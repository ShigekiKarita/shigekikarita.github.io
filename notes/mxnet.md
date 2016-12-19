最終更新 2016.12.20

# MxNet

## install (with Intel MKL)

画像のタスクをやるつもりはないので、OpenCVはなし、BLASはビルド面倒なのでMKLを使います。依存関係の調整はMakefileのあるルートディレクトリで

```
$ git clone https://github.com/dmlc/mxnet.git --recursive
$ cd mxnet
$ cp ./make/config.mk .
```

として、config.mk を編集して使います。
`USE_...` という変数を確認して依存の有無を制御できるので、何かがなくてビルドエラーになったときは `USE_OPENCV=0` といった具合でオフにしてみましょう。ちなみに IntelMKLは 2017 のやつを使ってるのですが、experimental のオプションは使えませんでした。要調査。

```
$ make -j 4 USE_OPENCV=0 USE_BLAS=mkl
```

mkl のパスがうまく設定できないときは MKL を install したディレクトリ下 (例. /opt/intel) のスクリプトを使うと動くかもしれない

```
$ source /opt/intel/bin/compilervars.sh -arch intel64 -platform linux
```


## warp-ctc を使う注意

最近、warp-ctc のHEADには破壊的変更があったらしく release されてる [v1.0](https://github.com/baidu-research/warp-ctc/archive/v1.0.tar.gz) を使う。`make install` しない場合はきちんと libwarpctc.so ファイルのある場所に `LD_LIBRARY_PATH` を通せばうごきます。動いてるかどうかは以下で確認できます。

```
$ cd example/warpctc
$ python toy_ctc.py
```

うちの環境では GTX760 (デスクトップ) 1300 samples/sec, Quadro42C (ラップトップ) 1000 samples/sec くらいでした。


## Bucketing とは何か

https://github.com/dmlc/mxnet/blob/master/docs/how_to/bucketing.md

RNN のような(時間方向に)動的な計算グラフを持つモデルを定義する場合、Tensorflow や MxNet のようなシンボル定義のフレームワークでは**長めに時間方向を展開したグラフを静的に作る**必要があります。しかしながら、最大長よりかなり短いデータを扱うときは計算が非効率です。ちなみにMxNetやchainerなどのフレームワークはforループを使い動的なグラフを作れますが、欠点として複雑なモデル(LSTMやsequence-to-sequenceなど)の動作はデータ毎に計算グラフ生成(+ あればグラフ最適化)のコストがかかるので遅いです。

そこで普及しているRNN実装が Bucketing。やってることは簡単で、最大の系列長で定義したグラフではなく、**複数の系列長で定義した異なるグラフたち(bucket)を使い、データの系列長に近いグラフを適宜取り出して訓練に用いる**だけです。ただし異なるグラフでも、パラメタは全て同じものを共有している必要がある、そしてbucket内の計算グラフは再利用できると効率がいい。


### ~MxNetの良いところ~

計算グラフのパラメタ共有や再利用はMxNetではフレームワークの機能としてサポートしている。MxNetにおける実装方法はモデルの定義は弄らなくてよく、データの渡し方(bucket長にデータを切り出す or 埋める)を工夫してやれば良いらしい。下記の例でも、bucket の有無でモデルに違いはない。動的にグラフを作るには sym_gen 関数にそのデータ長を毎回設定すれば良い

https://github.com/dmlc/mxnet/blob/master/example/rnn/lstm_bucketing.py

### ~MxNetの嫌なところ~

どうやら `mxnet.model.FeedForward` は `symbol` 引数に計算グラフではなく、[関数(callable)を渡す](https://github.com/dmlc/mxnet/blob/c6db87842cac64bf001f0c66c279800e32300321/python/mxnet/model.py#L436)と、学習に使う fit メソッドに渡される `X, eval_data` は [default_bucket_keyメンバ=fitで使うバケット長を持つイテレータと解釈する](https://github.com/dmlc/mxnet/blob/c6db87842cac64bf001f0c66c279800e32300321/python/mxnet/model.py#L761)めちゃくちゃアドホックな動作をするらしい。さすがにドキュメントなり、専用のクラスだったり作るべきだと思います。



## ハマりどころ

### 環境変数が多い

http://mxnet.io/how_to/env_var.html

+ GridEngineなどを使っている環境では Memory 系や `***_NTHREADS`系には気をつけたい
+ 1 とか true とか混在していて気持ち悪い
+ 可能であれば `MXNET_GPU_WORKER_NTHREADS` は大きな値を設定したほうが良い。(注意: これは1GPUデバイス辺りのスレッド数)
