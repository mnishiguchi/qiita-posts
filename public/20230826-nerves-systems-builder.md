---
title: Nerves Systems BuilderでNervesシステムを自分でビルドする
tags:
  - Erlang
  - Elixir
  - IoT
  - Nerves
private: false
updated_at: '2023-08-27T20:49:05+09:00'
id: 53c68d1a2006d97c8a72
organization_url_name: fukuokaex
slide: false
---

[Nerves]でファームウエアをビルドする時は、通常は[取扱説明書](https://hexdocs.pm/nerves/getting-started.html#creating-a-new-nerves-app)の通りの手順で[Nervesコアチームが公式サポートするNervesシステム](https://github.com/nerves-project/nerves#hardware)を利用することが多いと思います。それらはパッケージ化されており、自分のNervesプロジェクトの依存性リストに追加するだけで自動的に必要なバイナリをダウンロードしてくれます。

しかしながら、それは既にリリースされているNervesシステムにおける話であって、まだリリースされていないシステムは自分でビルドする必要があります。例えば、リリース前の最新の機能を試したい場合、Nervesコアチームの開発・テストの支援をしたい場合、カスタムシステムを構築したい場合などが考えられます。

:::note info
本記事の内容は[Nerves Systems Builder]のREADMEに毛が生えたようなものです。原典も合わせてご参照ください。
:::

<!-- begin hyperlink list -->
[Nerves]: https://github.com/nerves-project/nerves
[nerves]: https://github.com/nerves-project/nerves
[nerves_systems]: https://github.com/nerves-project/nerves_systems
[Nerves Systems Builder]: https://github.com/nerves-project/nerves_systems
[Elixir]: https://ja.wikipedia.org/wiki/Elixir_(プログラミング言語)
[Mix]: https://hexdocs.pm/mix/Mix.html
[Buildroot]: https://buildroot.org/
[x86_64]: https://ja.wikipedia.org/wiki/X64
[aarch64]: https://ja.wikipedia.org/wiki/AArch64
[Linux]: https://ja.wikipedia.org/wiki/Linux
[仮想機械]: https://ja.wikipedia.org/wiki/仮想機械
[Linuxディストリビューション]: https://ja.wikipedia.org/wiki/Linuxディストリビューション
[Debian]: https://ja.wikipedia.org/wiki/Debian
[Erlang]: https://ja.wikipedia.org/wiki/Erlang
[hex]: https://hex.pm/
[rebar]: https://github.com/erlang/rebar3
[asdf]: https://asdf-vm.com/
[asdf installation]: https://asdf-vm.com/guide/getting-started.html#_3-install-asdf
[nerves_bootstrap]: https://github.com/nerves-project/nerves_bootstrap
[シェル]: https://ja.wikipedia.org/wiki/シェル
[bash]: https://ja.wikipedia.org/wiki/Bash
[アーカイブ]: https://ja.wikipedia.org/wiki/アーカイブ_(コンピュータ)
[インクリメンタルビルド]: https://ja.wikipedia.org/wiki/ビルド_(ソフトウェア)
[対象ボード]: https://hexdocs.pm/nerves/targets.html
<!-- end hyperlink list -->

## Nervesシステムをビルドする方法

やり方はいくつかあります。

- 他の[Elixir]プロジェクトをビルドする方法と同様に[Mix]を使用
  - 推奨
  - 複数のOSに対応
- [Nerves Systems Builder]
  - Nervesコアチームが便宜上つかっているスクリプト
  - Nervesシステムを構築および保守するためのスクリプトを提供
  - [Buildroot]を頻繁に使用する場合、または複数のNervesシステムを保守する場合にビルドが比較的高速
  - [x86_64]または[aarch64]上の[Linux]でのみで動作　（[仮想機械]のLinuxでも動作するらしい）

## Linuxマシンを準備

- CPUアーキテクチャ: [x86_64]または[aarch64]
- OS: `Linux`
- 空きディスク容量: `128 GB`以上

## 必要なライブラリをインストール

[Debian]系の[Linuxディストリビューション]の場合、以下のコマンドで必要なライブラリをインストールします。

```bash:terminal
sudo apt update
sudo apt install git build-essential bc cmake cvs wget curl mercurial python3 python3-aiohttp python3-flake8 python3-ijson python3-nose2 python3-pexpect python3-pip python3-requests rsync subversion unzip gawk jq squashfs-tools libssl-dev automake autoconf libncurses5-dev
```

## ErlangとElixirをインストール

[Erlang] と [Elixir]をインストールします。一例として[asdf]を用いたインストール方法は以下の通りです。

```bash:terminal
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.12.0
asdf update

plugins=(erlang　elixir)

for plugin in "${plugins[@]}"; do
  asdf plugin add "$plugin"
  asdf install "$plugin" latest
  asdf global "$plugin" latest
done
```

[asdf]をインストールした後のやり方がお使いの[シェル]によって異なるため、詳しくは[asdfの公式ドキュメント][asdf installation]をご参照ください。[bash]の場合は以下の通りです。

```bash:terminal
echo '. $HOME/.asdf/asdf.sh' >> ~/.bashrc
echo '. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc
source ~/.bashrc
```

https://qiita.com/torifukukaiou/items/9009191de6873664bb58

https://qiita.com/mnishiguchi/items/68fb2869110bc823e595


## hexとrebarをインストール

- [hex] : Erlangエコシステムのパッケージマネージャ
- [rebar] : Erlangビルドツール

```bash:terminal
mix local.hex
mix local.rebar
```

これで、[nerves_bootstrap]を[Mix]環境に追加する準備が整いました。

## nerves_bootstrapをインストール

[nerves_bootstrap]アーカイブをインストールすることにより、[Nerves]開発用の[Mix]環境を構築し、各[対象ボード]に対応するクロスコンパイラが利用可能になります。また、[nerves_bootstrap]アーカイブには、新しいNervesプロジェクトの作成に使用できるプロジェクトジェネレーターも含まれています。

```bash:terminal
mix archive.install hex nerves_bootstrap
```

:::note warn
ここでインストールするのは[nerves_bootstrap]アーカイブです。[nerves]パッケージではないので注意してください。

https://github.com/nerves-project/nerves/blob/37c7312d51e7e17908910bd534cbc36807ad2de9/mix.exs#L115-L120
:::

https://hexdocs.pm/mix/Mix.Tasks.Archive.Install.html

## Nerves Systems Builderをダウンロード

[Nerves Systems Builder]は現時点ではバージョン管理されていません。あくまでNervesコアチームが使っている便利ツールという位置付けのようです。

```bash:terminal
git clone git@github.com:nerves-project/nerves_systems.git
```

## Nerves Systems Builderの設定

設定は `config/config.exs` ファイルにて行います。

設定サンプルが[`config/starter-config.exs`](https://github.com/nerves-project/nerves_systems/blob/main/config/starter-config.exs)にありますので、それを`config/config.exs`にコピーし、適宜調整するのが手っ取り早いです。

```bash:Nerves Systems Builder用のターミナル
cd path/to/nerves_systems

cp config/starter-config.exs config/config.exs

open config/config.exs
```

ビルドしたいNervesシステム以外をコメントアウトするとビルドにかかる時間を短縮できます。

## ビルドしたいNervesシステムのソースコードをダウンロード

`mix ns.clone`タスクで設定ファイルに列挙したNervesシステムを`src`ディレクトリにダウンロードします。

```bash:Nerves Systems Builder用のターミナル
mix ns.clone
```

`mix ns.clone`はだた`git clone`するだけなので、ご自分で`git clone`されても結果は同じです。

```text:srcディレクトリはこんな感じ
src/
    nerves_system_br
    nerves_system_rpi0
    nerves_system_bbb
    ...
```

やり直す時は迷わず`rm -fr src`で`src`ディレクトリを消去してしまって大丈夫です。

## Nerves Systems BuilderでNervesシステムをビルド

Nervesシステムをビルドには2つの段階があります。`mix ns.build`は両方のステップを実行します。

1. 出力ディレクトリ内の`nerves_defconfig`を`.config`ファイルに変換
2. 出力ディレクトリ内で`make`を実行

出力ディレクトリは`o/<システムの短縮名>`（例、`o/rpi0`）です。

[インクリメンタルビルド]はできる場合とできない場合が考えられます。うまくいかない場合は、出力ディレクトリを削除してビルドを最初からやり直してください。

```bash:Nerves Systems Builder用のターミナル
mix ns.build
```

:::note info
- `mix ns.build`が失敗した場合は、失敗した出力ディレクトリに移動し、`make` を再実行してください。
- `make source`を実行するとまず全てをダウンロードし、のちに`make`することが可能です。
- ダウンロードされたものは `~/.nerves/dl/` に保存されます。
- `make menuconfig`を実行した後には`make savedefconfig`を実行してください。`src/nerves_system_xyz`に更新内容が反映されますので、必要に応じてコミットしてください。
:::

## ビルドしたNervesシステムを使ってファームウエアを作る

### 別のターミナルを開く

別のターミナルを開き、そこでご自身のNervesファームウエアプロジェクトを開きます。

### 環境変数をセットする

`mix.exs`で参照されている通常のパッケージ化されたNervesシステムではなくカスタムNervesシステムを使用するようにと[nerves]に指示するための特別な環境変数がいくつかあります。

1. [対象ボード]に対応する`nerves.env.sh`スクリプトを見つけます。
1. ご自身のNervesファームウエアプロジェクトのターミナルで実行します。

`nerves.env.sh`スクリプトは各[対象ボード]に対応する出力ディレクトリ内にあります。

[対象ボード]は Raspberry Pi Zero の場合、スクリプトのパスは`~/path/to/nerves_systems/o/rpi0/nerves-env.sh`となります。

```bash:ご自身のNervesファームウエアプロジェクト用のターミナル
. ~/path/to/nerves_systems/o/rpi0/nerves-env.sh
```

また、通常どおり`MIX_TARGET`を設定することを忘れないでください。Raspberry Pi Zero の場合は以下の通りとなります。

```bash:ご自身のNervesファームウエアプロジェクト用のターミナル
export MIX_TARGET=rpi0
```

## あとはいつも通り

https://hexdocs.pm/nerves/getting-started.html

:tada::tada::tada:
