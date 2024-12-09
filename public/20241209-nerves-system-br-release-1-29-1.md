---
title: Nerves システム最新リリースの概要 (v1.29.1)
tags:
  - Elixir
  - IoT
  - Nerves
private: false
updated_at: '2024-12-09T21:32:43+09:00'
id: ff720c8706b13ce29152
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

## はじめに

Nerves の共同開発者である Frank Hunleth 氏が[Elixir Forum][elixir_forum_post]で最新の Nerves システムリリース（v1.29.1）の情報を共有されていました。

このアップデートには、Erlang/OTP の最新バージョン対応や Buildroot 更新のみならず、他にもいろいろ**エキサイティング**な更新が含まれています。

## 主な更新内容

### Erlang/OTP 27.1.2 へのアップデート

Nerves が最新の [Erlang/OTP 27.1.2][erlang_release] に対応しました。これにより、パフォーマンスと安定性がさらに向上しています。

### Buildroot 2024.08.2 への更新

Buildroot が最新版である [Buildroot 2024.08.2][buildroot_release] にアップデートされました。ツールチェーンやビルドシステムが刷新され、基盤がさらに強化されています。

### 802.11x 向けの PKCS11 サポート追加

ハードウェアセキュリティモジュール（HSM）がサポートされるようになりました。これにより、802.11x 認証におけるセキュリティ機能が強化されています。

### XLA サポートの修正

加速線形代数（XLA）の利用に関する問題が修正されました。この改善により、機械学習関連プロジェクトの取り組みがスムーズになります。

## 「特にエキサイティング」アップデート

> Some of the most exciting updates are in the official Nerves systems, though.

最もエキサイティングなアップデートは、公式の Nerves システムに関連するものです。

### リアルタイム Linux の PREEMPT_RT パッチ

リアルタイム Linux（PREEMPT_RT）パッチが導入されました。このパッチにより、カーネル全体のレイテンシが低減され、リアルタイム I/O 応答時間が向上します。

この機能をフル活用するには、Linux カーネルや Erlang のオプションを使ってリアルタイムコアを割り当てる必要があります。

https://wiki.linuxfoundation.org/realtime/start

### libcamera への移行

Raspberry Pi ユーザーにとって重要なのは、MMAL ベースのカメラドライバから **[libcamera][raspberry_pi_camera]** ベースのものに移行したことです。この変更は、すべての Raspberry Pi システムに影響を与えています。これにより、長年利用されてきた **[picam][picam]** ライブラリが正式に非推奨となりました。

Nerves システムには、[Raspberry Pi libcamera ドキュメント][raspberry_pi_camera] に記載されているサンプルカメラアプリケーションが含まれています。ただし、現時点ではこれらを簡単に活用できる Elixir 向けのラッパーライブラリは存在しません。そのため、libcamera の恩恵を受けつつ、最新のコンピュータビジョンやカメラ技術を取り入れるには、アプリケーション側での工夫が必要です。

## Frank さんからのお願い

Nerves システムのサポート対象プラットフォームやデバイスが非常に多いため、全てを完全に網羅するのは簡単ではありません。以下の点で協力をお願いされています。

1. **使用中の Nerves システムのリリースノートを確認してください！**  
   プロジェクトに影響を与える可能性があるため、各システムの[変更履歴][nerves_system_br_releases]をご覧ください。

2. **フィードバックをお寄せください！**  
   万が一、不具合や回帰が発生した場合は、ぜひ報告をお願いします。Nerves プロジェクトをさらに良いものにするために、フィードバックがとても重要です。

## Frank さんからの感謝

今回のリリースサイクルで Frank さんは、以下のような課題を乗り越えたそうです。

- **Web ブラウザのキオスクモード対応**
- **リアルタイム Linux の導入**
- **機械学習サポートの拡張**
- **初の GCC バグへの対応**

これらの成果は、Nerves ユーザーコミュニティの協力なしでは達成できなかったそうで、関わってくださった全ての方に感謝を伝えたいとのことです。

## おわりに

今回のリリースは、セキュリティやリアルタイム性の強化に加え、最新技術の活用を可能にするアップデートが盛り込まれています。  
詳しくはご自身の目で[Elixir Forum][elixir_forum_post]や公式の[変更履歴][nerves_system_br_releases]をご覧ください。

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)

<!-- begin-reusable-link -->

[elixir_forum_post]: https://elixirforum.com/t/nerves-system-releases/25621/16?u=mnishiguchi  
[erlang_release]: https://erlang.org/download/OTP-27.1.2.README.md  
[buildroot_release]: https://lore.kernel.org/buildroot/871pzex7gn.fsf@dell.be.48ers.dk/T/  
[raspberry_pi_camera]: https://www.raspberrypi.com/documentation/computers/camera_software.html#libcamera  
[nerves_system_br_releases]: https://github.com/nerves-project/nerves_system_br/releases  
[picam]: https://hex.pm/packages/picam  

<!-- end-reusable-link -->
