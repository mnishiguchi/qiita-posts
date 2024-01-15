---
title: Nerves関連のMixタスクを列挙する
tags:
  - Erlang
  - Linux
  - Elixir
  - IoT
  - Nerves
private: false
updated_at: '2024-01-16T00:01:42+09:00'
id: fc3d287d8c6dcd3f5ddb
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

Nerves関連のMixタスクを列挙する方法を考えてみます。

## Mixタスク

Mix は、Elixir プロジェクトの作成、コンパイル、テスト、依存関係の管理などのタスクを提供するビルド ツールです。

https://hexdocs.pm/mix/Mix.html

https://elixirschool.com/ja/lessons/basics/mix

## Elixirプロジェクト内のMixタスクを列挙

現在の環境で Mix が提供するすべての機能を確認するには、`mix help` を実行します。

```bash:terminal
mix help
```

行数を数えてみると65ありました。

```bash:terminal
mix help | wc -l
```

## Nerves関連のMixタスクだけに絞り込む

単純に`grep`したらうまくNerves関連ののMixタスクだけに絞り込めました！

```bash:terminal
mix help | grep 'mix' | grep -iE 'nerves|firmware'
```

結果は以下の通りです。

```bash
mix burn                    # Write a firmware image to an SDCard
mix compile.nerves_package  # Nerves Package Compiler
mix firmware                # Build a firmware bundle
mix firmware.burn           # Build a firmware bundle and write it to an SDCard
mix firmware.gen.gdb        # Generates a helper shell script for using gdb to analyze core dumps
mix firmware.gen.script     # Generates a shell script for pushing firmware updates
mix firmware.image          # Create a firmware image file
mix firmware.metadata       # Print out metadata for the current firmware
mix firmware.patch          # Build a firmware patch
mix firmware.unpack         # Unpack a firmware bundle for inspection
mix local.nerves            # Checks for updates to nerves_bootstrap
mix nerves.artifact         # Creates system and toolchain artifacts for Nerves
mix nerves.artifact.details # Prints Nerves artifact details
mix nerves.clean            # Cleans dependencies and build artifacts
mix nerves.info             # Prints Nerves information
mix nerves.new              # Creates a new Nerves application
mix nerves.system.shell     # Enter a shell to configure a custom system
mix nerves_key.device       # Simulate NervesKey device key creation
mix nerves_key.signer       # Manages NervesKey signing keys
mix upload                  # Uploads firmware to a Nerves device over SSH
```

## Nerves関連ののMixタスクは何処から来たのか

これが大変でした。Nervesプロジェクトは関心事ごとにパッケージ化されています。ですので、様々な機能が別々の場所で管理されているのです。

> Our project is spread over many repositories in order to focus on a limited scope per repository.
>
> This repository (nerves-project/nerves) is an entrance to Nerves and provides the core tooling and documentation.

> 私たちのプロジェクトは、リポジトリごとの限られた範囲に焦点を当てるために、多くのリポジトリに分散されています。
>
> このリポジトリ (nerves-project/nerves) は Nerves への入り口であり、コアツールとドキュメントを提供します。

nerves パッケージの [README.md](https://github.com/nerves-project/nerves/blob/main/README.md) に何がどこで管理されているか説明されています。

### nerves パッケージ
https://hexdocs.pm/nerves

```bash
mix burn                    # Write a firmware image to an SDCard
mix compile.nerves_package  # Nerves Package Compiler
mix firmware                # Build a firmware bundle
mix firmware.burn           # Build a firmware bundle and write it to an SDCard
mix firmware.gen.gdb        # Generates a helper shell script for using gdb to analyze core dumps
mix firmware.image          # Create a firmware image file
mix firmware.metadata       # Print out metadata for the current firmware
mix firmware.patch          # Build a firmware patch
mix firmware.unpack         # Unpack a firmware bundle for inspection
mix nerves.artifact         # Creates system and toolchain artifacts for Nerves
mix nerves.artifact.details # Prints Nerves artifact details
mix nerves.clean            # Cleans dependencies and build artifacts
mix nerves.info             # Prints Nerves information
mix nerves.system.shell     # Enter a shell to configure a custom system
```

### nerves_bootstrap パッケージ

https://hexdocs.pm/nerves_bootstrap

```bash
mix local.nerves            # Checks for updates to nerves_bootstrap
mix nerves.new              # Creates a new Nerves application
```

### nerves_key パッケージ

https://hexdocs.pm/nerves_key

```bash
mix nerves_key.device       # Simulate NervesKey device key creation
mix nerves_key.signer       # Manages NervesKey signing keys
```

### ssh_subsystem_fwup パッケージ

https://hexdocs.pm/ssh_subsystem_fwup

```bash
mix firmware.gen.script     # Generates a shell script for pushing firmware updates
mix upload                  # Uploads firmware to a Nerves device over SSH
```

:tada::tada::tada:

## 最後に一言

`mix nerves.info`について知りました。迷った時にとりあえずこれをランすると何か手がかりが得られそうです。

実は基本的なコマンド以外はほとんど使ったことがありません。何かいいテクニックをお持ちの方は是非教えてください！

本記事は [autoracex #269](https://autoracex.connpass.com/event/307159/) の成果です。ありがとうございます。

https://autoracex.connpass.com/

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)
