---
title: ArchLinuxで日本語入力
tags:
  - Linux
  - archLinux
  - 日本語入力
  - キーボード設定
  - fcitx-mozc
private: false
updated_at: '2023-11-21T10:20:19+09:00'
id: 2a1a485a72ff6289b32f
organization_url_name: null
slide: false
ignorePublish: false
---

[ArchLinux] のマシンで日本語入力できるようにします。


## 環境

- OS: Arch Linux x86_64
- ホスト: MacBookAir6,2 1.0
- デスクトップ環境: Xfce 4.18

## TL;DR

- 日本語ロケールを有効にする
- 日本語フォントをインストール
- [fcitx5-im] と [fcitx5-mozc] をインストール　
- `$HOME/.xprofile` で [Fcitx5] を有効にする
- [Fcitx5] の設定で [Mozc] を現在の入力メソッドに追加


## 日本語ロケールを有効にする

ロケール（言語環境）の設定で 日本語ロケールが有効になっている必要があります。

### 現在の設定を確認

現在の設定は以下のコマンドで確認できます。

```shell:terminal
locale -a
```

出力に `ja_JP.utf8` が含まれていていたら OK。日本語ロケールがすでに有効化されているということです。

![locale-a.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/f6443bc8-4c74-9e08-6c5f-ca0ace24f531.gif)

### 日本語ロケールを有効化

日本語ロケールが有効化されていない場合は `/etc/locale.gen` ファイルを開き、 `ja_JP.utf8` をアンコメント（コメントアウトの逆）します。

```diff_shell:/etc/locale.gen
  #...
  #ja_JP.EUC-JP EUC-JP
- #ja_JP.UTF-8 UTF-8
+ ja_JP.UTF-8 UTF-8
  #ka_GE.UTF-8 UTF-8
  #...
```

そしてロケール設定を再生成することで、変更が反映されます。

```shell:terminal
locale-gen
```

## 日本語フォントをインストール

ArchWiki に日本語フォントがいくつか紹介されています。


https://wiki.archlinux.jp/index.php/%E3%83%AD%E3%83%BC%E3%82%AB%E3%83%AA%E3%82%BC%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3


https://wiki.archlinux.org/title/Localization/Japanese


### パッケージを利用する場合

どのフォントがいいのかわからないので、とりあえず [noto-fonts-cjk] を入れてます。

```shell:terminal
sudo pacman -S noto-fonts-cjk
```

### 手動でインストールする場合

フォントファイルが手元にある場合は `/usr/share/fonts` か `$HOME/.local/share/fonts` に入れます。

## fcitx5-im と fcitx5-mozc をインストール　

[入力メソッド]を設定するには、入力メソッドフレームワークと入力メソッドエディター（IME）のインストールが必要なようです。


https://wiki.archlinux.jp/index.php/%E3%82%A4%E3%83%B3%E3%83%97%E3%83%83%E3%83%88%E3%83%A1%E3%82%BD%E3%83%83%E3%83%89


いくつか選択肢があるようですが、僕の環境の場合 [fcitx5-im] と [fcitx5-mozc] をインストールしてうまくいきました。

- [Fcitx5]
  - 軽量の入力メソッドフレームワーク
  - アプリケーションにさまざまなスクリプトの文字を入力するためのインターフェイスを提供
  - アドオンを通じて数多くの言語をサポート
- [Fcitx5-mozc]
  - 日本語入力メソッドモジュール
  - Google日本語入力のオープンソース版

```shell:terminal
sudo pacman -S fcitx5-im fcitx5-mozc
```

## `$HOME/.xprofile` で Fcitx5 を有効にする

```diff_shell:$HOME/.xprofile
+ # Enable Fcitx5
+ # See https://wiki.archlinux.org/title/Localization/Japanese
+ GTK_IM_MODULE=fcitx
+ QT_IM_MODULE=fcitx
+ XMODIFIERS=@im=fcitx
```

## Fcitx 設定で Mozc を現在の入力メソッドに追加

[Fcitx5] の設定ファイルは、`~/.config/fcitx5/` にあります。

設定ファイルを直接編集してもいいのですが、[fcitx5-im] に含まれている [fcitx5-configtool] グラフィカルユーザインターフェース（GUI）が便利です。

![fcitx-config-mozc 2023-11-19 21-11.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/06cd4c02-122f-ce10-54c0-d8fa1a9764b2.gif)

設定ファイルを開いてみましたがよくわかりませんでした。

![fcitx5-config-profile 2023-11-20 19-40-49.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/bfaffb38-fd6c-7600-b4f5-f98d683e2674.png)

## 入力言語の切り替え方法

「Ctrl + Space」を押して言語入力を切り替えます。

![japanese-input-demo 2023-11-20 20-02.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/578334d8-7d73-e7a0-11fd-d629f72a16e0.gif)

:tada::tada::tada:

## さいごに

本記事は [autoracex #257](https://autoracex.connpass.com/event/300536/) の成果です。ありがとうございます。

https://autoracex.connpass.com/

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)

<!-- begin hyperlinks -->
[ArchLinux]: https://wiki.archlinux.jp/index.php/Arch_Linux
[Fcitx5]: https://wiki.archlinux.jp/index.php/Fcitx5
[fcitx5-im]: https://archlinux.org/groups/x86_64/fcitx5-im/
[fcitx5-mozc]: https://archlinux.org/packages/extra/x86_64/fcitx5-mozc
[Mozc]: https://wiki.archlinux.jp/index.php/Mozc
[fcitx5-configtool]: https://archlinux.org/packages/extra/x86_64/fcitx5-configtool/
[入力メソッド]: https://wiki.archlinux.jp/index.php/%E3%82%A4%E3%83%B3%E3%83%97%E3%83%83%E3%83%88%E3%83%A1%E3%82%BD%E3%83%83%E3%83%89
[noto-fonts-cjk]: https://github.com/notofonts/noto-cjk
<!-- end hyperlinks -->
