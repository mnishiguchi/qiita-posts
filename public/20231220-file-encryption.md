---
title: ファイルを氣輕に暗号化できるスクリプトを書く
tags:
  - Linux
  - gpg
  - GnuPG
  - password
private: false
updated_at: '2024-07-24T18:15:09+09:00'
id: be589685d8b5cd8154d5
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

大事なファイルを扱っている時に何らかの方法で暗号化をすることがあります。
日常氣輕に暗号化できるコマンドがあれば便利かなと思い、シェルスクリプトの勉強も兼ねスクリプトを書いてみました。

シェルスクリプトについては @osw_nuco さんの記事に色んな技が網羅されていています。

https://qiita.com/osw_nuco/items/a5d7173c1e443030875f

## やったこと

スクリプトファイルにするほどのものでは無いので、関数としてまとめることにしました。

[GnuPG]を利用して二つの関数（暗号化するための`mkgpg()`と復号するための`ungpg()`）を実装しました。

https://qiita.com/tags/gpg

自分用なので、簡単にパスフレーズだけでデータを暗号化できる対称暗号化を採用しました。

https://wiki.archlinux.jp/index.php/GnuPG#暗号化と復号化

これらの関数はいつでもターミナルで呼び出せるよう`.bashrc`ファイルに置くことにしました。[Bash]以外のシェルをお使いの方は対応するファイルに読み替えてください。

https://qiita.com/to3izo/items/b6a735793d55d65c5b10

## 暗号化

基本的に[gpg][GnuPG]コマンドは一つのファイルしか暗号化できないようですので、ファイル・ディレクトリを問わず処理できるよう`.tar.gz`の[アーカイブ]に変換してから[gpg][GnuPG]コマンドを呼ぶ方式にしました。


```bash:.bashrc
mkgpg() {
  local archive="$1.tar.gz"

  # ファイルまたはディレクトリを`.tar.gz`アーカイブに変換
  tar cvzf "$archive" "$@"

  # 作ったアーカイブを暗号化
  # 結果として`.tar.gz.gpg`ファイルが生成される
  gpg --symmetric --cipher-algo aes256 "$archive"
}
```

## 復号

```bash:.bashrc
ungpg() {
  case "$1" in
  *.tar.gz.gpg)
    # `.tar.gz.gpg`ファイルを復号
    gpg --ungpg "$1" | tar xvzf -
    ;;
  *.gpg)
    # `.tar.gz.gpg`でない`.gpg`ファイルを復号
    gpg --output "${1%.*}" --ungpg "$1"
    ;;
  *)
    echo "error: don't know how to extract '$1'"
    return 1
    ;;
  esac
}
```

`--output`オプションで出力ファイルを指定しない場合、結果が標準出力に吐き出されるようです。

`"${hoge%.*}"`は拡張子を一つだけ取り除く時に使える便利な技です。

## 色んな形式の復号ができるextract()を実装してみる

たくさんの方々がオレオレextract()を実装されているようです。自分のオレオレextract()を育てていこうと思います。

https://wiki.archlinux.org/title/Bash/Functions

一応自分のがありますが、現時点ではあまり使っていません。少しずつ使いながら改善していきます。

```bash:.bashrc
extract() {
  case "$1" in
  *.tar.bz2)    tar xvjf "$1" ;;
  *.tar.gz)     tar xvzf "$1" ;;
  *.bz2)        bunzip2 "$1" ;;
  *.rar)        unrar x "$1" ;;
  *.gz)         gunzip "$1" ;;
  *.tar)        tar xvf "$1" ;;
  *.tbz2)       tar xvjf "$1" ;;
  *.tgz)        tar xvzf "$1" ;;
  *.zip)        unzip "$1" ;;
  *.ZIP)        unzip "$1" ;;
  *.pax)        pax -r <"$1" ;;
  *.pax.Z)      uncompress "$1" —stdout | pax -r ;;
  *.Z)          uncompress "$1" ;;
  *.7z)         7z x "$1" ;;
  *.tar.gz.gpg) gpg --decrypt "$1" | tar xvzf - ;;
  *.gpg)        gpg --output "${1%.*}" --decrypt "$1" ;;
  *)
    echo "extract() doesn't know how to extract '$1'"
    return 1
    ;;
  esac
}
```

## set -x で関数が実行した処理を印字してみる

カスタム関数はしばらく時間が経つと作った本人が忘れてしまうことがあります。
場合によっては、関数を実行して何が走ったのか把握できるよう処理を印字してみるといい氣がします。

```bash:.bashrc
mkgpg() (
  set -x
  local archive="$1.tar.gz"
  tar cvzf "$archive" "$@"
  gpg --symmetric --cipher-algo aes256 "$archive"
)

extract() (
  set -x
  case "$1" in
  *.tar.bz2) tar xvjf "$1" ;;
  *.tar.gz) tar xvzf "$1" ;;
  *.bz2) bunzip2 "$1" ;;
  *.rar) unrar x "$1" ;;
  *.gz) gunzip "$1" ;;
  *.tar) tar xvf "$1" ;;
  *.tbz2) tar xvjf "$1" ;;
  *.tgz) tar xvzf "$1" ;;
  *.zip) unzip "$1" ;;
  *.ZIP) unzip "$1" ;;
  *.pax) pax -r <"$1" ;;
  *.pax.Z) uncompress "$1" —stdout | pax -r ;;
  *.Z) uncompress "$1" ;;
  *.7z) 7z x "$1" ;;
  *.tar.gz.gpg) gpg --decrypt "$1" | tar xvzf - ;;
  *.gpg) gpg --output "${1%.*}" --decrypt "$1" ;;
  *)
    echo "extract() doesn't know how to extract '$1'"
    return 1
    ;;
  esac
)
```

`set -x`が現行のプロセスに影響を与えると嫌なので、子プロセスで処理するようにしました。

## GNUPGHOME

デフォルトのままだと、[GnuPG]は`$HOME/.gnupg`ディレクトリに色んなデータを書き込みます。

個人的に`$HOME`ディレクトリをコンパクトに保ちたいので、極力[XDG Base Directory]を使うことにしています。

https://wiki.archlinux.org/title/XDG_Base_Directory

```bash:.bashrc
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
mkdir -p "$XDG_CACHE_HOME"
mkdir -p "$XDG_CONFIG_HOME"
mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_STATE_HOME"

export GNUPGHOME="$XDG_DATA_HOME/gnupg"
mkdir -p "$GNUPGHOME"
```
## ファイルアクセス権

通常のファイルアクセス権だど、[GnuPG]に怒られます。

```
gpg: WARNING: unsafe permissions on homedir '/home/path/to/user/.gnupg'
```

自分しか読み書きできないようにします。

```bash:.bashrc
chown -R "$(whoami)" "$GNUPGHOME"
chmod 700 "$GNUPGHOME"
chmod 600 "$GNUPGHOME"/*
chmod 700 "$GNUPGHOME"/*.d
```

https://gist.github.com/oseme-techguy/bae2e309c084d93b75a9b25f49718f85?permalink_comment_id=4198726#gistcomment-4198726

## さいごに

実はここでご紹介した実装にたどり着くまで色々迷いがありました。ネット検索すると、暗号化の方法は山ほど出てくるんです。とりあえずひとつ使えるものができたのでひと段落です。

本記事は [闘魂Elixir #60](https://autoracex.connpass.com/event/305753/) の成果です。ありがとうございます。

https://autoracex.connpass.com/

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)

<!-- begin links -->
[GnuPG]: https://wiki.archlinux.jp/index.php/GnuPG
[Bash]: https://www.gnu.org/software/bash/
[アーカイブ]: https://ja.wikipedia.org/wiki/%E3%82%A2%E3%83%BC%E3%82%AB%E3%82%A4%E3%83%96_(%E3%82%B3%E3%83%B3%E3%83%94%E3%83%A5%E3%83%BC%E3%82%BF)
[XDG Base Directory]: https://wiki.archlinux.org/title/XDG_Base_Directory
<!-- end links -->
