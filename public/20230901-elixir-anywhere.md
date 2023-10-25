---
title: Elixirが無い所でもElixirを実行できるシェルスクリプト
tags:
  - ShellScript
  - Erlang
  - 関数型言語
  - Elixir
  - Docker
private: false
updated_at: '2023-09-02T08:41:59+09:00'
id: 79dfd4ea3d00b959c142
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

[Elixir]プログラマーは [Elixir]が好きなあまり、ついついなんでもかんでも[Elixir]でプログラムを記述しがちです。その点における一つ課題は、[Elixir]プログラミングをしない人のPCに必ずしも[Elixir]の実行環境があるわけではなく[Elixir]プログラムを実行できない場合があるということです。

「どこでもエリクサー」みたいなものを作ってみんなが気軽に[Elixir]スクリプトを実行できるようになれば、[Elixir]プログラマーとして気兼ねなく[Elixir]を書けて嬉しいですし、[Elixir]プログラミングをしない人にとっても[Elixir]という素敵な世俗派関数型言語 [^1] に出会う絶好の機会になるともいえます。

[Elixir]を使ってサーバーの費用を **$2 Million/年** 節約できたという話が大きく話題になりました。[Elixir]の素晴らしさをより多くの方々と共有できればなお嬉しいです。

https://paraxial.io/blog/elixir-savings

<!-- begin hyperlink list -->
[Elixir]: https://elixirschool.com/ja/why
[Docker]: https://docs.docker.jp/get-started/01_overview.html
[Mix]: https://hexdocs.pm/mix/Mix.html
[Erlang]: https://ja.wikipedia.org/wiki/Erlang
[hex]: https://hex.pm/
[rebar]: https://github.com/erlang/rebar3
[シェル]: https://ja.wikipedia.org/wiki/シェル
[bash]: https://ja.wikipedia.org/wiki/Bash
[バインドマウント]: https://docs.docker.jp/get-started/06_bind_mounts.html
<!-- end hyperlink list -->

## Elixir実行環境の有無を調べる方法

ターミナルで`elixir`コマンドを打つのが一番簡単だと思います。

```bash:ターミナル：Elixirのインストールされていない場合
root@d79eb598ea41:/# elixir
bash: elixir: command not found
```

他にもいろんなやり方あります。

`command -v`コマンドの終了値で判定する方法があります。正常終了の時に`0`、そうで無い場合に`1`以上の値が終了値となります。

```bash:ターミナル：コマンドの解釈に成功した場合
$ command -v bash
/bin/bash

$ echo $?
0
```

```bash:ターミナル：コマンドの解釈に失敗した場合
$ command -v nanjakore

$ echo $?
1
```

上述の特性を利用してこんな感じで条件分岐することができそうです。

```bash:ターミナル
if command -v elixir &>/dev/null; then
  echo "elixir is installed"
else
  echo "where is elixir?"
fi
```

`command -v`コマンドは現在のシェル環境が与えられたコマンドをどのように解釈するかを標準出力に出します。ここではそれは不要なのではブラックホール（`/dev/null`）に放り込んでいます。

## Elixirが無い所でElixirスクリプトを実行する方法

[Elixir]が無い所で[Elixir]スクリプトを実行する方法としては、[Docker]が手っ取り早いような気がします。

@torifukukaiou さんの「[Qiita CLI で取得した.md ファイルのファイル名を Elixir で変更する](https://qiita.com/torifukukaiou/items/aaca74a5033d0ddbc363#%E4%BD%BF%E3%81%84%E6%96%B9)」に登場する技が活用できそうです。

```bash:ターミナル：ElixirスクリプトをDockerコンテナ内で実行
docker run \
  --rm \
  --mount type=bind,src="$(pwd)",dst=/app \
  --workdir /app \
  elixir:1.15.4-otp-25-slim \
  elixir -e 'File.write("genki.txt", "元氣があればなんでもできる！\n")'
```

ポイントは、[Elixir]のイメージを使うことによりコンテナ内で[Elixir]が実行できるようになることと、[バインドマウント]することによりコンテナ内でのファイルの変更がホストマシンに反映されることです。

```bash:ターミナル：ホストにファイルが生成されたことを確認
$ cat ./genki.txt
元氣があればなんでもできる！
```

https://qiita.com/torifukukaiou/items/aaca74a5033d0ddbc363#%E4%BD%BF%E3%81%84%E6%96%B9

https://docs.docker.jp/get-started/06_bind_mounts.html

ファイルにするほどでもない短い[Elixir]コードは`-e`オプションで気軽に実行できます。

https://qiita.com/torifukukaiou/items/e07ed758d1259d14a2b7

以上の技を組み合わせ、本題に取り組みます。

## Elixirが無い所でElixirスクリプトを実行するシェルスクリプトを書く

まず、テスト用ディレクトリを作ってその中に入ります。

```bash:ターミナル
mkdir -p hoge && cd hoge
```

テスト用の楽しい[Elixir]スクリプトファイル（`my-power.exs`）を作ります。

[progress_bar](https://hex.pm/packages/progress_bar)パッケージをインストールしてプログレスバーを表示させるだけですが色々楽しめる[Elixir]プログラムです。

```elixir:ターミナル：テスト用のElixirスクリプトを作る
cat <<-'EOF' > ./my-power.exs
Mix.install([{:progress_bar, "~> 3.0"}])

[99..44, 44..77, 77..0]
|> Enum.concat()
|> Enum.each(fn i ->
  ProgressBar.render(i, 100,
    bar: " ",
    bar_color: [IO.ANSI.yellow_background()],
    blank_color: [IO.ANSI.red_background()]
  )

  Process.sleep(22)
end)

IO.puts([])
:ko
EOF
```

[Elixir]を実行する環境であれば、この時点で`elixir`コマンドを用いて[Elixir]スクリプトを直接実行できる所ですが、そうでない場合は実行できません。

```bash:ターミナル：Elixirのインストールされていない場合
$ elixir ./my-power.exs
bash: elixir: command not found
```

`elixir`コマンドが無い時に代わりに使える`./dokodemo-elixir.sh`を実装します。

```bash:ターミナル：elixirコマンドの代わりに使えるシェルスクリプトを作る-1
cat <<-'EOF' > ./dokodemo-elixir.sh
#!/bin/bash

docker run \
  --rm \
  --mount type=bind,src="$(pwd)",dst=/app \
  --workdir /app \
  elixir:1.15.4-otp-25-slim \
  elixir "$@"

echo "完了"
EOF
```

`./dokodemo-elixir.sh`を実行できるようにファイルのアクセス権を変えます。

```bash:ターミナル
chmod +x ./dokodemo-elixir.sh
```

`./dokodemo-elixir.sh`で`./my-power.exs`スクリプトを実行。

```bash:ターミナル
$ ./dokodemo-elixir.sh ./my-power.exs
```

:tada::tada::tada:


一回一回コンテナを起動して依存関係をインストールしているのでサクサクとは行かないですが、これで[Docker]さえインストールされていれば誰でも[Elixir]スクリプトを実行することができるようになりました。

比較的シンプルな[Elixir]スクリプトを共有する場合にこのテクニックが使える場面があるかもしれません。

場合によっては[Elixir]実行環境の有無により分岐をさせても良いかもしれません。

- [Elixir]実行環境のある場合
  - `elixir`コマンドで [Elixir]スクリプトを実行
- [Elixir]実行環境のない場合
  - `docker run`で`elixir`コンテナを起動してその中で [Elixir]スクリプトを実行

```bash:ターミナル：elixirコマンドの代わりに使えるシェルスクリプトを作る-2
cat <<-'EOF' > ./dokodemo-elixir.sh
#!/bin/bash

if command -v elixir &>/dev/null; then
  echo "elixirコマンドが見つかりました。それを使います。"
  elixir "$@"
else
  echo "elixirコマンドが見つかりませんでした。Dockerを使います。"

  docker run \
    --rm \
    --mount type=bind,src="$(pwd)",dst=/app \
    --workdir /app \
    elixir:1.15.4-otp-25-slim \
    elixir "$@"
fi

echo "完了"
EOF
```

:tada::tada::tada:

## Livebook

いま流行りのLivebookを使ってElixirコードをノートブックとして共有する方法もあります。この方法だと[Docker]さえも不要になります。

https://livebook.dev/

https://moneyforward-dev.jp/entry/2023/08/31/100000

https://qiita.com/tags/livebook

https://notes.club/

<!-- begin footnotes -->

[^1]: @kikuyuta 先生の「[世俗派関数型言語 Elixir を関数型言語風に使ってみたらやっぱり関数型言語みたいだった](https://qiita.com/kikuyuta/items/afa4c264720eb29d9760)」より。

<!-- end footnotes -->
