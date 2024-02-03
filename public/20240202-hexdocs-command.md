---
title: いつでもElixirのドキュメントがみれるコマンドを作る
tags:
  - Elixir
  - Bash
private: false
updated_at: ''
id:
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

## 結論

試行錯誤した結果、二つのシンプルなシェル関数ができ、満足しています。
これらを`.bashrc`で読み込み、いつでもターミナルで使えるようにしています。

###　Elixirライブラリのドキュメントを開くコマンド

ElixirライブラリのドキュメントをWEBブラウザで開くコマンドです。

何も引数がない場合、Elixirのドキュメントを開きます。
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

###　Elixirライブラリを検索するコマンド

Elixirライブラリ

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
Linuxの場合には `xdg-open` が存在するという前提で、あえてそのチェックはしていません。

```bash:ターミナル
# make sure the open command is available
if ! command -v open &>/dev/null; then
  alias open='xdg-open &>/dev/null'
fi
```

:tada::tada::tada:

## 最後に一言

今の所うまくイゴいています。実はLinuxで動作確認していません。後日確認します。

本記事は [piyopiyo.ex #25：もくもく作業タイム](https://piyopiyoex.connpass.com/event/308605/) の成果です。ありがとうございます。

https://autoracex.connpass.com/

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)

<!-- begin links -->

[Application.app_dir/2]: https://hexdocs.pm/elixir/Application.html#app_dir/2
[asdf]: https://asdf-vm.com/
[bash]: https://ja.wikipedia.org/wiki/Bash
[BeagleBone]: https://www.beagleboard.org/boards/beaglebone-black
[Buildroot]: https://buildroot.org/
[cavocado/pinout]: https://hex.pm/packages/pinout
[Debian]: https://ja.wikipedia.org/wiki/Debian
[Elixir]: https://ja.wikipedia.org/wiki/Elixir_(プログラミング言語)
[Erlang VM]: https://en.wikipedia.org/wiki/BEAM_(Erlang_virtual_machine)
[Erlang]: https://ja.wikipedia.org/wiki/Erlang
[Erlang]: https://www.erlang.org/
[hex]: https://hex.pm/
[IEx]: https://elixirschool.com/ja/lessons/basics/basics#%E5%AF%BE%E8%A9%B1%E3%83%A2%E3%83%BC%E3%83%89-2
[LFE]: https://en.wikipedia.org/wiki/LFE_(programming_language)
[Linux]: https://ja.wikipedia.org/wiki/Linux
[Livebook]: https://livebook.dev/
[Mix]: https://hexdocs.pm/mix/Mix.html
[Nerves Livebook]: https://github.com/nerves-livebook/nerves_livebook
[Nerves Systems Builder]: https://github.com/nerves-project/nerves_systems
[Nerves Target]: https://hexdocs.pm/nerves/supported-targets.html
[nerves_bootstrap]: https://github.com/nerves-project/nerves_bootstrap
[nerves_system_br]: https://github.com/nerves-project/nerves_system_br
[nerves_system_rp4]: https://github.com/nerves-project/nerves_system_rpi4
[nerves_systems]: https://github.com/nerves-project/nerves_systems
[nerves]: https://github.com/nerves-project/nerves
[Nerves]: https://github.com/nerves-project/nerves
[Phoenix]: https://www.phoenixframework.org/
[Raspberry Pi 4]: https://www.raspberrypi.com/products/raspberry-pi-4-model-b/
[Raspberry Pi 5]: https://www.raspberrypi.com/products/raspberry-pi-5/
[Raspberry Pi Zero W]: https://www.raspberrypi.com/products/raspberry-pi-zero-w/
[Raspberry Pi]: https://www.raspberrypi.com/products/raspberry-pi-5/
[rebar]: https://github.com/erlang/rebar3
[SDカード]: https://ja.wikipedia.org/wiki/SD%E3%83%A1%E3%83%A2%E3%83%AA%E3%83%BC%E3%82%AB%E3%83%BC%E3%83%89
[SquashFS]: https://ja.wikipedia.org/wiki/SquashFS
[シェル]: https://ja.wikipedia.org/wiki/シェル
[ピン配置図]: https://en.wikipedia.org/wiki/Pinout
[対象ボード]: https://hexdocs.pm/nerves/targets.html

<!-- end links -->
