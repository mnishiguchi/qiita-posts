---
title: Elixir Nerves で 無線LAN (Wi-Fi）を設定する
tags:
  - Network
  - WiFi
  - 初心者
  - Elixir
  - Nerves
private: false
updated_at: '2023-12-12T08:33:59+09:00'
id: 9d7ed9f674423be26598
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

## はじめに

[Nerves 対象デバイス][対象デバイス]（[Raspberry Pi] や [Beaglebone]等）で [DHCP] を設定して無線LAN (Wi-Fi) でインターネット接続する方法をまとめます。

https://qiita.com/tags/nerves

https://qiita.com/torifukukaiou/items/21df3c512308832c4a15

https://qiita.com/torifukukaiou/items/173a6d86d7a15649c5b5

https://qiita.com/nishiuchikazuma/items/1341b32c4ce997fc362d

https://qiita.com/nishiuchikazuma/items/01f5df5472ec0feceb5f

https://curiosum.com/blog/how-program-iot-device-elixir-using-nerves#connecting-the-device-to-the-wifi

https://youtu.be/Yu1ITcTfvHY?si=mclgn1iELMvEd3S7

[Raspberry Pi]: https://www.raspberrypi.org/
[Beaglebone]: https://www.beagleboard.org/

## やりかた

やり方はいくつかあります。

- コンパイル時
  - ネットワーク設定をファームウエアと一緒に microSD カードに焼く
- 実行時
  - 対象 Nervesマシンが実行中に有線 (Ethernet、シリアルコンソール等) で接続してネットワーク設定をする
- NervesLivebook
  - NervesLivebook 限定の裏技

基本的なネットワーク設定は [VintageNet Cookbook] で解説されています。

https://hexdocs.pm/vintage_net/cookbook.html#wifi

[VintageNet Cookbook]: https://hexdocs.pm/vintage_net/cookbook.html

## 環境

- Elixir: 1.15.4-otp-26
- Nerves: 1.10.3

## nerves_pack

[Nerves の公式サンプルプロジェクト](https://github.com/nerves-project/nerves#example-projects)や [Nerves Getting Started ドキュメント](https://hexdocs.pm/nerves/getting-started.html)に沿って新規作成された [Nerves] プロジェクトには、`mix.exs` の依存パッケージリストに [nerves_pack] が含まれていると思います。

https://github.com/nerves-project/nerves_bootstrap/blob/494c050731f9a6bcc698446cfed4d8907401223a/templates/new/mix.exs#L47

https://qiita.com/torifukukaiou/items/1fcf2458dc8fb23404cf

[nerves_pack] は最小限の作業で Nerves プロジェクトを立ち上げて実行するための依存関係とデフォルト設定をまとめたものです。ネットワーク関連のパッケージ（[vintage_net] 等）もそこに含まれています。

https://github.com/nerves-project/nerves_pack/blob/7692aefe00a653dc2242e08a9985fe2e606f66e3/mix.exs#L39

[nerves_pack]: https://github.com/nerves-project/nerves_pack
[vintage_net]: https://hex.pm/packages/vintage_net

## inets

インターネット接続するには [inets](https://www.erlang.org/doc/man/inets.html) と [ssl](https://www.erlang.org/doc/man/ssl) をあらかじめ `mix.exs` の `:extra_applications` に追加しておく必要があります。

インターネットに接続しない場合は無視してください。

```diff_elixir:mix.exs
   def application do
     [
       mod: {HelloNerves.Application, []},
-      extra_applications: [:logger, :runtime_tools]
+      extra_applications: [:logger, :runtime_tools, :inets, :ssl]
     ]
   end
```

以下のエラーを見たらこのことを思い出してください。

```elixir:対象デバイスのIEx
iex(1)> weather
** (RuntimeError) :ssl can't be started.
This probably means that it isn't in the OTP release.
To fix, edit your mix.exs and add :ssl to the :extra_applications list.

    (toolshed 0.3.1) lib/toolshed.ex:100: Toolshed.check_app/1
    (toolshed 0.3.1) lib/toolshed.ex:12: Toolshed.weather/0
    iex:1: (file)
```

```elixir:対象デバイスのIEx
iex(1)> weather
** (RuntimeError) :inets can't be started.
This probably means that it isn't in the OTP release.
To fix, edit your mix.exs and add :inets to the :extra_applications list.

    (toolshed 0.3.1) lib/toolshed.ex:100: Toolshed.check_app/1
    (toolshed 0.3.1) lib/toolshed.ex:11: Toolshed.weather/0
    iex:1: (file)
```

## コンパイル時に設定

お手元の Nerves プロジェクトの `config/target.exs` を開き、以下の設定を追加します。

```elixir:target.exs
ssid = System.get_env("NERVES_WIFI_SSID") ||
  raise("environment variable WIFI_SSID is missing")

psk = System.get_env("NERVES_WIFI_PASSPHRASE") ||
  raise("environment variable NERVES_WIFI_PASSPHRASE is missing")

config :vintage_net,
  regulatory_domain: "JP", # Japan: JP, US: US, Global: 00, etc
  config: [
    {"usb0", %{type: VintageNetDirect}},
    {"eth0",
     %{
       type: VintageNetEthernet,
       ipv4: %{method: :dhcp}
     }},
    # Wi-Fi の 設定
    {"wlan0",
     %{
       type: VintageNetWiFi,
       vintage_net_wifi: %{
         networks: [
           %{
             key_mgmt: :wpa_psk,
             ssid: ssid, # Wi-Fi の ID　ー　直書き、もしくは環境変数で渡す
             psk: psk # Wi-Fi の パスワード　ー　直書き、もしくは環境変数で渡す
           }
         ]
       },
       ipv4: %{method: :dhcp} # DHCP（IP アドレス等を自動的に割り当て）
     }}
  ]
```

`regulatory_domain` は使用される国に応じて設定する必要があるようです。よくわかりません。

https://wireless.wiki.kernel.org/en/developers/regulatory/wireless-regdb

https://git.kernel.org/pub/scm/linux/kernel/git/wens/wireless-regdb.git/tree/db.txt?id=HEAD#n947

もちろん [DHCP] の代わりに、固定 IP アドレスの設定をすることも可能です。

https://qiita.com/torifukukaiou/items/45cfc7bdf73f3f232299

## 実行時に設定

[VintageNet.configure/3]、もしくは [VintageNetWiFi.quick_configure/2] を使うと、対象デバイスが動作中に Wi-Fi の設定を行うことができます。特に [VintageNetWiFi.quick_configure/2] が便利です。

```elixir:対象デバイスのIEx
VintageNetWiFi.quick_configure("access_point", "passphrase")
```

このときに設定された内容は永続化されますので、デバイスを再起動しても設定された内容は保持されます。

エンタープライズネットワーク上にある場合、固定 IP アドレスを使用している場合、またはその他の特殊な処理が必要な場合は、[VintageNet.configure/3] を呼び出す必要があります。詳しくは [VintageNet Cookbook] をご覧ください。

ネットワーク設定を消去したい場合は、[VintageNet.deconfigure/2] を使います。

```elixir:対象デバイスのIEx
VintageNet.deconfigure("wlan0")
```

対象デバイスにまだ Wi-Fi の設定がされていない場合は当然 Wi-Fi がまだ使えませんので、Ethernet やシリアルコンソールで接続する必要があります。

https://qiita.com/mnishiguchi/items/dddbac0262bcff4dca23

[VintageNet.configure/3]: https://hexdocs.pm/vintage_net/VintageNet.html#configure/3
[VintageNetWiFi.quick_configure/2]: https://hexdocs.pm/vintage_net_wifi/VintageNetWiFi.html#quick_configure/2
[VintageNet.deconfigure/2]: https://hexdocs.pm/vintage_net/VintageNet.html#deconfigure/2

## NervesLivebook から設定

[Nerves Livebook ファームウェア][nerves_livebook]を使用すると、何も構築せずに実際のハードウェアで Nerves プロジェクトを試すことができます。 数分以内に、Raspberry Pi や Beaglebone で Nerves を実行できるようになります。 Livebook でコードを実行し、ブラウザーで快適に Nerves チュートリアルを進めることができます。

有志の方々が Nerves Livebook のセットアップ方法ついてのビデオを制作してくださっています。ありがとうございます。

https://youtu.be/-c4VJpRaIl4?si=XV26RifdxSjKog_L

https://youtu.be/-b5TPb_MwQE?si=nL43DmK7RNIQjOu5

Nerves Livebook の中に ネットワーク関連のノートブックが含まれており、ブラウザ上で Wi-Fi の設定ができてしまいます。

- [WiFi 設定についてのノートブック](https://github.com/nerves-livebook/nerves_livebook/blob/main/priv/samples/networking/configure_wifi.livemd)
- [VintageNet についてのノートブック](https://github.com/nerves-livebook/nerves_livebook/blob/main/priv/samples/networking/vintage_net.livemd)

また、[Nerves Livebook ファームウェア][nerves_livebook] を microSD に焼く時点で Wi-Fi の設定を環境変数として渡す方法もあります。

README の [firmware-provisioning-options](https://github.com/nerves-livebook/nerves_livebook#firmware-provisioning-options) セクションをご参照ください。

```bash:ホストマシンのターミナルで microSD に焼くコマンド
sudo NERVES_WIFI_SSID='access_point' \
     NERVES_WIFI_PASSPHRASE='passphrase' \
     fwup nerves_livebook_rpi0.fw
```

https://qiita.com/torifukukaiou/items/dfe1577004f36b8b77d7

[nerves_livebook]: https://github.com/nerves-livebook/nerves_livebook

## ネットワーク設定を確認

### VintageNet.info

[VintageNet.info/1] で現在のネットワーク設定を確認できます。

[VintageNet.info/1]: https://hexdocs.pm/vintage_net/VintageNet.html#info/1

```elixir:対象デバイスのIEx
VintageNet.info
```

```
VintageNet 0.13.5

All interfaces:       ["lo", "usb0", "wlan0"]
Available interfaces: ["wlan0"]

Interface eth0
  Type: VintageNetEthernet
  Present: false
  Configuration:
    %{type: VintageNetEthernet, ipv4: %{method: :dhcp}}

Interface usb0
  Type: VintageNetDirect
  Present: true
  State: :configured (12 days, 18:46:34)
  Connection: :disconnected (12 days, 18:46:36)
  Addresses: 172.31.36.97/30
  MAC Address: "12:3d:01:01:19:79"
  Configuration:
    %{type: VintageNetDirect, vintage_net_direct: %{}}

Interface wlan0
  Type: VintageNetWiFi
  Present: true
  State: :configured (12 days, 18:46:34)
  Connection: :internet (12 days, 18:46:27)
  Addresses: 192.168.1.2/24, fe80::ba27:ebff:asdf:222a/64
  MAC Address: "b8:27:eb:cb:12:34"
  Configuration:
    %{
      type: VintageNetWiFi,
      vintage_net_wifi: %{
        networks: [
          %{
            mode: :infrastructure,
            psk: "....",
            ssid: "PiyoPiyo",
            key_mgmt: :wpa_psk
          }
        ]
      },
      ipv4: %{method: :dhcp}
    }

:ok
```


### ifconfig

ターミナルで使う UNIX コマンドのような感覚で [Toolshed.ifconfig/0] を使うこともできます。

```elixir:対象デバイスのIEx
ifconfig
```

```
lo: flags=[:up, :loopback, :running]
    inet 127.0.0.1  netmask 255.0.0.0
    inet ::1  netmask ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff
    hwaddr 00:00:00:00:00:00

wlan0: flags=[:up, :broadcast, :running, :multicast]
    inet 192.168.1.2  netmask 255.255.255.0  broadcast 192.168.1.255
    inet fe80::ba27:ebff:asdf:222a  netmask ffff:ffff:ffff:ffff::
    hwaddr b8:27:eb:cb:12:34

usb0: flags=[:up, :broadcast, :running, :multicast]
    inet 172.31.36.97  netmask 255.255.255.252  broadcast 172.31.36.99
    hwaddr 12:3d:01:01:19:79
```

[Toolshed]: https://hexdocs.pm/toolshed
[Toolshed.ifconfig/0]: https://hexdocs.pm/toolshed/Toolshed.html#ifconfig/0

## インターネット接続の確認

[Toolshed.weather/0] を実行してエラーが出なければ OK です。

```elixir:対象デバイスのIEx
iex(1)> weather
┌┤  Weather report for: Washington, District of Columbia, United States  ├┐
│                                                                        │
│                                                                        │
│       Sun 05 Nov              Mon 06 Nov              Tue 07 Nov       │
│                       ╷                       ╷                        │
│                                                                        │
│                                                                        │
│+71          ⡔⠉⠉⠉⠑⡄                                                     │
│            ⡸     ⠘⡄                                         ⢀⠔⠉⠉⠉⠢⣀    │
│           ⢠⠃      ⠱⡀                                       ⢠⠃      ⠑⢄  │
│           ⡜        ⢣                                      ⢠⠃         ⠉⠁│
│          ⢀⠇        ⠈⣆                                    ⡠⠃            │
│⢀⢄⡀       ⡸          ⠈⡂              ⡠⠒⠉⠉⠉⠑⠒⠤⣀    ⢀⣀⣀⣀⣀⣀⠤⠔⠁             │
│⡇ ⠢⡀      ⡇           ⠈⠢⡀           ⡰⠁        ⠉⠉⠉⠉⠁                     │
│⡇  ⠱⡀    ⡸              ⠈⠢⢄        ⡰⠂                                   │
│⡇   ⠱⡀  ⢀⠇                 ⠉⠢⢄    ⢠⠃                                    │
│+44  ⠑⢄⢁⠎                     ⠑⠢⠤⡠⠃                                     │
│                                                                        │
│─────┴─────┼─────┴─────╂─────┴─────┼─────┴─────╂─────┴─────┼─────┴─────╂│
│     6    12    18           6    12    18           6    12    18      │
│                                                                        │
│                                                                        │
│                                                                        │
│                                                                        │
│                                                                        │
│                                                                        │
│                                                                        │
│                                                                        │
│                                                                        │
│ ⛅️ ⛅️ ⛅️ ☁️  ☀️  ☀️  ☀️  ☀️  ☀️  ☀️  ☀️  ⛅️ ⛅️ ☁️  ☁️  ☀️  ☀️  ⛅️ ⛅️ ⛅️ ⛅️ ☁️  ⛅️ ☀️ │
│ ↑  →  ↘  ↘  ↘  ↘  ↘  ↓  ↓  ↙  ↙  ←  ↑  ↑  ↑  ↑  ↑  ↗  ↗  ↗  ↗  ↗  ↘  ↘ │
│ 2  2  3  2  7  9  5  5  5  3  3  3  4  7  6  7  9  8  8  8  9  6  7  9 │
│                                                                        │
│🌗                     🌗                      🌘                     🌘│
│       ━━━━━━━━━━━             ━━━━━━━━━━━             ━━━━━━━━━━━      │
│                                                                        │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
Weather: ⛅️  Partly cloudy, +61°F, 44%, ↓9mph, 1018hPa
Timezone: America/New_York
  Now:    21:24:24-0500 | Dawn:    06:12:21  | Sunrise: 06:40:49
  Zenith: 11:51:41      | Sunset:  17:02:10  | Dusk:    17:30:37
```

[Toolshed.ping/1] も使えます。

```elixir:対象デバイスのIEx
iex(1)> ping "8.8.8.8"
Response from 8.8.8.8 (8.8.8.8): icmp_seq=0 time=33.517ms
Response from 8.8.8.8 (8.8.8.8): icmp_seq=1 time=100.672ms
Response from 8.8.8.8 (8.8.8.8): icmp_seq=2 time=39.159ms
```

[Toolshed.speedtest/1] も面白いです。

```elixir:対象デバイスのIEx
iex(1)> speed_test
2345425 bytes received in 5.18 s
Download speed: 3.62 Mbps
```

[Toolshed]: https://hexdocs.pm/toolshed
[Toolshed.weather/0]: https://hexdocs.pm/toolshed/Toolshed.html#weather/0
[Toolshed.speedtest/1]: https://hexdocs.pm/toolshed/Toolshed.html#speedtest/1
[Toolshed.ping/1]: https://hexdocs.pm/toolshed/Toolshed.html#ping/1

## ファームウエアのメタデータ

[Nerves.Runtime.KV] の関数でファームウエアのメタデータにアクセスできます。

```elixir:対象デバイスのIEx
Nerves.Runtime.KV.get_all
Nerves.Runtime.KV.get("wifi_ssid")
Nerves.Runtime.KV.get("wifi_passphrase")
```

[Nerves.Runtime.KV]: https://hexdocs.pm/nerves_runtime/Nerves.Runtime.KV.html

## さいごに

Nerves で 無線LAN (Wi-Fi) でインターネット接続する方法をまとめました。

他にも [vintage_net_wizard](https://github.com/nerves-networking/vintage_net_wizard) などまだ試せていないものがたくさんあります。

本記事は [autoracex #253](https://autoracex.connpass.com/event/298184/) の成果です。ありがとうございます。

https://autoracex.connpass.com/

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

<!-- begin hyperlink list -->
[Nerves]: https://github.com/nerves-project/nerves
[nerves]: https://github.com/nerves-project/nerves
[nerves_systems]: https://github.com/nerves-project/nerves_systems
[Nerves Systems Builder]: https://github.com/nerves-project/nerves_systems
[Elixir]: https://ja.wikipedia.org/wiki/Elixir_(プログラミング言語)
[Mix]: https://hexdocs.pm/mix/Mix.html
[Buildroot]: https://buildroot.org/
[x86_64]: https://ja.wikipedia.org/wiki/X64
[aarch64]: https://ja.wikipedia.org/wiki/AArch64
[Linux]: https://ja.wikipedia.org/wiki/Linux
[仮想機械]: https://ja.wikipedia.org/wiki/仮想機械
[Debian]: https://ja.wikipedia.org/wiki/Debian
[Erlang]: https://ja.wikipedia.org/wiki/Erlang
[hex]: https://hex.pm/
[rebar]: https://github.com/erlang/rebar3
[asdf]: https://asdf-vm.com/
[asdf installation]: https://asdf-vm.com/guide/getting-started.html#_3-install-asdf
[nerves_bootstrap]: https://github.com/nerves-project/nerves_bootstrap
[シェル]: https://ja.wikipedia.org/wiki/シェル
[bash]: https://ja.wikipedia.org/wiki/Bash
[アーカイブ]: https://ja.wikipedia.org/wiki/アーカイブ_(コンピュータ)
[インクリメンタルビルド]: https://ja.wikipedia.org/wiki/ビルド_(ソフトウェア)
[対象デバイス]: https://hexdocs.pm/nerves/targets.html
[DHCP]: https://ja.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol
<!-- end hyperlink list -->

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)
