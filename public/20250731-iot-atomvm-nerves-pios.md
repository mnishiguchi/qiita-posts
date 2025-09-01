---
title: Elixirで始めるIoT開発：AtomVM・Nerves・Raspberry Pi OS
tags:
  - RaspberryPi
  - Elixir
  - Nerves
  - ESP32
  - AtomVM
private: false
updated_at: '2025-08-01T16:21:47+09:00'
id: 69b3c3ddea99fd46705e
organization_url_name: haw
slide: false
ignorePublish: false
---

## はじめに

[Elixir]を使ってIoT開発を行う場合、用途やデバイスに応じて選べるプラットフォームが複数あります。

代表的なのは次の3つです：

- **AtomVM**:
  [ESP32]などの小型マイコン向け。
  極小メモリで動作する軽量な[Erlang VM]実装で、OS無しで直接マイコン上で[Elixir]を実行します。
- **Nerves**:
  Raspberry Piなどの[シングルボードコンピュータ][SBC]向け。
  [Elixir]に特化した組込みLinux環境（Buildrootベースの組み込みLinux）上でBEAMを動かすプラットフォーム。
- **Raspberry Pi OS**:
  汎用Linuxディストリビューション（Debian系）上に[Elixir]をインストールして利用する方法。
  フル機能のOS環境でElixirが動きます。

---

## プラットフォーム比較

|                | **AtomVM**       | **Nerves**                     | **Raspberry Pi OS** |
| -------------- | ---------------- | ------------------------------ | ------------------- |
| 対応デバイス   | ESP32など        | Raspberry Pi など              | Raspberry Pi など   |
| OS             | なし(RTOS)       | Buildrootベースの組み込みLinux | Debian Linux        |
| イメージサイズ | 0.5–4 MB         | 30–60 MB                       | 400 MB 以上         |
| 電池駆動       | ◎ 長期駆動可     | ▲ 常時給電推奨                 | ▲ 常時給電推奨      |
| OTA更新        | ✕ 未対応         | ◎ 標準対応                     | ✕ 未対応            |
| 価格（参考）   | 約 500〜1,000 円 | 約 4,000〜10,000 円            | 約 4,000〜10,000 円 |

- OTA(Over-The-Air)更新: 無線 / ネットワーク経由でファームウェアをアップデートする仕組み。

---

## Elixir/Erlang VMの利点

- 軽量プロセスとメッセージパッシングによる並行処理。数万の並行プロセスを難なく生成可能。
- プリエンプティブなスケジューリングで実行が偏らず、リアルタイム性が求められる処理でも遅延が少ない。
- 共有メモリやロックを使わない安全な並行モデル。スレッド同期不具合と無縁。
- ガーベジコレクションに対応し、メモリ管理の負担が少ない。長時間稼働でもメモリリークしにくい。
- 優れた通信処理やタイマ制御の標準ライブラリ。分散ノード間通信や遅延評価などIoT通信に強い。
- 障害に強い設計（自己復旧）。一部プロセスが異常終了してもシステム全体が落ちにくい。

以上の特徴から、並行センサー処理やリアルタイム制御、高信頼な常時稼働システムに向いており、[Elixir]がIoT開発者にとって魅力的な選択肢となることがわかります。

---

## Nerves

### 特徴

- Linux上でElixirが動作
- SSHでリモート開発・デバッグが可能
- 小型で堅牢なLinuxファームウェアが構築可能

### やってみる

[Nerves Livebookに挑戦](https://gist.github.com/mnishiguchi/b2b6472dad381065da298f2c9db62988)

https://qiita.com/mnishiguchi/items/d2df8cac1f973204b843

https://qiita.com/mnishiguchi/items/f709d6c211cf41078f2f

---

## AtomVM

### 特徴

- 数百KiBのマイコンでElixirが動く
- 起動が高速、リアルタイム制御に向く
- GPIO, SPI, I2C, UARTなどを直接操作可能

### やってみる

[Lチカに挑戦](https://gist.github.com/mnishiguchi/6df85bcc93d62ba449dd430134d24d56)

![atomvm-blinky_0835~3.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/29ca8e53-c0b9-4186-99ef-bc10bb701a02.gif)

![atomvm-blinky 2025-08-01 12-04.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/3804612f-fdd6-482b-b45a-956fc11b374d.gif)

---

## おわりに

Elixirは、幅広いIoTデバイスで活用できます。

- 低コスト・省電力・リアルタイムが必要なら[AtomVM]
- OTA更新やLinuxの機能が必要なら[Nerves]

みんなそれぞれいいですね！
プロジェクトの要件に応じて使い分けましょう。

- [AtomVM公式ドキュメント][AtomVM]
- [Nerves公式サイト][Nerves]

[Nerves]: https://nerves-project.org
[AtomVM]: https://doc.atomvm.org
[Elixir]: https://elixir-lang.org
[Erlang VM]: https://www.google.com/search?q=Erlang+VM%E3%81%A8%E3%81%AF
[ESP32]: https://www.espressif.com/en/products/socs/esp32
[SBC]: https://www.google.com/search?q=%E3%82%B7%E3%83%B3%E3%82%B0%E3%83%AB%E3%83%9C%E3%83%BC%E3%83%89%E3%82%B3%E3%83%B3%E3%83%94%E3%83%A5%E3%83%BC%E3%82%BF%E3%81%A8%E3%81%AF
