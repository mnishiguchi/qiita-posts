---
title: Nerves デバイスの /data ディレクトリ
tags:
  - Erlang
  - Linux
  - Elixir
  - IoT
  - Nerves
private: false
updated_at: '2023-12-13T10:58:35+09:00'
id: 39847da8df3873fec8c9
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

## 読み込み専用ファイルシステム[SquashFS]

[Nerves]は読み込み専用ファイルシステムである[SquashFS]を採用し、不測の電源障害が起きてもファイルシステムが壊れない堅牢な組み込み IoT システムを実現しています。

https://ja.wikipedia.org/wiki/SquashFS

https://hexdocs.pm/nerves/advanced-configuration.html

現実は永続化したいデータや設定がいくつかあると思いますので、全く書き込めないとそれは不便です。そのため[Nerves]は書き込める場所を用意してくれています。

https://qiita.com/torifukukaiou/items/9dd5cfa81109a2e0a5eb

それが、特別に書き込める場所`/data`です。

## 書き込める場所`/data`

[Nerves]システムのルートファイルシステム（Rootfs）は読み取り専用としてマウントされているため、それとは別に Application という読み書き可能な領域が設けられ、それがルートユーザーのホームディレクトリとして`/data`にマウントされています。

実際には、書き込み可能なパーティションは常に `/root` であり、`/data` は `/root` へのシンボリックリンクです。

```
 +----------------------------+
 | MBR                        |
 +----------------------------+
 | Firmware configuration data|
 | (formatted as uboot env)   |
 +----------------------------+
 | p0*: Boot A        (FAT32) |
 | zImage, bootcode.bin,      |
 | config.txt, etc.           |
 +----------------------------+
 | p0*: Boot B        (FAT32) |
 +----------------------------+
 | p1*: Rootfs A   (squashfs) |
 +----------------------------+
 | p1*: Rootfs B   (squashfs) |
 +----------------------------+
 | p2: Application     (EXT4) |
 +----------------------------+
```

https://hexdocs.pm/nerves/advanced-configuration.html#partitions

https://hexdocs.pm/nerves_runtime/readme.html#filesystem-initialization

## `/data`の中身

`/data`の中身は`nerves_system_xxx`パッケージの`rootfs_overlay/etc/erlinit.config`設定ファイルにより決定されるようです。詳しくは知りません。

`nerves_system_xxx`の`xxx`の部分はお手元のデバイスに対応する[Nerves Target]に読み替えてください。[Nerves]公式サポートの[Nerves Target]以外にもコミュニティによって制作されたカスタムシステムも多数あります。

https://hex.pm/packages?search=nerves_system_&sort=recent_downloads

例として挙げると、[Raspberry Pi 4]に対応する[Nerves Target]は`rpi4`になります。

https://github.com/nerves-project/nerves_system_rpi4/blob/main/rootfs_overlay/etc/erlinit.config

`mix burn`を実行すると [SDカード]全体を事実上初期の状態にリセットことになるので、`/data`のファイルが消去されます。一方、ネットワークを介した通常のファームウェアの更新は`/data` には影響しません。

`/data`の中身を読み書きするシナリオはいくつか考えられます。

- ファームウエアをビルドして、[SDカード]に焼くときに初期化される
- エンジニアが[SFTP]で読み書き
- Elixir アプリ（ライブラリ）が永続化するデータを読み書き
- 工場出荷状態に初期化

https://qiita.com/mnishiguchi/items/f354dc92942724aad1d1

## rootfs_overlay

Nerves システムに用意されている初期設定をちょこっとだけ変更したい場合には、`rootfs_overlay`という仕組みがあります。これにより直接`nerves_system_xxx`をいじらずにプチカスタマイズすることが可能となります。

オーバーレイとは「重ね合わせる」という意味で、ルートファイルシステムに追加したいディレクトリ構造を提示し、それがファームウエアをビルドするときにルートファイルシステムに重ね合わされて実際にルートファイルシステムの一部となるというイメージです。

https://hexdocs.pm/nerves/advanced-configuration.html#root-filesystem-overlays

[Nerves] により生成された[Elixir]プロジェクトには、`rootfs_overlay` ディレクトリが含まれており、`config/config.exs`にそれ用の設定項目があります。

基本的に、`rootfs_overlay` ディレクトリに置いたものはすべてディスク上にオーバーレイされます。 例えば、あるファイルをデバイス上の `/etc/some_data_file.txt` に存在させたい場合は、そのファイルを `rootfs_overlay/etc/some_data_file.txt` のリポジトリに置くことになります。

```elixir:config/config.exs
config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"
```

一例として[Nerves Livebook]の`rootfs_overlay`ディレクトリにはこんなファイルが含まれています。

```elixir:rootfs_overlay/etc/iex.exs
NervesMOTD.print()

# Add Toolshed helpers to the IEx session
use Toolshed
```

https://github.com/nerves-livebook/nerves_livebook/tree/d180dacb6ff76e7f269f92d1a992c27b9775f0c8/rootfs_overlay

このファイルがファームウエアのファイルシステムの`/etc/iex.exs`ファイルとなり、[IEx] 起動時の挙動を変更しています。

https://speakerdeck.com/ohr486/iex-maniacs

https://samuelmullen.com/articles/customizing_elixirs_iex

https://alchemist.camp/episodes/iex-exs

https://fly.io/phoenix-files/taking-control-of-map-sort-order-in-elixir/

同様に`/data`の中身を変更したい場合は、ご自身の Nerves プロジェクトに`rootfs_overlay/etc/erlinit.config` ファイルを用意することにより、ご使用の Nerves システム（例、[Raspberry Pi 4]用は[nerves_system_rp4]）にある同じものを上書きすることができます。

ここで注意すべき点は、オーバーレイを適用すると、内容が結合されるのではなく、ファイル全体が置き換えられることです。 したがって、最初に元のファイルを取得してそれを必要に応じて変更するというやり方が安全です。

https://github.com/nerves-project/nerves_system_rpi4/blob/main/rootfs_overlay/etc/erlinit.config

## rootfs_overlay で禁止されていること

[v1.9.2](https://github.com/nerves-project/nerves/blob/main/CHANGELOG.md#v192---2023-02-05)から以下のディレクトリ(`/root`を含む！)のオーバーレイが禁止になりましたので、注意してください。

- `/root`
- `/tmp`
- `/dev`
- `/sys`
- `/proc`

ですので直接、初期設定の`/root`を上書きすることはできません。システムの初期設定は（手作業でなく）設定ファイルを介して行います。

https://github.com/nerves-project/nerves_system_br/issues/495

https://github.com/nerves-project/nerves/blob/main/CHANGELOG.md#v192---2023-02-05

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

## Nerves JP

[Nerves] にご興味のある方は、ぜひ Nerves JP にお越しください。わいわいガヤガヤ楽しく [Nerves] してます。

https://nerves-jp.connpass.com/event/291879/

https://docs.google.com/presentation/d/18v1go3hRx2iHQ0Z0f41GW9IHJs-rIxlW1TaYuCaGWzY/edit

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)

<!-- begin links -->

[Nerves]: https://github.com/nerves-project/nerves
[Elixir]: https://elixir-lang.org/
[Erlang]: https://www.erlang.org/
[Phoenix]: https://www.phoenixframework.org/
[IEx]: https://elixirschool.com/ja/lessons/basics/basics#%E5%AF%BE%E8%A9%B1%E3%83%A2%E3%83%BC%E3%83%89-2
[Application.app_dir/2]: https://hexdocs.pm/elixir/Application.html#app_dir/2
[SDカード]: https://ja.wikipedia.org/wiki/SD%E3%83%A1%E3%83%A2%E3%83%AA%E3%83%BC%E3%82%AB%E3%83%BC%E3%83%89
[SquashFS]: https://ja.wikipedia.org/wiki/SquashFS
[Nerves Target]: https://hexdocs.pm/nerves/supported-targets.html
[SFTP]: https://ja.wikipedia.org/wiki/SSH_File_Transfer_Protocol
[Nerves Livebook]: https://github.com/nerves-livebook/nerves_livebook
[Raspberry Pi 4]: https://www.raspberrypi.com/products/raspberry-pi-4-model-b/
[nerves_system_rp4]: https://github.com/nerves-project/nerves_system_rpi4

<!-- end links -->
