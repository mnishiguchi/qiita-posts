---
title: ファイルを氣輕に暗号化できるスクリプトを書く
tags:
  - Linux
  - gpg
  - GnuPG
  - password
private: false
updated_at: '2023-12-21T03:14:41+09:00'
id: be589685d8b5cd8154d5
organization_url_name: null
slide: false
ignorePublish: false
---

大事なファイルを扱っている時に何らかの方法で暗号化をすることがあります。
日常氣輕に暗号化できるコマンドがあれば便利かなと思い、シェルスクリプトの勉強も兼ねスクリプトを書いてみました。

https://qiita.com/osw_nuco/items/a5d7173c1e443030875f

## 結論

スクリプトファイルにするほどのものでは無いので、関数としてまとめることにしました。

[GnuPG]を利用して二つの関数（暗号化するための`encrypt()`と復号するための`decrypt()`）を実装しました。

https://qiita.com/tags/gpg

自分用なので、簡単にパスフレーズだけでデータを暗号化できる対称暗号化を採用しました。

https://wiki.archlinux.jp/index.php/GnuPG#暗号化と復号化

これらの関数はいつでもターミナルで呼び出せるよう`.zshrc`ファイルに置くことにしました。[Z Shell]以外のシェルをお使いの方は対応するファイルに読み替えてください。

https://qiita.com/to3izo/items/b6a735793d55d65c5b10

## 暗号化

基本的に[gpg][GnuPG]コマンドは一つのファイルしか暗号化できないようですので、ファイル・ディレクトリを問わず処理できるよう`.tar.gz`の[アーカイブ]に変換してから[gpg][GnuPG]コマンドを呼ぶ方式にしました。


```shell:.zshrc
encrypt() {
  if [ ! -f "$1" ] && [ ! -d "$1" ]; then
    echo "error: invalid file or directory '$1'"
    return 1
  fi

  source="$1"
  archive="${source}.tar.gz"

  # ファイルまたはディレクトリを`.tar.gz`アーカイブに変換
  tar cvzf "$archive" "$source"

  # 作ったアーカイブを暗号化
  # 結果として`.tar.gz.gpg`ファイルが生成される
  gpg --symmetric --cipher-algo aes256 "$archive"

  # アーカイブはもういらないので削除
  rm -rf "$archive"
}
```

## 復号

```shell:.zshrc
decrypt() {
  if [ ! -f "$1" ]; then
    echo "error: invalid file: '$1'"
    return 1
  fi

  source="$1"

  case "$source" in
  *.tar.gz.gpg)
    # `.tar.gz.gpg`ファイルを復号
    gpg --decrypt "$source" | tar xvzf -
    ;;
  *.gpg)
    # ついでに`.tar.gz.gpg`でない`.gpg`ファイルの復号にも対応
    gpg --output "${source%.*}" --decrypt "$source"
    ;;
  *)
    echo "error: don't know how to extract '$source'"
    return 1
    ;;
  esac
}
```

`--output`オプションで出力ファイルを指定しない場合、結果が標準出力に吐き出されるようです。

`"${source%.*}"`は拡張子を取り除く時に使える便利な技です。

## さいごに

実はここでご紹介した実装にたどり着くまで色々迷いがありました。ネット検索すると、暗号化の方法は山ほど出てくるんです。とりあえずひとつ使えるものができたのでひと段落です。

本記事は [闘魂Elixir #60](https://autoracex.connpass.com/event/305753/) の成果です。ありがとうございます。

https://autoracex.connpass.com/

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)


<!-- begin links -->
[GnuPG]: https://wiki.archlinux.jp/index.php/GnuPG
[Z Shell]: https://en.wikipedia.org/wiki/Z_shell
[アーカイブ]: https://ja.wikipedia.org/wiki/%E3%82%A2%E3%83%BC%E3%82%AB%E3%82%A4%E3%83%96_(%E3%82%B3%E3%83%B3%E3%83%94%E3%83%A5%E3%83%BC%E3%82%BF)
<!-- end links -->
