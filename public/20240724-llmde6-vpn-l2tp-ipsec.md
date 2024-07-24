---
title: Linux Mint (LMDE6)で L2TP/IPsecを使ったVPNを使う
tags:
  - Linux
  - Debian
  - ipsec
  - l2tp
  - l2tp-ipsec-vpn
private: false
updated_at: '2024-07-24T16:54:47+09:00'
id: e5ccc2c57b1981a5a4ee
organization_url_name: haw
slide: false
ignorePublish: false
---
## はじめに

[Linux Mint (LMDE6)][Linux Mint Debian Edition]で 「[L2TP/IPsec]」プロトコルを使った VPN の設定に挑戦します。

標準では「[PPTP]」と「[OpenVPN]」を使った VPN 接続が可能ですが、パッケージを追加することで「[L2TP/IPsec]」を含む別の方式にも対応できます。

## 環境

- OS: [Linux Mint Debian Edition 6 (Faye)][Linux Mint Debian Edition]
- 言語： English (United States)

## 結論

- [network-manager-l2tp]と[network-manager-l2tp-gnome]をインストール
    ```bash:Terminal
    sudo apt install network-manager-l2tp network-manager-l2tp-gnome
    ```
- [nm-connection-editor]を使って設定
    ```bash:Terminal
    nm-connection-editor
    ```

[ArchWiki - NetworkManager]: https://wiki.archlinux.jp/index.php/NetworkManager
[Debian 12]: https://www.debian.org/releases/bookworm/
[L2TP]: https://ja.wikipedia.org/wiki/Layer_2_Tunneling_Protocol
[L2TP/IPsec]: https://ja.wikipedia.org/wiki/Layer_2_Tunneling_Protocol
[Linux Mint Debian Edition]: https://linuxmint.com/download_lmde.php
[network-manager-l2tp-gnome]: https://packages.debian.org/bookworm/network-manager-l2tp-gnome
[network-manager-l2tp]: https://packages.debian.org/bookworm/network-manager-l2tp
[NetworkManager - VPN support]: https://networkmanager.dev/docs/vpn/
[NetworkManager]: https://networkmanager.dev
[nm-connection-editor]: https://man.archlinux.org/man/nm-connection-editor.1.en
[OpenVPN]: https://ja.wikipedia.org/wiki/OpenVPN
[PPTP]: https://ja.wikipedia.org/wiki/Point_to_Point_Tunneling_Protocol
[Ubuntu 22.04.4 LTS]:https://releases.ubuntu.com/jammy/

## NetworkManager

- ネットワークの設定や接続をできるだけ簡単に自動的に行うことを目的とするプログラム
- [一般的なVPN 接続のサポート][NetworkManager - VPN support]はプラグインにより提供
- [NetworkManager公式ホームページ][NetworkManager]
- [ArchWiki - NetworkManager]

## `nm-connection-editor`

- ネットワーク接続の設定ができるグラフィカルインターフェイス （GUI）
- 二通りの開き方
  - ターミナルから起動
    1. ターミナルで`nm-connection-editor`コマンドを実行
  - Linux Mint メニューから起動
    1. Linux Mint メニューから「Advanced Network Configuration」（「Network」でない）を開く
    
## `network-manager-l2tp`

- IPsec サポートを備えた L2TP 用の VPN プラグインを提供

## `network-manager-l2tp-gnome`

- グラフィカルユーザーインターフェース (GUI) を使用した [L2TP] および [L2TP/IPsec] 接続のサポートを提供

## 論よりRun

### 必要なパッケージをインストール

```bash:Terminal
sudo apt install network-manager-l2tp
sudo apt install network-manager-l2tp-gnome
```

### VPN 接続情報を入力

1. Linux Mint メニューから「Advanced Network Configuration」を開く
1. 「Advanced Network Configuration」ダイアログボックスの左下にある「＋」ボタンを押し、「Layer 2 Tunneling Protocol (L2TP)」を選択
   ![vpn-open-form 2024-07-03 11-54.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/05f43ce6-fee7-1fe6-c9b3-98ba982d17eb.gif)
1. [L2TP/IPsec] で VPN 接続するための設定を入力する（内容はいつでも変更可能）
   ![lmde6-editting-vpn 2024-07-03 12-02-24.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/8976a139-6be2-6af0-b860-7748d5cb93a7.png)

### VPN に接続

後は簡単にVPN接続の入り切りができます。

![lmde6-network-connection 2024-07-23 21-00-05.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/b25513a4-077c-a221-079a-d4882991b6ec.png)

:tada::tada::tada:

## はまったところ

- 通常の「Network」ダイアログボックス上でも VPN 接続情報を入力できるはずなのだが、エラーがでて入力フォームがでてこない

```
Error: unable to load VPN connection editor
```

![lmde-network-vpn-gui-error 2024-07-03 11-25-21.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/8d369c61-f662-3801-3646-6b6756e80e40.png)

## バグ

[ArchWiki](https://wiki.archlinux.jp/index.php/NetworkManager#VPN_%E3%82%B5%E3%83%9D%E3%83%BC%E3%83%88)によると[VPN サポートに関連するバグ](https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/issues?search=VPN&state=opened)は少なくないようです。

## Ubuntu 22.04 LTS

今回は[Debian 12]ベース のOSなので関係ありませんが、[Ubuntu 22.04.4 LTS] のリポジトリにあるパッケージはバージョンが古く、接続が不安定という不具合が含まれているそうです。この不具合は Ubuntu 23.04 以降で修正されたそうです。

以上です。
