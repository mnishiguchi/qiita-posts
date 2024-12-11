---
title: 'カスタム Nerves: デバイスドライバを特定する方法'
tags:
  - Linux
  - Elixir
  - IoT
  - Nerves
  - USBカメラ
private: false
updated_at: '2024-12-11T18:25:48+09:00'
id: 0d26a09ecd3e3f02f411
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
## はじめに

Linux 環境や組み込みシステムで特定のデバイスを使用するには、そのデバイスに対応したドライバを見つけて設定する必要があります。本記事では、USB カメラのドライバを特定する際に調査した内容をまとめます。

### Raspberry Pi OS のセットアップ

USB カメラは、Raspberry Pi カメラモジュールの代替手段となることがありますが、現時点では USB カメラは Nerves システムでネイティブサポートされていません。Nerves に統合する前に、Raspberry Pi OS 上で USB カメラをテストすることが重要となります。

Raspberry Pi OS のセットアップ方法については、以下の公式リソースを参照してください。

- [Official Raspberry Pi Imager Documentation](https://www.raspberrypi.com/software/)
- [Installing Raspberry Pi OS on Your Raspberry Pi](https://www.raspberrypi.com/documentation/computers/getting-started.html)
- [How to Flash Raspberry Pi OS Using Raspberry Pi Imager](https://projects.raspberrypi.org/en/projects/raspberry-pi-setting-up)

これらのガイドは、Raspberry Pi OS のシステムを構築し、USB カメラのテスト環境を準備するのに役立ちます。

## デバイスドライバを特定する手順

以下の手順では、USB カメラを例に取り、Linux システムで必要なドライバを特定する方法を紹介します。この手法は、Nerves システムのカスタマイズやその他のデバイスにも役立ちます。

### 1. システムの現在の状態を確認

デバイス接続前のシステム状態を記録します。これにより、後でどのドライバがロードされたかを簡単に確認できます。

まず、端末を開き、以下のコマンドを実行してください。

```bash
lsmod > before.txt
```

このコマンドにより、現在ロードされているカーネルモジュールのリストが `before.txt` ファイルに保存されます。

`lsmod` コマンドは、システムで動作しているモジュールを一覧表示するためのものです。これにより、後の手順で比較が可能になります。

### 2. デバイスを接続

USB デバイスを接続し、システムが正しく認識するかを確認します。

まず、USB ポートにデバイスを接続します。接続が確実に行われていることを確認してください。

デバイスを接続した後、以下のコマンドを実行して接続を確認します。

```bash
lsusb
```

このコマンドは、システムに接続されている USB デバイスの一覧を表示します。以下は出力例です。

```
Bus 001 Device 003: ID 056e:701a Elecom Co., Ltd ELECOM 2MP Webcam
```

ここで、`056e` は Vendor ID を、`701a` は Product ID を表します。これらの情報がデバイスを特定するための鍵となります。

もしデバイスが認識されない場合は、別の USB ポートに接続してみてください。また、以下のコマンドでシステムログを確認することも有効です。

```bash
dmesg | tail
```

別の PC に接続して動作確認を行うことで、ハードウェアの不具合かどうかを切り分けることも可能です。

### 3. ドライバの検索

取得した Vendor ID と Product ID を使用して、適切なドライバを調べます。検索エンジンを利用して、以下のようにキーワードを工夫しながら調べてみてください。

- デバイス名と「Linux ドライバ」を組み合わせて検索
- Vendor ID と Product ID に加えて「UVC」や「カーネルモジュール」といったキーワードを加えて検索

:::note
USB カメラに関しては、大抵の場合 **UVC (USB Video Class)** 規格に準拠しており、`uvcvideo` ドライバを使用します。
[UVC 準拠デバイス一覧](https://www.ideasonboard.org/uvc/) というものがありますが、すべてのデバイスが掲載されているわけではないようです。実際、多くの現代の USB ウェブカメラは、リストに記載されていなくても UVC 準拠であると言われています。
:::

https://qiita.com/mnishiguchi/items/ebef421efbd8d0d54fd3

### 4. ドライバのロード確認

該当するドライバがロードされているか確認します。以下のコマンドを実行してください。

```bash
lsmod | grep uvcvideo
```

:::note
該当するモジュールがリストに含まれていない場合は、手動でロードする必要があります。以下のコマンドでロードを行います。

```bash
sudo modprobe uvcvideo
```
:::

### 5. システム状態の比較

接続後のシステム状態を記録し、接続前の状態と比較します。

デバイスを接続した状態で以下のコマンドを実行し、現在の状態を保存します。

```bash
lsmod > after.txt
```

接続前の `before.txt` ファイルと比較します。

```bash
diff before.txt after.txt
```

以下は出力例です。

```
> uvcvideo            98304  0
```

この出力から、新たに `uvcvideo` モジュールがロードされたことがわかります。

## Nerves システムへの応用

この手法は、[Nerves](https://www.nerves-project.org/) システムをカスタマイズして特定のデバイスを動作させる際に非常に有用です。詳細は [Nerves のカスタマイズガイド](https://hexdocs.pm/nerves/customizing-systems.html) をご覧ください。

## まとめ

本記事では、Linux 環境でデバイスに必要なドライバを特定する手順を解説しました。この方法は、Nerves システムを含むさまざまな環境で応用可能です。

何か氣づいた点や改善提案があれば、コメントで共有していただけると嬉しいです。

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)
