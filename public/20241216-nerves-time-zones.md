---
title: 'Nervesでローカルタイムとタイムゾーン管理: NervesTimeZones の活用法'
tags:
  - Elixir
  - timezone
  - IoT
  - Nerves
private: false
updated_at: '2024-12-16T09:35:40+09:00'
id: 6ebfb59b5d285ac7b3c1
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
## はじめに

IoT デバイスや組み込みシステムでタイムゾーンやローカルタイムを管理することは、意外と難しい課題です。
本記事では、[NervesTimeZones] ライブラリを使ってこの課題を解決する方法をご紹介します。

![Screen Shot 2021-12-21 at 12.12.38 PM.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fbd9d5e4-f08d-a9fa-d800-63d3bd5c120d.png)

## タイムゾーンと IoT デバイスの背景

- **UTC とローカルタイムの違い**  
  IoT デバイスでは UTC を基準に運用することが一般的ですが、ユーザーにローカルタイムを表示する必要がある場合も多いです。
- **Nerves プロジェクトでのタイム管理の課題**
  - 組み込みシステムでは[タイムゾーンデータベース]が省かれることが多く、ローカルタイムの取得が困難。
  - Nerves デバイスは RTC（リアルタイムクロック）が搭載されていない場合があり、ネットワーク経由での同期に依存。
- **既存のアプローチ**
  - `/etc/timezone` ファイルの設定や `Timex.Timezone.Local` を使用する方法があるが、設定の煩雑さやサイズの大きさが課題。

## NervesTimeZones が解決する課題

- **軽量で効率的なタイムゾーンデータ管理**
  - 従来の tzdata や tz パッケージと比較してデータベースのサイズを大幅に削減。
  - [タイムゾーンデータベース]から必要な期間のみに絞ったデータを使用。
- **デバイス全体での一貫性あるタイムゾーン設定**
  - Erlang/Elixir のタイムゾーン機能をサポートするだけでなく、非 BEAM プログラムでも同じデータベースを利用可能。
- **設定の永続化と柔軟性**
  - デバイスの再起動後も設定を保持。
  - デフォルトのタイムゾーンやデータ期間を柔軟に変更可能。

## 基本的な使い方

### 1. インストール

`mix.exs` に以下を追加します。

```elixir:mix.exs
def deps do
  [
    {:nerves_time_zones, "~> 0.3.2"}
  ]
end
```

### 2. 初期設定

`config/config.exs`でタイムゾーンの初期値を設定します。何も指定しない場合は`UTC`が使用されます。

```elixir:config/config.exs
config :nerves_time_zones, default_time_zone: "Asia/Tokyo"
```

### 3. タイムゾーンの変更

実行時にタイムゾーンの変更したい場合は、`NervesTimeZones.set_time_zone/1` を使ってタイムゾーンを設定します。

```elixir
# 現在使用されているタイムゾーンを表示
iex> NervesTimeZones.get_time_zone()

# タイムゾーンを変更
iex> NervesTimeZones.set_time_zone("America/New_York")

# タイムゾーンを初期値に戻す
iex> NervesTimeZones.reset_time_zone()
```

[NervesTimeZones] には他にも便利な関数があります。

```elixir
# 使用可能なタイムゾーン名リストを表示
iex> NervesTimeZones.time_zones()
["Africa/Abidjan", "Africa/Accra", "Africa/Addis_Ababa", "Africa/Algiers", ...

# タイムゾーン名が使用可能か確認
iex> NervesTimeZones.valid_time_zone?("Autoracex")
false

iex> NervesTimeZones.valid_time_zone?("Asia/Tokyo")
true

# nerves_time_zonesが使用するタイムゾーン関連の環境変数を表示。
iex> NervesTimeZones.tz_environment()
%{
  "TZ" => "/srv/erlang/lib/nerves_time_zones-0.1.10/priv/zoneinfo/America/New_York",
  "TZDIR" => "/srv/erlang/lib/nerves_time_zones-0.1.10/priv/zoneinfo"
}
```

## 実践例

### ローカルタイムの取得と活用

タイムゾーン設定後、`NaiveDateTime.local_now/0` でローカルタイムを取得できます。

```elixir
iex> DateTime.now("America/New_York")
{:ok, #DateTime<2024-12-16 12:00:00-05:00 EST America/New_York>}
```

### BEAM 外のプログラムでの使用

`System.cmd/3` の `env` オプションでタイムゾーン環境を設定可能です。

```elixir
iex> System.cmd("date", [], env: NervesTimeZones.tz_environment())
{"Mon Dec 16 12:00:00 EST 2024\n", 0}
```

## 他の選択肢との比較

| ライブラリ            | 主な特徴                                                                                          | データサイズ (例)           | 主な使用例                     |
| --------------------- | ------------------------------------------------------------------------------------------------- | --------------------------- | ------------------------------ |
| **`tzdata`**          | - IANA データを内部フォーマット（ETS テーブル）に変換して管理<br>- 自動データ更新機能あり         | ~600 KB (gzip 圧縮: 300 KB) | Web アプリや標準的なアプリ用途 |
| **`tz`**              | - コンパイル済みの BEAM ファイル形式で管理<br>- サイズが小さいが自動更新機能はなし                | ~250 KB (gzip 圧縮: 200 KB) | 軽量さを求める BEAM アプリ用途 |
| **`zoneinfo`**        | - TZif ファイルを直接使用<br>- サイズが最も小さい<br>- 非 BEAM プログラムでも利用可能             | ~16 KB (gzip 圧縮)          | IoT デバイスや組み込みシステム |
| **`NervesTimeZones`** | - `zoneinfo` を基盤に Nerves デバイス向けに最適化<br>- 設定の永続化が可能<br>- 自動更新機能はなし | ~16 KB (zoneinfo に依存)    | Nerves デバイス専用            |

## おわりに

[NervesTimeZones] は、Nerves デバイス上でローカルタイムやタイムゾーンを管理するための効率的で柔軟なソリューションです。ぜひプロジェクトに活用してみてください！

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)

[Nerves]: https://hexdocs.pm/nerves/getting-started.html
[タイムゾーンデータベース]: https://ja.wikipedia.org/wiki/Tz_database
[NervesTimeZones]: https://hexdocs.pm/nerves_time_zones
