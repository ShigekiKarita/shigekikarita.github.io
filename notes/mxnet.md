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

