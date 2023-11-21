---
title: Linux US キーボードの CapsLock を Ctrl に変更する方法
tags:
  - Linux
  - Keyboard
  - キーボード設定
  - CapsLock
  - US配列
private: false
updated_at: '2023-11-21T10:11:38+09:00'
id: ea5b5d13a6b2c1bcfaf5
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

Linux マシンの US キーボードの CapsLock を Ctrl に変更する方法を調べました。いろんなやり方があるようです。

![us-keyboard-capslock-1.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/70040d00-43d8-66c0-de0a-4a8115fe212f.png)

## 環境

- OS: Arch Linux x86_64
- ホスト: MacBookAir6,2 1.0
- デスクトップ環境: Xfce 4.18

## いろんな設定方法

- xmodmap
- setxkbmap
- Xorg の設定ファイル
- グラフィカルユーザインターフェース（GUI）

## xmodmap で設定する場合

> xmodmap は Xorg におけるキーマップやマウスボタンのマッピングを変更するためのユーティリティです。-- ArchWiki

https://wiki.archlinux.jp/index.php/Xmodmap

[Xorg] ディスプレイサーバーが起動するときに、`/etc/X11/xinit/xinitrc` が読み込まれます。
読み込まれるものの中に `$HOME/.Xmodmap` という [Xmodmap] の設定ファイルがあります。

>　xmodmap は Xorg におけるキーマップやマウスボタンのマッピングを変更するためのユーティリティです。-- ArchWiki

https://wiki.archlinux.jp/index.php/Xmodmap

最初はないと思うので、`$HOME/.Xmodmap` を作ります。
ArchWiki によると以下の設定で CapsLock を Ctrl に変更できるそうなのでおまじないとして貼り付けます。

```bash:$HOME/.Xmodmap
clear lock
clear control
keycode 66 = Control_L
add control = Control_L Control_R
```

以上！

これで設定が永続化されているはずです。

:tada::tada::tada:

僕のマシンでは `/etc/X11/xinit/xinitrc` の中身はこんな感じでした。
ここで `$HOME/.Xmodmap` が読み込まれることがわかると思います。

```bash:/etc/X11/xinit/xinitrc
#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

twm &
xclock -geometry 50x50-1+1 &
xterm -geometry 80x50+494+51 &
xterm -geometry 80x20+494-0 &
exec xterm -geometry 80x66+0+0 -name login
```

ちなみに `/etc/X11/xinit/xinitrc` は初期設定のままにしておくのが作法のようです。
万一挙動を変更したい場合は、`$HOME/.xinitrc` を作るとこれが代わりに読み込まれるようになるとのことです。

```bash:terminal
cp /etc/X11/xinit/xinitrc ~/.xinitrc
```

https://wiki.archlinux.jp/index.php/Xinit

また、ウィンドウマネージャが開始される前にコマンドを実行したい場合は、`$HOME/.xprofile` ファイルを作りその中で実施します。

https://wiki.archlinux.jp/index.php/Xprofile

[Xorg]: https://wiki.archlinux.jp/index.php/Xorg
[Xmodmap]: https://wiki.archlinux.jp/index.php/Xmodmap
[xprofile]: https://wiki.archlinux.jp/index.php/Xprofile

## setxkbmap で設定する場合

[setxkbmap] は、キーボードレイアウトの設定ができる便利なコマンドです。現在の X セッション限定でキーボードレイアウトを設定します。

以下のコマンドを実行して CapsLock を Ctrl に変更することが可能です。

```bash:terminal
setxkbmap -option ctrl:nocaps
```

いつでも設定変更ができて便利ですが、このコマンドを打つだけでは設定は永続化されません。

https://wiki.archlinux.jp/index.php/Xorg/%E3%82%AD%E3%83%BC%E3%83%9C%E3%83%BC%E3%83%89%E8%A8%AD%E5%AE%9A#setxkbmap_.E3.82.92.E4.BD.BF.E3.81.86

いつでも CapsLock をオンオフできるようにコマンドを用意しておくと便利かもしれません。

```bash:~/.local/bin/capslock
#!/bin/bash

# Usage
#
#    capslock on
#    capslock off
#
[ "$1" == on ] && setxkbmap -option
[ "$1" == off ] && setxkbmap -option ctrl:nocaps
```
:tada::tada::tada:

[setxkbmap]: https://man.archlinux.org/man/setxkbmap.1

## Xorg の設定ファイルで設定する場合

`/etc/X11/xorg.conf` や `/etc/xorg.conf` で [Xorg] を設定することもできます。

https://wiki.archlinux.jp/index.php/Xorg#.E8.A8.AD.E5.AE.9A

僕のマシンでは `/etc/X11/xorg.conf.d/00-keyboard.conf` というファイルがあり、その中にキーボード関連の設定が記述されています。
コメントを読むとこれは自動生成されたものなので、どうも触らないほうがよさそうです。

```bash:/etc/X11/xorg.conf.d/00-keyboard.conf
# Written by systemd-localed(8), read by systemd-localed and Xorg. It's
# probably wise not to edit this file manually. Use localectl(1) to
# instruct systemd-localed to update it.
Section "InputClass"
        Identifier "system-keyboard"
        MatchIsKeyboard "on"
        Option "XkbLayout" "us"
        Option "XkbModel" "pc105+inet"
        Option "XkbOptions" "terminate:ctrl_alt_bksp"
EndSection
```

[localectl] コマンドを使用して [systemd-localed] にキーボード設定を更新するよう指示を出せる仕組みになっているようです。

https://wiki.archlinux.jp/index.php/Xorg/%E3%82%AD%E3%83%BC%E3%83%9C%E3%83%BC%E3%83%89%E8%A8%AD%E5%AE%9A#localectl_%E3%82%92%E4%BD%BF%E3%81%86

[localectl] コマンドでキーボード設定を更新する文法は以下のとおりです。サブコマンドは `set-x11-keymap` で、引数を四つ取ります。

```
localectl set-x11-keymap LAYOUT [MODEL [VARIANT [OPTIONS]]]
```

まずは現在の設定を確認します。Xorg の設定ファイルを直接覗く以外にも確認する方法があります。

```bash:terminalで現在の設定を確認
localectl status

# System Locale: LANG=en_US.UTF-8
#     VC Keymap: us
#    X11 Layout: us
#     X11 Model: pc105+inet
#   X11 Options: terminate:ctrl_alt_bksp
```

```bash:terminalで現在の設定を確認
setxkbmap -print -verbose 10

# Setting verbose level to 10
# locale is C
# Trying to load rules file ./rules/evdev...
# Trying to load rules file /usr/share/X11/xkb/rules/evdev...
# Success.
# Applied rules from evdev:
# rules:      evdev
# model:      pc105+inet
# layout:     us
# options:    terminate:ctrl_alt_bksp
# Trying to build keymap using the following components:
# keycodes:   evdev+aliases(qwerty)
# types:      complete
# compat:     complete
# symbols:    pc+us+inet(evdev)+terminate(ctrl_alt_bksp)
# geometry:   pc(pc104)
# xkb_keymap {
#         xkb_keycodes  { include "evdev+aliases(qwerty)" };
#         xkb_types     { include "complete"      };
#         xkb_compat    { include "complete"      };
#         xkb_symbols   { include "pc+us+inet(evdev)+terminate(ctrl_alt_bksp)" };
#         xkb_geometry  { include "pc(pc104)"     };
# };
```

確認した現在の設定をもとに設定変更をするコマンドを組み立てます。四つの引数をどうするかの問題です。

- LAYOUT
- MODEL
- VARIANT
- OPTIONS

使用可能なパラメータ値は以下のコマンドで確認できます。

```
localectl list-x11-keymap-models
localectl list-x11-keymap-layouts
localectl list-x11-keymap-variants [layout]
localectl list-x11-keymap-options
```

僕の場合はこうなりました。VARIANT は該当しないので空にしています。変更したのは OPTIONS だけです。

```bash:terminalで設定変更をするコマンドを組み立て
sudo localectl set-x11-keymap \
  "us" \
   pc105+inet \
   "" \
   terminate:ctrl_alt_bksp,ctrl:nocaps
```

リブート後に設定が反映され永続化されているはずです。

:tada::tada::tada:

[localectl]: https://man.archlinux.org/man/localectl.1.en
[systemd-localed]: https://man.archlinux.org/man/systemd-localed.8.en

## グラフィカルユーザインターフェース（GUI）

僕の（今使っている）マシンにはないのですが、[Linuxディストリビューション] によっては便利なグラフィカルユーザインターフェース（GUI）が付いてくる場合があります。
例えば、[Linux Mint] ではチェックボックスで簡単にキーボード設定の変更ができます。

![linux-mint-keyboard-layouts-2023-02-24 23-19-40 (1).png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/1aac1fa6-489e-8768-2d5d-31e2b8b78cc8.png)

:tada::tada::tada:

[Linux Mint]: https://ja.wikipedia.org/wiki/Linux_Mint
[Linuxディストリビューション]: https://ja.wikipedia.org/wiki/Linux%E3%83%87%E3%82%A3%E3%82%B9%E3%83%88%E3%83%AA%E3%83%93%E3%83%A5%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3

## さいごに

本記事は [autoracex #257](https://autoracex.connpass.com/event/300536/) の成果です。ありがとうございます。

https://autoracex.connpass.com/

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)
