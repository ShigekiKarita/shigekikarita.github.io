#include <iostream>
#include <thrust/device_vector.h>
#include <cooperative_groups.h>

namespace cg = cooperative_groups;


__global__ void iota(float* data) {
    auto i = threadIdx.x + blockIdx.x * blockDim.x;
    data[i] = i;
}

// [rank + 2の倍数] 番目のデータの和
__device__ float reduce_sum(cg::thread_group g, float* temp, float acc) {
    auto lane = g.thread_rank();
    for (auto i = g.size() / 2; i > 0; i /= 2) {
        temp[lane] = acc;
        g.sync(); // 全threadのストアが終わるまで待機
        if (lane < i) {
            acc += temp[lane + i];
        }
        g.sync(); // 全threadのロードが終わるまで待機
    }
    return acc; // 0番目スレッドの返り値が完全な合計になる
}

__device__ float thread_sum(float *input, int n) {
    float sum = 0;
    // 4-dim ベクトル化による高速化
    // https://devblogs.nvidia.com/cuda-pro-tip-increase-performance-with-vectorized-memory-access
    for(auto i = blockIdx.x * blockDim.x + threadIdx.x;
        i < n / 4; 
        i += blockDim.x * gridDim.x) {
        auto in = reinterpret_cast<float4*>(input)[i];
        sum += in.x + in.y + in.z + in.w;
    }
    return sum;
}

__global__ void sum_kernel_block(float* sum, float* input, int n) {
    auto my_sum = thread_sum(input, n);

    extern __shared__ int temp[];
    auto g = this_thread_block();
    auto block_sum = reduce_sum(g, temp, my_sum);

    if (g.thread_rank() == 0) atomicAdd(sum, block_sum);
}

int main() {
    thrust::device_vector<float> data(11);
    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, 0); // 0番目デバイスの情報取得
    int max_block_size = prop.maxThreadsPerBlock;
    std::cout << max_block_size << std::endl;

    dim3 block_size(32, 1, 1);
    dim3 grid_size((data.size() + block_size.x - 1) / block_size.x, 1, 1);
    iota<<<block_size, grid_size>>>(thrust::raw_pointer_cast(data.data()));
    for (auto d : data) {
        std::cout << d << std::endl;
    }
}
