---
title: Nervesデバイスを工場出荷状態に初期化する方法
tags:
  - Erlang
  - Linux
  - Elixir
  - IoT
  - Nerves
private: false
updated_at: '2023-12-13T06:16:05+09:00'
id: f354dc92942724aad1d1
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

[Nerves] デバイスを工場出荷状態に初期化するにはどうすればいいのでしょうか？　
いくつかアイデアがあります。自分でやったことはないのですが、識者の会話から学んだことをまとめます。参考になれば幸いです。

## Elixir プロジェクトの`priv`ディレクトリに初期化用データを追加

最も簡単な方法は、[Nerves] ファームウエアを構成する[Elixir] プロジェクトのうちどれか一つの`priv`ディレクトリに読み取り専用データを追加することです。 そのデータは[Elixir]コードとともに [Nerves] イメージに含まれるので、実行時に[Application.app_dir/2] を呼び出してそのパスを取得できます。

実はこれは[Nerves] 特有のものではなく [Elixir]/[Erlang] に備わっている機能です。

[Erlang]のドキュメントにはこう書かれています。

> priv - Optional. Used for application specific files.

https://www.erlang.org/doc/design_principles/applications.html

そういえば[Phoenix]アプリで写真とかが`priv/static/assets`に格納されてましたね。

> assets - a directory that keeps source code for your front-end assets, typically JavaScript and CSS. These sources are automatically bundled by the esbuild tool. Static files like images and fonts go in priv/static.

https://hexdocs.pm/phoenix/directory_structure.html

## `rootfs_overlay`ディレクトリに初期化用データを追加

初期化用データを`rootfs_overlay`ディレクトリに含めることにより、[Nerves] ファームウエアのビルド時にファイルシステムの一部にしてしまう技です。なんらかの理由で（`priv`ディレクトリ以外の）特定のパスに初期化用データを置いておきたい場合はこの手法が便利です。

[Nerves] により生成された[Elixir]プロジェクトには、`rootfs_overlay` ディレクトリが含まれており、`config/config.exs`にそれ用の設定項目があります。

基本的に、`rootfs_overlay` ディレクトリに置いたものはすべてディスク上にオーバーレイされます。 例えば、あるファイルをデバイス上の `/etc/some_data_file.txt` に存在させたい場合は、そのファイルを `rootfs_overlay/etc/some_data_file.txt` のリポジトリに置くことになります。

https://hexdocs.pm/nerves/advanced-configuration.html#root-filesystem-overlays

[v1.9.2](https://github.com/nerves-project/nerves/blob/main/CHANGELOG.md#v192---2023-02-05)から以下のディレクトリのオーバーレイが禁止になりましたので、注意してください。
- `/root`
- `/tmp`
- `/dev`
- `/sys`
- `/proc`

https://github.com/nerves-project/nerves/blob/main/CHANGELOG.md#v192---2023-02-05

https://github.com/nerves-project/nerves_system_br/issues/495

## `/root`（別名`/data`）内のすべてのファイルとディレクトリを再フォーマット

https://qiita.com/torifukukaiou/items/9dd5cfa81109a2e0a5eb

工場出荷状態に初期化するとは、読み書き可能な`/root`（別名`/data`）内のすべてのファイルとディレクトリを削除し、[SDカード]を`mix burn`を実行した時と同じ状態にすることと考えることができます。 その考えでいけば、すべての設定とデータを`/root`に保存するということになります。

直接ファイルを削除するのではなく、下位レベルの`/data`パーティションをゼロにして再フォーマットするのが確実だと考えられます。

```elixir
# `/root` がマウントされている場所を確認
root_mount_point = (
  System.shell("mount | grep 'on /root'")
  |> elem(0)
  |> String.split(" ")
  |> hd()
)

# `/root`パーティションをゼロにして再フォーマット
System.cmd("dd", ["if=/dev/zero", "of=#{root_mount_point}", "bs=1M", "count=1"])

# 再起動
Nerves.Runtime.reboot
```

:tada::tada::tada:

ただ、この作業はちょっと大変なので、将来の[Nerves]リリースでなんとかこれを簡単にできるようにしたいですね。

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

お、もう簡単にできるようになっているのかも！うっかり見落としてました。

[Nerves.Runtime.FwupOps.factory_reset/1](https://hexdocs.pm/nerves_runtime/Nerves.Runtime.FwupOps.html#factory_reset/1)、これで一発です。

```elixir
Nerves.Runtime.FwupOps.factory_reset
```

https://hexdocs.pm/nerves_runtime/Nerves.Runtime.FwupOps.html#factory_reset/1

https://github.com/nerves-project/nerves_runtime/commit/1b2645167a3bdf32c4f12e5eda40eaabddc32315

https://hexdocs.pm/nerves_runtime/readme.html#filesystem-initialization

WiFi SSID やパスワードなどのネットワーク設定を含む多くの設定がアプリケーション データ パーティションに保存されていることに注意してください。 出荷時設定にリセットされたデバイスは、その後ネットワークに接続できなくなる可能性があります。

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)

<!-- begin links -->

[Nerves]: https://github.com/nerves-project/nerves
[Elixir]: https://elixir-lang.org/
[Erlang]: https://www.erlang.org/
[Phoenix]: https://www.phoenixframework.org/
[IEx]: https://elixirschool.com/ja/lessons/basics/basics#%E5%AF%BE%E8%A9%B1%E3%83%A2%E3%83%BC%E3%83%89-2
[Application.app_dir/2]: https://hexdocs.pm/elixir/Application.html#app_dir/2
[SDカード]: https://ja.wikipedia.org/wiki/SD%E3%83%A1%E3%83%A2%E3%83%AA%E3%83%BC%E3%82%AB%E3%83%BC%E3%83%89

<!-- end links -->
