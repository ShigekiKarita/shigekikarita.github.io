# OCaml notes

### Unicode 文字列の操作

OCamlで日本語(とunicode全般)を処理するには、どうすればいいのか...。[Reddit - Libraries and Tools for Unicode/UTF-8 strings in OCaml?](https://www.reddit.com/r/ocaml/comments/39t31h/libraries_and_tools_for_unicodeutf8_strings_in/)によると[Camomile](https://github.com/yoriyuki/Camomile)と、[Batteries](https://github.com/ocaml-batteries-team/batteries-included)が挙がっていました。現在Camomileは開発終了され、その作者はBatteriesの[BatText](http://ocaml-batteries-team.github.io/batteries-included/hdoc2/BatText.html)に貢献しているのでとりあえずBatteriesを使おうと思います。

BatteriesはC++でいうBoostのようなライブラリ集で、標準ライブラリの機能拡張を提供しています。`open Batteries`で標準ライブラリを上書きして簡単に使えます(例えば`BatText`モジュールは`Text`として使える)。ただしBatteriesは非互換の変更が多く、ドキュメントも色んなverが公開されてるのは注意です。[Non-backwards-compatible changes](https://github.com/ocaml-batteries-team/batteries-included/wiki/Interfacechanges12#non-backwards-compatible-changes)によると、Unicode関係のライブラリは以前はRopeという名前でしたが今はBatTextらしいです。BatTextライブラリでは文字列の実装はRopeという永続的データ構造でありながら、操作後も可能な限りデータを共有するため、長さ\\(n\\)の文字列に\\(m\\) (ただし\\((n >> m)\\))回の操作で\\(O(m)\\)サイズの空間しか使わないとか。ただ、逆順にしたりするくらいなら、標準の`Str`モジュールやBatteriesの`String`モジュールでもそんなに困らないような気もしています。

### 一通りの簡単な使い方

簡単な例として(日本語の)文字列を交互に結合する[自然言語処理100本ノック](http://www.cl.ecei.tohoku.ac.jp/nlp100/)の1本目で説明します。
まずライブラリの batteries と自動ビルドするコマンドをインストールします。

`$ opam install batteries ocamlbuild`

`utop`などの対話ツールが便利なんですが、何故かUnicode文字列が文字化けしたりするので、今回は基本的にコンパイルして結果を確認しています。コンパイルをするには`_tags`という依存ライブラリを書いたファイル

```
<*>: package(batteries)
```

を用意して、以下のコマンドで`q01.ml`というファイル

```
open Batteries

let zip_string a b =
  let to_enum =  Text.enum % Text.of_string in
  let ea = to_enum a in
  let eb = to_enum b in
  let append2 x y = Text.append_char x %> Text.append_char y in
  let zip_text = Enum.fold2 append2 Text.empty in
  zip_text ea eb |> Text.to_string

let () = zip_string "パトカー" "タクシー" |> print_endline
```

ここで、ギョッとするけど`%`とか`%>` は関数合成です(適用順が逆同士)。デフォルトで有効になっている中置き演算子は[BatPervasives](https://ocaml-batteries-team.github.io/batteries-included/hdoc2/BatPervasives.html)に説明してあります。あと[(Bat)Enum](https://ocaml-batteries-team.github.io/batteries-included/hdoc2/BatEnum.html)は, [githubのwiki](https://github.com/ocaml-batteries-team/batteries-included/wiki/Introduction-to-batEnum)によるとデータ構造の変換ブリッジや、線形アルゴリズムの実装に使うものらしいけど、`List`とどう違うのかはよくわからない、ただ関係する関数を見てると使い捨て(処理の中間で使う)データ構造らしく[D言語のRange](https://www.tutorialspoint.com/d_programming/d_programming_ranges.htm)っぽい感じがします(適当)。

細かいことはともかく、以下のようにコンパイル＆実行できます。

```
$ ocamlbuild -use-ocamlfind ./q01.native
$ ./q01.native
パタトクカシーー
```

また何か、自然言語処理100本ノックやって知見がたまったら続き書きます。
