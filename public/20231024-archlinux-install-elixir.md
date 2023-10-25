---
title: Arch Linux に Elixir をインストール
tags:
  - Erlang
  - Linux
  - archLinux
  - Elixir
  - asdf
private: false
updated_at: '2023-10-25T12:25:04+09:00'
id: 122249b6c27391f03d82
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

[Arch Linux] のマシンにプログラミング言語 [Elixir] をインストールします。

https://elixir-lang.info/

<!-- begin links -->
[Elixir]: https://ja.wikipedia.org/wiki/Elixir_(プログラミング言語)
[Arch Linux]: https://ja.wikipedia.org/wiki/Arch_Linux
[Erlang VM]: https://en.wikipedia.org/wiki/BEAM_(Erlang_virtual_machine)
[asdf]: https://asdf-vm.com/
<!-- end links -->

## Elixir をインストールする色んな方法

色んなやり方があります。

https://elixir-lang.jp/install.html

ここではバージョン管理ツール [asdf] を使用して [Elixir] をインストールします。

## asdf のインストール

基本的に [asdf] の [Getting Started](https://asdf-vm.com/guide/getting-started.html) ドキュメントの通りです。

`curl` と `git` がまだインストールされてない場合は、それらをインストールします。

```bash:ターミナル
sudo pacman -S curl git
```

`--branch` オプションで[バージョン](https://github.com/asdf-vm/asdf/releases)を指定してインストールします。
執筆時点の最新版は `v0.13.1` でした。

```bash:ターミナル
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1
```

実はバージョンはあまり気にしなくても大丈夫です。以下のコマンドでいつでもアップデートできます。

```bash:ターミナル
asdf update
```

https://qiita.com/torifukukaiou/items/9009191de6873664bb58


あと、ターミナルの起動時に asdf のスクリプトが実行されるようにしたいのですが、これはお使いのシェルにより異なりますので、[ドキュメント](https://asdf-vm.com/guide/getting-started.html#_3-install-asdf)をご参照ください。以下は bash の一例です。

```bash:~/.bashrc
. "$HOME/.asdf/asdf.sh"
```

## Erlang のインストール

[Elixir] は [Erlang VM] 上で動作するので [Elixir] をインストールする前に Erlang がインストールされている必要があります。

まず必要なパッケージをインストールします。

```bash:ターミナル
sudo pacman -S base-devel ncurses glu mesa wxwidgets-gtk3 libpng libssh unixodbc libxslt fop
```

asdf に [Erlang プラグイン](https://github.com/asdf-vm/asdf-erlang) を追加。

```bash:ターミナル
asdf plugin add erlang
```

erlang の最新版をインストール。

```bash:ターミナル
asdf install erlang latest
```

erlang の最新版を使うように設定。

```bash:ターミナル
asdf global erlang latest
```

## Elixir のインストール

erlang のインストールと同様の手順です。 [Elixir プラグイン](https://github.com/asdf-vm/asdf-elixir)を利用します。

```bash:ターミナル
sudo pacman -S unzip

asdf plugin add elixir
asdf install elixir latest
asdf global elixir latest
```

余談ですが、[Elixir] 言語を使ってサーバーの費用を **$2 Million/年** 節約できたというウワサがあります。

https://paraxial.io/blog/elixir-savings

## インストールされた内容を確認

```bash:ターミナル
asdf list
asdf current
```

## 対話シェル（IEx）を試してみる

`iex` コマンドで Elixir 対話シェル（IEx）を起動します。

```bash:ターミナル
iex
```

適当に Elixir を楽しみます。

```elixir:IEx
Mix.install([{:progress_bar, "~> 3.0"}])

my_life = fn ->
  Enum.each Enum.concat([99..44, 44..77, 77..0]), fn i ->
    format = [
      bar: " ",
      bar_color: [IO.ANSI.yellow_background],
      blank_color: [IO.ANSI.red_background],
    ]
    ProgressBar.render(i, 100, format)
    Process.sleep(20)
  end
  IO.puts("")
  :ko
end

my_life.()
```

https://elixirschool.com/ja/lessons/basics/basics#%E5%AF%BE%E8%A9%B1%E3%83%A2%E3%83%BC%E3%83%89-2

## 全部一氣にインストールしてみる

```bash:ターミナル
sudo pacman -S curl git

git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1

asdf update

sudo pacman -S base-devel ncurses glu mesa wxwidgets-gtk3 libpng libssh unixodbc libxslt fop unzip

plugin_names=(erlang elixir)

for plugin_name in "${plugin_names[@]}"; do
  asdf plugin add "$plugin_name"
  asdf install "$plugin_name" latest
  asdf global "$plugin_name" latest
done
```

https://qiita.com/mnishiguchi/items/68fb2869110bc823e595

## インストールに失敗した場合

正しい手順でやっていてうまくいかないときは、インストールし直すとうまく行くことが多いです。

その場合、順番が大事です。システムで必要なパッケージ、Erlang、Elixirの順にインストールするのがコツです。

https://elixirforum.com/t/cannot-start-observer-undefinedfunctionerror-function-observer-start-0-is-undefined/56642/3

https://elixirforum.com/t/couldnt-start-observer-failed-to-load-nif-library-asdf-installs-erlang-24-0-4-lib-wx-2-0-1-priv-wxe-driver-so/47813

https://github.com/asdf-vm/asdf-erlang/issues/35
