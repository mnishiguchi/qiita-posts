---
title: Elixir と Nerves で実現する音の世界：Joseph Stewart 氏のシンセサイザープロジェクト
tags:
  - Elixir
  - MIDI
  - IoT
  - ALSA
  - Nerves
private: false
updated_at: '2024-12-13T21:43:43+09:00'
id: fa47c20a44fdbb9e3311
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
## はじめに

2024年11月、[Nerves Meetup] で Joseph Stewart 氏が *"Beeps and Ports: Creating an Audio Synthesizer with Elixir and Nerves"* という発表を行いました。この発表では、[Elixir] と [Nerves] を活用してハードウェアと統合し、ユニークなオーディオ体験を作り上げるまでのプロセスが語られました。その内容は技術的な新しさだけでなく、創造性と遊び心にあふれ、Nerves コミュニティに新たな刺激を与えました。

発表内容を見逃してしまった方でも、[発表の録画](https://youtu.be/M6vbVjR9KEU)が公開されているので安心です。

この記事では、発表内容の概要とその魅力、さらに今後の計画について詳しくご紹介します。

## Nerves Meetup での発表内容

Joseph さんは、サウンドとハードウェアに関する独創的な実験の過程を共有しました。主なポイントは以下の通りです：

- **ALSA Port Driver**: C 言語で ALSA ポートドライバを開発し、Elixir プログラムから直接オーディオを再生可能に。
- **オープンソースのサウンドライブラリの探索**: 最適なオーディオ生成ソリューションを見つけるために複数のライブラリを試行。
- **Erlang タームのエンコーダ/デコーダ**: Elixir と ALSA ドライバ間の効率的な通信を実現するためにカスタムエンコーダとデコーダを開発。
- **MIDI ハードウェアの復活**: 自作の MIDI アダプタを復元し、Rock Band 3 のキータ (音楽ゲーム『Rock Band』で使用されるシンセサイザー型のゲームコントローラー) に接続することで古いハードウェアを再利用。
- **無限の正弦波**: 実験中に発生した正弦波により、家族を少々困らせるというユーモラスなエピソードも披露。

録画はこちらから視聴できます：

<iframe width="560" height="315" src="https://www.youtube.com/embed/M6vbVjR9KEU?si=DIpj8WnsNJiAL2YC" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

## なぜこのプロジェクトが注目されるのか

このプロジェクトは、技術的に優れているだけでなく、以下の点で非常に魅力的です：

1. **Elixir と Nerves の創造的な活用**: オーディオ合成やハードウェア統合といった分野で Elixir と Nerves の新たな可能性を示しました。
2. **ハードウェアの再利用**: MIDI アダプタと Rock Band 3 のキータ を接続し、古いガジェットの新しい使い道を提示。
3. **コミュニティの活性化**: オーディオ工学のようなニッチな分野を探求するきっかけを提供し、創造性と技術の融合を促進しました。

## 簡単な技術的解説

Joseph さんのプロジェクトでは、以下の技術的な課題が含まれています：

- **ALSA ポートドライバの作成**: C 言語で開発されたこのドライバは、Linux の強力なサウンドフレームワーク ALSA を介して Elixir プログラムからオーディオ波形を再生可能にします。
- **Erlang タームのエンコーディング/デコーディング**: ポートドライバと Elixir プロセス間のデータ転送を効率化するためにカスタムエンコーダ/デコーダを実装。
- **MIDI 統合**: 自作の MIDI アダプタを用いて Rock Band 3 のキータに接続し、新しいインターフェースを実現。

これらの取り組みは、Elixir と Nerves の可能性が IoT の枠を超え、新たな創造の領域へと広がることを示しています。

## Joseph さんの今後の計画

Meetup 後、Joseph さんは Nerves Slack で次のようなアップデートや計画を共有しました。

まず、彼はシンセエンジンのデモを公開しました。このデモでは、発表で触れた内容をより具体的に示しています。デモ動画は以下のリンクから視聴できます：

<iframe width="560" height="315" src="https://www.youtube.com/embed/7-JvqZe65Xk?si=SzgkiantSD2HDP7E" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

また、彼は **MIDI USB ガジェットモード**や **USB シリアル/UART ガジェットモード** を Raspberry Pi Zero で Nerves と共に使用する可能性についても模索しています。この機能を活用すれば、さらなるデバイス統合が期待できます。

さらに、彼は _"Build a MIDI Synthesizer with Elixir and Nerves"_ というタイトルの短い技術書の執筆を検討中です。この書籍は、他のニッチな技術ガイドのように、開発者に音声合成やハードウェア統合への挑戦を促すことを目的としています。

## おわりに

Joseph さんのプロジェクトは、Nerves と Elixir コミュニティの魅力をよく表しています。革新や協力の大切さ、そして創造的な刺激を与える取り組みです。Elixir と Nerves の可能性を広げることで、新しい応用分野を切り開き、コミュニティに新たな活力をもたらしました。

このプロジェクトは、創造性と技術が交わることで、どんな可能性が広がるのかを私たちに教えてくれます。ベテランの開発者から初心者まで、多くの人に新しい挑戦と発見の楽しさを伝えています。

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)


<!-- begin links -->
[Nerves Meetup]: https://www.meetup.com/nerves/
[asdf installation]: https://asdf-vm.com/guide/getting-started.html#_3-install-asdf
[asdf plugins]: https://asdf-vm.com/manage/plugins.html
[asdf]: https://asdf-vm.com/
[bash]: https://ja.wikipedia.org/wiki/Bash
[BeagleBone]: https://www.beagleboard.org/boards/beaglebone-black
[Buildroot]: https://buildroot.org/
[Debian]: https://ja.wikipedia.org/wiki/Debian
[Elixir]: https://ja.wikipedia.org/wiki/Elixir_(プログラミング言語)
[Erlang versions]: https://github.com/erlang/otp/tags
[Erlang VM]: https://en.wikipedia.org/wiki/BEAM_(Erlang_virtual_machine)
[Erlang]: https://ja.wikipedia.org/wiki/Erlang
[Erlang]: https://www.erlang.org/
[Ethernet]: https://ja.wikipedia.org/wiki/Ethernet
[fwup]: https://github.com/fwup-home/fwup
[Gadget Mode]: http://www.linux-usb.org/gadget/
[hex]: https://github.com/hexpm/hex
[hex]: https://hex.pm/
[IEx]: https://elixirschool.com/ja/lessons/basics/basics#%E5%AF%BE%E8%A9%B1%E3%83%A2%E3%83%BC%E3%83%89-2
[LAN ケーブル]: https://search.brave.com/images?q=LAN%E3%82%B1%E3%83%BC%E3%83%96%E3%83%AB&source=web
[Linux]: https://ja.wikipedia.org/wiki/Linux
[Livebook]: https://livebook.dev/
[microSD カード]: https://ja.wikipedia.org/wiki/SD%E3%83%A1%E3%83%A2%E3%83%AA%E3%83%BC%E3%82%AB%E3%83%BC%E3%83%89
[Mix]: https://hexdocs.pm/mix/Mix.html
[Nerves Livebook]: https://github.com/nerves-livebook/nerves_livebook
[Nerves Systems Builder]: https://github.com/nerves-project/nerves_systems
[nerves systems compatibility]: https://hexdocs.pm/nerves/systems.html#compatibility
[Nerves Target]: https://hexdocs.pm/nerves/supported-targets.html
[nerves_bootstrap]: https://github.com/nerves-project/nerves_bootstrap
[nerves_bootstrap]: https://github.com/nerves-project/nerves_bootstrap
[nerves_system_br]: https://github.com/nerves-project/nerves_system_br
[nerves_system_rp4]: https://github.com/nerves-project/nerves_system_rpi4
[nerves_systems]: https://github.com/nerves-project/nerves_systems
[nerves]: https://github.com/nerves-project/nerves
[Nerves]: https://github.com/nerves-project/nerves
[Phoenix]: https://www.phoenixframework.org/
[PowerShell]: https://learn.microsoft.com/en-us/powershell/
[Raspberry Pi 4]: https://www.raspberrypi.com/products/raspberry-pi-4-model-b/
[Raspberry Pi 5]: https://www.raspberrypi.com/products/raspberry-pi-5/
[Raspberry Pi Zero WH]: https://www.switch-science.com/products/3646
[Raspberry Pi Zero]: https://www.raspberrypi.com/products/raspberry-pi-zero/
[Raspberry Pi]: https://www.raspberrypi.com/
[rebar]: https://github.com/erlang/rebar3
[rebar]: https://github.com/erlang/rebar3
[rebar3]: https://github.com/erlang/rebar3
[SD カードリーダー]: https://search.brave.com/images?q=SD+%E3%82%AB%E3%83%BC%E3%83%89%E3%83%AA%E3%83%BC%E3%83%80%E3%83%BC
[SDカード]: https://ja.wikipedia.org/wiki/SD%E3%83%A1%E3%83%A2%E3%83%AA%E3%83%BC%E3%82%AB%E3%83%BC%E3%83%89
[SFTP]: https://ja.wikipedia.org/wiki/SSH_File_Transfer_Protocol
[SquashFS]: https://ja.wikipedia.org/wiki/SquashFS
[systemd]: https://wiki.archlinux.jp/index.php/Systemd
[UART]: https://ja.wikipedia.org/wiki/UART
[Ubuntu]: https://ubuntu.com/
[USB On-The-Go]: https://ja.wikipedia.org/wiki/USB_On-The-Go
[USB to TTL シリアルケーブル]: https://search.brave.com/images?q=USB%20to%20TTL%20%E3%82%B7%E3%83%AA%E3%82%A2%E3%83%AB%E3%82%B1%E3%83%BC%E3%83%96%E3%83%AB
[USB WiFi ドングル]: https://search.brave.com/images?q=+USB+WiFi+%E3%83%89%E3%83%B3%E3%82%B0%E3%83%AB&source=web
[USB ガジェットモード]: http://www.linux-usb.org/gadget/
[USB ケーブル]: https://search.brave.com/images?q=USB+cable+for+Raspberry+Pi&source=web
[USB]: https://ja.wikipedia.org/wiki/%E3%83%A6%E3%83%8B%E3%83%90%E3%83%BC%E3%82%B5%E3%83%AB%E3%83%BB%E3%82%B7%E3%83%AA%E3%82%A2%E3%83%AB%E3%83%BB%E3%83%90%E3%82%B9
[アーカイブ]: https://ja.wikipedia.org/wiki/アーカイブ_(コンピュータ)
[イーサネット]: https://ja.wikipedia.org/wiki/Ethernet
[インクリメンタルビルド]: https://ja.wikipedia.org/wiki/ビルド_(ソフトウェア)
[オープンソース]: https://ja.wikipedia.org/wiki/%E3%82%AA%E3%83%BC%E3%83%97%E3%83%B3%E3%82%BD%E3%83%BC%E3%82%B9
[クロスコンパイラ]: https://ja.wikipedia.org/wiki/%E3%82%AF%E3%83%AD%E3%82%B9%E3%82%B3%E3%83%B3%E3%83%91%E3%82%A4%E3%83%A9
[シェル]: https://ja.wikipedia.org/wiki/シェル
[シリアル通信]: https://ja.wikipedia.org/wiki/シリアル通信
[ブートローダ]: https://wiki.archlinux.jp/index.php/Arch_%E3%83%96%E3%83%BC%E3%83%88%E3%83%97%E3%83%AD%E3%82%BB%E3%82%B9
[ファームウェア]: https://ja.wikipedia.org/wiki/%E3%83%95%E3%82%A1%E3%83%BC%E3%83%A0%E3%82%A6%E3%82%A7%E3%82%A2
[仮想機械]: https://ja.wikipedia.org/wiki/仮想機械
[対象ボード]: https://hexdocs.pm/nerves/targets.html
[無線 LAN]: https://ja.wikipedia.org/wiki/%E7%84%A1%E7%B7%9ALAN
[組み込みシステム]: https://ja.wikipedia.org/wiki/%E7%B5%84%E3%81%BF%E8%BE%BC%E3%81%BF%E3%82%B7%E3%82%B9%E3%83%86%E3%83%A0
[シリアルコンソール]: https://wiki.archlinux.jp/index.php/%E3%82%B7%E3%83%AA%E3%82%A2%E3%83%AB%E3%82%B3%E3%83%B3%E3%82%BD%E3%83%BC%E3%83%AB
[Adafruit USB to TTL Serial Cable]: https://www.adafruit.com/product/954

<!-- end links -->
