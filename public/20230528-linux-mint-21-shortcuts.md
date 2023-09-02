---
title: Linux Mint 21 のショートカット
tags:
  - Linux
  - LinuxMint
  - Linux_Mint
  - Linuxコマンド
private: false
updated_at: '2023-09-03T05:31:17+09:00'
id: 94d3ab813fca051a0e54
organization_url_name: fukuokaex
slide: false
---

## はじめに

古い macbook に [Linux Mint] 21 をインストールして復活させました。まずは操作方法がわからないと話になりません。基本的なショートカットキーを調査しました。

![linux_mint_on_mac](https://user-images.githubusercontent.com/7563926/226134164-83465202-bd6b-4e44-a327-1a4ee27ea543.jpg)

![linux-mint-system-info](https://user-images.githubusercontent.com/7563926/241089029-d3fa01ab-1a56-42f6-86f4-929858145fdf.png)

[Linux Mint]: https://ja.wikipedia.org/wiki/Linux_Mint

## 余談: macOS 風のショートカットキーにカスタマイズ

これは余談なのですが、普段は [macOS] を使っておりまして、Linux を使い始めた当初は [macOS] 風のショートカットキーにカスタマイズした方が便利だろうと思い込んでいました。いろいろ調べたところ [kinto] と言うツールでそれを簡単に実現することができました。

しばらく経ってから、やっぱり郷に入れば郷に従うべきと考えるようになり、元々の [Linux Mint] 初期設定のショートカットキーを学ぶに至りました。

[macOS]: https://ja.wikipedia.org/wiki/MacOS
[kinto]: https://github.com/rbreaves/kinto

## 基本

メニューとターミナルさえ開くことができれば、設定やインストールに取り組めます。

| やりたいこと                 | ショートカット       | 備考                         |
| ---------------------------- | -------------------- | ---------------------------- |
| メニューを開く               | `Super`              |                              |
| デスクトップを表示           | `Super` + `D`        |                              |
| ファイルエクスプローラを開く | `Super` + `E`        |                              |
| ターミナルを開く             | `Ctrl` + `Alt` + `T` |                              |
| 入力言語を切替               | `Ctrl` + `Space`     | [fcitx]                      |
| 右クリック                   | 指 2 本でタップ      | トラックパッドを使用する場合 |

[fcitx]: https://wiki.archlinux.org/title/fcitx

## ウインドウ関連

アプリを使い始めるとウインドウを扱うショートカットが欲しくなると思います。
特にウインドウを閉じる「`Alt` + `F4`」とウインドウを最大化する「`Alt` + `F10`」を便利に感じています。

| やりたいこと                           | ショートカット             | 備考 |
| -------------------------------------- | -------------------------- | ---- |
| ウインドウを画面の縁に合わせて整列     | `Super` + `↑` `↓` `←` `→`  |      |
| ウインドウ番号でウインドウをフォーカス | `Super` + `1`,`2`,`3`, ... |      |
| 別のウインドウへ移動                   | `Alt` + `Tab`              |      |
| ウインドウのメニューを開く             | `Alt` + `Space`            |      |
| ウインドウを閉じる                     | `Alt` + `F4`               |      |
| ウインドウを上下左右に移動             | `Alt` + `F7`               |      |
| ウィンドウサイズを変更                 | `Alt` + `F8`               |      |
| ウインドウを最大化                     | `Alt` + `F10`              |      |

## ワークスペース関連

仕事の量が増えてくるとワークスペース関連のショートカットが重宝するかもしれません。

| やりたいこと                                             | ショートカット                     | 備考 |
| -------------------------------------------------------- | ---------------------------------- | ---- |
| ワークスペースを切替                                     | `Ctrl` + `Alt` + `←` `→`           |      |
| ウインドウを別のワークスペースへ移動す                   | `Ctrl` + `Shift` + `Alt` + `←` `→` |      |
| 現在開いている全アプリを表示（全てのワークスペース）     | `Ctrl` + `Alt` + `↑`               |      |
| 現在開いている全アプリを表示（現在のワークスペースのみ） | `Ctrl` + `Alt` + `↓`               |      |

## アプリ関連

一般的にこれらのショートカットを備えたアプリが多いそうです。

| やりたいこと | ショートカット | 備考 |
| ------------ | -------------- | ---- |
| New          | `Ctrl` + `N`   |      |
| Cut          | `Ctrl` + `X`   |      |
| Copy         | `Ctrl` + `C`   |      |
| Paste        | `Ctrl` + `V`   |      |
| Undo         | `Ctrl` + `Z`   |      |
| Save         | `Ctrl` + `S`   |      |
| Quit         | `Ctrl` + `Q`   |      |

## ターミナル関連

ターミナルではコピーやペーストをやるときに `Shift` を押す必要があります。最初これに戸惑いました。

| やりたいこと | ショートカット         | 備考 |
| ------------ | ---------------------- | ---- |
| Cut          | `Ctrl` + `Shift` + `X` |      |
| Copy         | `Ctrl` + `Shift` + `C` |      |
| Paste        | `Ctrl` + `Shift` + `V` |      |

## カスタムショートカット

調査をしていて思ったことは、Linux のショートカットについてまとめた資料があまりないことです。なぜかわかりました。Linux 使いの方々はデスクトップ環境を自由に変更する人が多いため一般化するのが難しいまたは無意味なのだと思います。

自由には責任が伴います。自分なりの方針を決定し、自分なりのデスクトップ環境を整えていきます。

| やりたいこと       | 俺俺ショートカット | 備考 |
| ------------------ | ------------------ | ---- |
| ターミナルを開く   | `Super` + `Enter`  |      |
| ウインドウを閉じる | `Super` + `W`      |      |

## さいごに

あとは慣れです。慣れます。

## モクモク會

本記事は以下のモクモク會での成果です。みなさんから刺激と元氣をいただき、ありがとうございました。

https://youtu.be/c0LP23SM7BU

https://okazakirin-beam.connpass.com/

https://autoracex.connpass.com

もしご興味のある方はお氣輕にご參加ください。

https://qiita.com/piacerex/items/09876caa1e17169ec5e1

https://speakerdeck.com/elijo/elixirkomiyunitei-falsebu-kifang-guo-nei-onrainbian

https://qiita.com/torifukukaiou/items/57a40119c9eefd056cae

https://qiita.com/piacerex/items/e0b6e46b1325bb931122

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

https://qiita.com/piacerex/items/e5590fa287d3c89eeebf

https://qiita.com/torifukukaiou/items/4481f7884a20ab4b1bea

https://note.com/awesomey/n/n4d8c355bc8f7

![](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/dc1ddba7-ab4c-5e20-1331-143c842be143.jpeg)
