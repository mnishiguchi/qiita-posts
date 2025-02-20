---
title: Debian環境でGhosttyをインストールしてみた
tags:
  - Linux
  - Debian
  - Terminal
  - LMDE6
  - ghostty
private: false
updated_at: '2025-01-24T09:50:37+09:00'
id: 53febfa1644cc6c14840
organization_url_name: haw
slide: false
ignorePublish: false
---

## はじめに

[Ghostty]: https://ghostty.org/
[Alacritty]: https://alacritty.org/
[Linux Mint Debian Edition]: https://linuxmint.com/download_lmde.php
[asdf]: https://asdf-vm.com/
[Zig]: https://ziglang.org/
[tmux]: https://github.com/tmux/tmux/wiki
[Neovim]: https://neovim.io/doc/
[FiraCode Nerd Font]: https://github.com/ryanoasis/nerd-fonts/

最近 **Ghostty** というターミナルエミュレータが注目を集めていることを知り、試してみることにしました。

技術系 YouTube で見聞きしたり、また同僚の「Ghostty いいね」といった感想もあり、自分自身でも体験してみようと思いました。

本執筆時点では公式に Debian 用のバイナリが提供されていないため、ソースコードからビルドする必要がありました。しかしながら、公式ドキュメントに従うことでなんの問題もなく簡単にビルド及びインストールすることができました。

本記事では、[Ghostty]を試した印象や氣づいたことを記録していきます。

---

## 環境

- **OS**: Debian ベースの[LMDE6 (Linux Mint Debian Edition 6)][Linux Mint Debian Edition]

---

## Ghostty の魅力

[Ghostty]は初期設定でも十分に使いやすく、直感的な操作性が特徴と認識しました。
デフォルトの設定を確認したり、ドキュメントを参照するためのコマンドが提供されているのがいいなと思いました。

これらの便利な機能により、初心者でも簡単にカスタマイズができそうな感じです。

```bash
# 現在の設定を列挙
ghostty +show-config

# 初期設定を列挙
ghostty +show-config --default

# 初期設定を説明付きで列挙
ghostty +show-config --default --docs

# ショートカット一覧を表示
ghostty +list-keybinds

# 利用可能なテーマをリストアップ
ghostty +list-themes
```

テーマの選択肢がデフォルトで豊富に用意されているのも大きな魅力のひとつです。
用意されているテーマをリストアップし、簡単に試すことができます。

`ghostty +help` コマンドを使うことで、すべての機能を簡単に把握することができます。`[+action]`の部分が特徴的に感じました。

```bash
$ ghostty +help
Usage: ghostty [+action] [options]

Run the Ghostty terminal emulator or a specific helper action.

If no `+action` is specified, run the Ghostty terminal emulator.
All configuration keys are available as command line options.
To specify a configuration key, use the `--<key>=<value>` syntax
where key and value are the same format you'd put into a configuration
file. For example, `--font-size=12` or `--font-family="Fira Code"`.

To see a list of all available configuration options, please see
the `src/config/Config.zig` file. A future update will allow seeing
the list of configuration options from the command line.

A special command line argument `-e <command>` can be used to run
the specific command inside the terminal emulator. For example,
`ghostty -e top` will run the `top` command inside the terminal.

On macOS, launching the terminal emulator from the CLI is not
supported and only actions are supported.

Available actions:

  +version
  +help
  +list-fonts
  +list-keybinds
  +list-themes
  +list-colors
  +list-actions
  +show-config
  +validate-config
  +crash-report
  +show-face

Specify `+<action> --help` to see the help for a specific action,
where `<action>` is one of actions listed above.
```

---

## 設定方法

[Ghostty]の設定ファイルは、`$HOME/.config/ghostty/config` に保存されています。
また、「`Ctrl` + `,`」のショートカットで直接開くことができます。

https://ghostty.org/docs/config

---

## 私の設定

デフォルトの設定でも十分快適なのですが、いくつか自分の好みに合わせて調整を加えました。

### 主な調整内容

- フォント: [Neovim] で使用している [FiraCode Nerd Font]
- ショートカット: [tmux] や [Neovim] で設定している操作感に合わせて、ページアップ/ダウンのショートカットを調整

以下が私の設定ファイルです：

```toml
# $HOME/.config/ghostty/config
theme = Dracula+
font-size = 10
font-family = FiraCode Nerd Font

keybind = ctrl+shift+up=scroll_page_up
keybind = ctrl+shift+down=scroll_page_down

keybind = ctrl+shift+k=scroll_page_up
keybind = ctrl+shift+j=scroll_page_down
```

---

## Alacritty との比較

これまでターミナルエミュレータとして [Alacritty] を愛用してきました。その理由は、シンプルであること、そして TOML/YAML 形式の設定ファイルを使って
簡単にカスタマイズが可能な点でした。

私がターミナルエミュレータに求めるのは「[tmux] や [Neovim] と組み合わせてシンプルに使えること」です。この観点から、[Alacritty]のシンプルさは非常に魅力的でした。

対して、[Ghostty]を使ってみた印象は、「人間に優しい設計」だということでした。設定やコマンドがわかりやすいのは、誰にとっても良いことだと思います。

---

## Debian 環境での[Ghostty]ビルド

公式ドキュメントに従うことでなんの問題もなく簡単にビルド及びインストールすることができました。

https://ghostty.org/docs/install/binary

https://ghostty.org/docs/install/build

### ビルド手順

以下の手順でソースコードからビルドしました。

#### `zig` をインストール

[Zig] は[asdf] を使って インストールしました。
[Ghostty] の公式ドキュメントによると [Zig] はバージョン 0.13 以上である必要があるそうです。

```bash
asdf plugin add zig
asdf install zig latest
asdf global zig latest

zig version
```

#### 必要な依存関係をインストール

```bash
sudo apt update && sudo apt install libgtk-4-dev libadwaita-1-dev git
```

#### ソースコードをダウンロード

ソースコードの置き場はどこでもいいのですが、設定ファイルのある`$HOME/.config/ghostty/`配下に置く方針にしました。

```bash
$ tree -L 1 $HOME/.config/ghostty
/home/mnishiguchi/.config/ghostty
├── config  # 設定
├── ghostty # ソースコード
└── themes  # テーマ

3 directories, 1 file
```

```bash
git clone https://github.com/ghostty-org/ghostty $HOME/.config/ghostty/ghostty
```

#### Ghostty をビルドしてインストール

基本的にソースコードのあるディレクトリに移動し、`zig build`コマンドを叩くだけですが、`-p`オプションでバイナリの置き場所を指定することがポイントです。

ビルド結果にはバイナリ以外にもいろんなファイル（アイコン、テーマ、デスクトップファイルなど）がついてきます。このオプションを指定することにより、必要なファイルが自動的に適切にコピーされます。便利！

私の場合は、バイナリの置き場所を`$HOME/.local`にしています。

```bash
cd $HOME/.config/ghostty/ghostty
zig build -p $HOME/.local -Doptimize=ReleaseFast
```

#### `.desktop` ファイルを修正

ビルド後、`$HOME/.local/bin/ghostty`は問題なく起動できたものの、デスクトップのアプリケーションメニューからは起動できませんでした。
どうもデスクトップ環境で何かが [Ghostty] をアプリケーションと認識されていないようです。

`.desktop` ファイルは`$HOME/.local/share/applications/com.mitchellh.ghostty.desktop`にありました。

それを手動でリネームしたら解決しました。

```bash
mv $HOME/.local/share/applications/com.mitchellh.ghostty.desktop $HOME/.local/share/applications/Ghostty.desktop
update-desktop-database $HOME/.local/share/applications/
```

---

## カスタムスクリプト

再インストールや最新のソースコードへの更新を簡単に行えるよう、以下のスクリプトを作成しました。

https://github.com/mnishiguchi/installers/blob/a4ca34269bd14592c84a8b7c6c5978ce4a9f38ae/debian/ghostty-install.sh

自分用なのでお使いの場合は適宜中身を変更してください。

---

## おわりに

[Ghostty]は、その直感的なわかりやすい設計が魅力的に思いました。日々の作業がより快適になりそうな予感がします。
これからも[Ghostty]を使い続け、その中で見つけた便利な使い方を追求していきたいと思います

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)
