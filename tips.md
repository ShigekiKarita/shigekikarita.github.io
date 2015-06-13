---
layout: page
---

## Tips

便利な小ネタを紹介します。

<br>

---

<br>

### C言語のバージョン

C言語には複数のバージョンがあり、GCC4.x はデフォルトで 1989 年のバージョンを使っています。
しかし、改良を重ねた 1999 年や 2011 年のバージョンを使う方が以下の点で便利です。

+ 変数がどこでも宣言できる
+ 一行コメント ``//`` 
+ ガンマ関数、複素数型など標準ライブラリの充実
+ ... etc

なお、新しいバージョンを使う方法は ``gcc main.c -std=c99`` としてコンパイルするだけです。
(2011年の規格は ``-std=c11`` )

<br>

---

<br>

### Makefile を使う

沢山の便利な機能(フラグ)がコンパイラにはありますが毎回全てをコマンド入力するのは面倒です。
さらに、他の人のライブラリなど複数ソースコードを使うときなんかも入力が面倒で、
一週間も経てば忘れてしまいます。
そんなとき、Makefile (GNU Make) を作ると便利です。

以下のコードは、あるフォルダに ``main.c`` と
その中で include されるヘッダ ``other.h`` の実装コード ``other.c`` が存在するときに書いておく ``Makefile``の 例です。

{% highlight make %}
CFLAGS=-O2 -Wall -Wextra -std=c99 -fdiagnostics-color=auto
CC=gcc
LIBS=-lm

all: main

main: main.o other.o $(LIBS)

clean:
	rm -rf *.o main
{% endhighlight %}

使い方は簡単で、上記のフォルダで ``make`` と入力するだけで以下のコマンドが実行され、
``main`` という実行ファイルが出力されます。
{% highlight bash %}
gcc -O2 -Wall -Wextra -Wunreachable-code -std=c99    -c -o main.o main.c
gcc -O2 -Wall -Wextra -Wunreachable-code -std=c99    -c -o other.o other.c
gcc   main.o other.o /usr/lib/x86_64-linux-gnu/libm.so   -o main
{% endhighlight %}

ちなみに Makefile は殆どのプログラミング言語に対応しているので日常的に役に立ちます。

