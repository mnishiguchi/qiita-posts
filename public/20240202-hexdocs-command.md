---
title: いつでもElixirのドキュメントがみれるコマンドを作る
tags:
  - Bash
  - Elixir
private: false
updated_at: '2024-02-03T13:46:58+09:00'
id: aa18ea0dcbb66bc1ecd8
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

## はじめに

[Elixir] プログラミングを楽しんでいるときに、ドキュメントを読んで確認したいことがあると思います。

皆さんはどのようにドキュメントを開いてますか。おそらくいろんなやり方があるのだろうと思います。

ここでは僕が使っているコマンドをご紹介いたします。

## やりたいこと

ターミナルでコマンドを打つと、ブラウザが開き、[Elixir]のドキュメントが表示される仕組みを作る。

## 環境

```bash
$ uname -a
Darwin MBP-M1 23.2.0 Darwin Kernel Version 23.2.0: Wed Nov 15 21:53:18 PST 2023; root:xnu-10002.61.3~2/RELEASE_ARM64_T6000 arm64

$ elixir --version
Erlang/OTP 26 [erts-14.2.1] [source] [64-bit] [smp:10:10] [ds:10:10:10] [async-threads:1] [jit]

Elixir 1.16.0 (compiled with Erlang/OTP 26)

$ bash --version
GNU bash, version 5.2.26(1)-release (aarch64-apple-darwin23.2.0)
Copyright (C) 2022 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>

This is free software; you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
```

## 結論

試行錯誤した結果、二つのシンプルなシェル関数ができ、満足しています。

これらを`.bashrc`で読み込み、いつでもターミナルで使えるようにしています。

### Elixirライブラリのドキュメントを開くコマンド

[Elixir]ライブラリのドキュメントをWEBブラウザで開くコマンドです。

何も引数がない場合、[Elixir]のドキュメントを開きます。

引数にライブラリ名（`mix.exs`ファイルに記述する名称）を渡すとそれのドキュメントが開きます。

```bash:.bashrc
hexdocs() { mix hex.docs online "${1:-elixir}"; }
```

**使い方**

```bash:ターミナル
# Elixir のドキュメントをWEBブラウザで開く
hexdocs

# Phoenix のドキュメントをWEBブラウザで開く
hexdocs phoenix

# Nerves のドキュメントをWEBブラウザで開く
hexdocs nerves
```

[mix hex.docs] Mixタスクをラップしただけですので、それを直接呼んでもいいと思います。

また、[Mix]を使うには[Elixir]がインストールされている必要があります。

https://hexdocs.pm/hex/Mix.Tasks.Hex.Docs.html

[mix hex.docs]: https://hexdocs.pm/hex/Mix.Tasks.Hex.Docs.html


### Elixirライブラリを検索するコマンド

[Elixir]ライブラリを検索し、結果をWEBブラウザで開くコマンドです。

引数に検索キーワードを渡します。

```bash:.bashrc
hexpm() { open "https://hex.pm/packages?search=${1:-}"; }
```

**使い方**

```bash:ターミナル
# "liveview"というキーワードを含むElixirライブラリを検索し、結果をWEBブラウザで開く
hexdocs liveview
```

## macOS のopenコマンド

macOS の `open` コマンドは、ターミナルからファイルやアプリを適切なアプリで開いてくれる便利なコマンドです。

Linuxにも似たようなものがありますが、コマンド名が異なるので、どちらのOSでも使えるようにするには工夫が必要です。

これは一例です。 `open` コマンドが存在しない場合に、`open` という名称のエイリアスを定義しています。
[Linux]の場合には `xdg-open` が存在するという前提で、あえてそのチェックはしていません。`xdg-open` が存在しない環境でお使いの場合は適宜コードを調整してください。

```bash:ターミナル
# make sure the open command is available
if ! command -v open &>/dev/null; then
  alias open='xdg-open &>/dev/null'
fi
```

:tada::tada::tada:

## 最後に一言

今の所うまくイゴいています。
実はLinuxで動作確認していません。後日確認します。

本記事は [piyopiyo.ex #25：もくもく作業タイム](https://piyopiyoex.connpass.com/event/308605/) の成果です。ありがとうございます。

https://piyopiyoex.connpass.com/

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)

<!-- begin links -->

[Application.app_dir/2]: https://hexdocs.pm/elixir/Application.html#app_dir/2
[asdf]: https://asdf-vm.com/
[bash]: https://ja.wikipedia.org/wiki/Bash
[Debian]: https://ja.wikipedia.org/wiki/Debian
[Elixir]: https://ja.wikipedia.org/wiki/Elixir_(プログラミング言語)
[Erlang VM]: https://en.wikipedia.org/wiki/BEAM_(Erlang_virtual_machine)
[Erlang]: https://ja.wikipedia.org/wiki/Erlang
[Erlang]: https://www.erlang.org/
[hex]: https://hex.pm/
[IEx]: https://elixirschool.com/ja/lessons/basics/basics#%E5%AF%BE%E8%A9%B1%E3%83%A2%E3%83%BC%E3%83%89-2
[Linux]: https://ja.wikipedia.org/wiki/Linux
[Livebook]: https://livebook.dev/
[Mix]: https://hexdocs.pm/mix/Mix.html
[nerves]: https://github.com/nerves-project/nerves
[Nerves]: https://github.com/nerves-project/nerves
[Phoenix]: https://www.phoenixframework.org/

<!-- end links -->
