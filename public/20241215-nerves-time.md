---
title: 'Nerves: NervesTime で時間管理'
tags:
  - Elixir
  - Nerves
  - RTC
private: false
updated_at: '2024-12-15T18:55:49+09:00'
id: a712c149d16d03d7e0e3
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

## はじめに

組み込みシステムや IoT アプリケーションでは、正確な時間管理が非常に重要です。ログの記録、イベントのスケジュール、データの整合性など、多くのシステム機能が正確なタイムスタンプに依存しています。しかし、リアルタイムクロック (RTC) がないデバイスや、ネットワークにアクセスできない環境では、正しい時刻を維持することが課題となります。

本記事では、Elixir ベースの組み込みシステム向けフレームワーク [Nerves] における時間管理の課題と、それを解決するための強力なツールである [NervesTime] パッケージについて公式 README に基づいて簡単に説明します。

## Nerves とは？

[Nerves] は、IoT や組み込みシステムを効率的に開発できるオープンソースのフレームワークです。
Elixir 言語の堅牢性と Erlang エコシステムの信頼性を活用することで、柔軟でスケーラブルなアプリケーションを簡単に構築できます。

## 時間管理の課題

組み込みシステムでは、RTC がない場合、デバイスが起動するとデフォルトで `1970-01-01 00:00:00 UTC` に設定されます。
この問題に対処する方法として、以下が一般的です。

1. **NTP サーバーを利用**
   - ネットワーク接続がある場合に有効ですが、接続が途切れると同期が取れなくなります。
2. **RTC を追加**
   - 正確な時間管理が可能ですが、追加のハードウェアとバッテリーが必要です。
3. **スクリプトで対応**
   - システムの起動時にスクリプトで時刻を設定しますが、メンテナンスの手間が増えます。

これらの解決策は一長一短であり、特に IoT プロジェクトではコストや実装の複雑さが課題となることがあります。

## NervesTime とは？

[NervesTime] は、Nerves プロジェクト向けに設計された時間管理パッケージで、以下の特徴があります。

- **RTC がなくても時刻を推定可能**: デバイスが最後に使用された時刻を基に、`NervesTime.FileTime` を利用して、`~/.nerves_time` の最終更新時刻を基に現在時刻を推定します。
- **NTP サーバーとの統合**: ネットワーク接続がある場合に自動的に同期を実行します。デフォルトでは [ntp.pool.org](https://www.ntppool.org/) の NTP サーバーが使用されますが、`config.exs` で代替サーバーを指定することも可能です。
- **時間範囲のカスタマイズ**: 指定した時間範囲外のタイムスタンプを防止できます。
- **RTC との統合**: 必要に応じて RTC を使用して精度を向上。

これにより、複雑な時間管理を簡略化し、組み込みシステムに適した信頼性の高いソリューションを提供します。

:::note
[NervesTime] はほとんどの Nerves システムに対応しており、簡単な設定で利用可能です。
:::

## IoT 環境での実用例

[NervesTime] を使用することで、次のようなシナリオで時間管理が簡単になります。また、時間範囲のカスタマイズを行うことで、指定した範囲外のタイムスタンプを防ぎ、RTC やインターネット接続がないデバイスでも信頼性の高い時間管理を実現できます。

- **リモート環境でのデータ収集**: ネットワーク接続がない環境でも、適切なタイムスタンプでデータを記録。
- **断続的なネットワーク接続**: NTP サーバーと自動同期することで、接続時に時刻を修正。
- **RTC 未搭載デバイス**: 最後の使用時刻を基に起動時の時刻を推定。

## NervesTime の導入方法

### インストール

`mix.exs` ファイルに以下を追加してください。

```elixir
def deps do
  [
    {:nerves_time, "~> 0.4.8"}
  ]
end
```

その後、以下のコマンドを実行して依存関係をインストールします。

```bash
mix deps.get
```

### 設定

[NervesTime] を使用するには、`vm.args` ファイルに以下の設定を追加します。
この設定は[Time Warp](https://www.erlang.org/doc/apps/erts/time_correction.html#time-warp-modes)を有効にするために必要です。

```elixir
+C multi_time_warp
```

さらに、プロジェクトの設定ファイル (`config.exs`) に初期化待機時間を指定します。この設定は、アプリケーションが有効な時刻が設定される前に起動するのを防ぐためのものです。

```elixir
config :nerves_time, await_initialization_timeout: :timer.seconds(5)
```

## まとめ

[NervesTime] は、組み込みシステムや IoT プロジェクトにおける時間管理の課題を解決する強力なツールです。その簡潔な設定、柔軟な機能、信頼性の高さから、Nerves プロジェクトにおいて欠かせない存在と言えるでしょう。

興味のある方は[公式ドキュメント][NervesTime]でさらに詳しい情報をチェックしてみてください。

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)

[Nerves]: https://hexdocs.pm/nerves
[NervesTime]: https://hexdocs.pm/nerves_time
