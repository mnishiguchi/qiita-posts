---
title: Nerves ファームウェア プロジェクトを新しいバージョンの Nerves System にアップグレード
tags:
  - Linux
  - Elixir
  - 組み込み
  - IoT
  - Nerves
private: false
updated_at: '2023-07-13T00:26:29+09:00'
id: a768d91d6b598b48d702
organization_url_name: fukuokaex
slide: false
---
## はじめに

Nerves ファームウェア プロジェクトを新しいバージョンの Nerves System にアップグレードするときに実行する手順についてのメモ。

[English](https://embedded-elixir.com/post/2023-07-11-nerves-upgrade-guide)

## Nervesとは

一言で言うと「Elixir で IoT！？ナウでヤングで cool な Nerves フレームワーク」です。

https://twitter.com/torifukukaiou/status/1201266889990623233

https://nerves-project.org

https://nerves-jp.connpass.com

https://www.slideshare.net/takasehideki/elixiriotcoolnerves-236780506

https://www.slideshare.net/YutakaKikuchi1/elixir-on-elixir-and-embedded-systems

https://qiita.com/pojiro/items/e4a724934feae93180b0

https://qiita.com/pojiro/items/fee4b0bd45eb655613da

https://www.meetup.com/nerves

https://www.youtube.com/channel/UCGN8sxQ5kyk6Ziqma_FEnMA

[Nerves]: https://nerves-project.org
[Hex]: https://hex.pm/docs/publish#submitting-the-package

## 準備

### プロジェクトが現在使用している Elixir および Erlang/OTP のバージョン

`elixir --version`をプロジェクトのディレクトリで実行するのが簡単です。

```bash:terminal
$ cd path/to/my_project

$ elixir --version
```

結果はこんな感じに出力されます。

```
Erlang/OTP 26 [erts-14.0.2] [source] [64-bit] [smp:10:10] [ds:10:10:10] [async-threads:1] [jit]

Elixir 1.15.2 (compiled with Erlang/OTP 26)
```

### Mix Target と Nerves System

ターゲットデバイスの [Mix Target] タグと、対応する Nerves System (ターゲット用のビルドプラットフォーム) を見つけます。
[Nerves Targets document] を参照してください。
例として、ターゲットデバイスが [Raspberry Pi 4] の場合以下の通りになります。

- Mix Target: `rpi4`
- Nerves System: [nerves_system_rpi4][nerves_system_rpi4 package]

[nerves package]: https://hex.pm/packages/nerves
[nerves_system_rpi4 package]: https://hex.pm/packages/nerves_system_rpi4
[Mix Target]: https://hexdocs.pm/mix/main/Mix.html#module-targets
[Raspberry Pi 4]: https://www.raspberrypi.com/products/raspberry-pi-4-model-b/
[Nerves Targets document]: https://hexdocs.pm/nerves/targets.html

### mix.exs

Nerves プロジェクトは、関心事ごとに限定された範囲に焦点を当てるために、多くのパッケージに分散されています。
これらは `mix.exs` ファイルに依存関係として列挙されています。以下は [nerves_examples/blinky/mix.exs] の例です。

```elixir:mix.exs
defp deps do
  [
    # Dependencies for all targets
    {:nerves, "~> 1.10", runtime: false},
    {:shoehorn, "~> 0.9.0"},
    {:ring_logger, "~> 0.10.2"},
    {:toolshed, "~> 0.3.1"},

    # Dependencies for all targets except :host
    {:nerves_runtime, "~> 0.13.0", targets: @all_targets},
    {:nerves_pack, "~> 0.7.0", targets: @all_targets},
    ...
    # Dependencies for specific targets
    {:nerves_system_rpi4, "~> 1.21", runtime: false, targets: :rpi4},
    ...
  ]
end
```

[nerves_examples/blinky/mix.exs]: https://github.com/nerves-project/nerves_examples/blob/ac067cf2d3b88cf5985cadabf7b845b0862e3785/blinky/mix.exs#L43
　
ほとんどの場合、変更ログで明記されていない限り下位互換性があり、通常は最新バージョンを使用しても問題ありません。ただし、Nerves System の依存関係は Erlang/OTP のバージョンに依存するので注意が必要です。具体的には、プロジェクトで使用する Erlang/OTP のメジャーバージョンは、Nerves System の依存関係が期待するメジャーバージョンと一致する必要があります。

Nerves System の依存関係によって、ターゲットで実行されている OTP バージョンが決まります。Nerves System のアップデートにより、新しいバージョンの Erlang/OTP が取り込まれた可能性を想定してください。公式の Nerves System を使用している場合は、Nerves ドキュメントの[Nerves System 互換性表][Nerves System compatibility chart] または[リリースに付属する変更ログ](https://github.com/nerves-project/nerves_system_rpi4/commit/0cff1d8b9d66c117cf00a8f5753dc9bc4a70b59a)で確認できます。

バージョンの不一致が発生した場合、わかりやすいエラーメッセージが表示されます。これは、Nerves ユーザーに上記のことを思い出してもらうことを目的としたものなので、怖がらずに読んでください。

![nerves-system-otp-version-not-matching](https://user-images.githubusercontent.com/7563926/252093501-5e8264ac-3e51-4d19-8a23-15c303b04651.png)

[nerves_system_br package]: https://hex.pm/packages/nerves_system_br
[Nerves System compatibility chart]: https://hexdocs.pm/nerves/systems.html#compatibility

## 基本的なワークフロー

### 依存関係を編集する
必要に応じて、 `mix.exs` で依存関係のバージョン番号を変更します。

### 依存関係を掃除する
```bash
# Option 1
$ mix clean --deps

# Option 2
$ rm -rf _build deps
```

### 依存関係の固定を解除する
```bash
# Option 1
$ mix deps.unlock --all

# Option 2
$ rm mix.lock
```

### 依存関係を更新する
```bash
# Set the MIX_TARGET to the desired platform (rpi4, bbb, mangopi_mq_pro, etc.)
$ export MIX_TARGET=rpi4
$ mix deps.get
```

### ファームウェアをビルドする
```bash
$ mix firmware
```

```bash
# Option 1: Insert a MicroSD card to your host machine
$ mix burn

# Option 2: Upload to an existing Nerves device
$ mix firmware.gen.script
$ ./upload.sh nerves-1234.local
```

## 重大な変更
Nerves コアチームは、管理するすべてのパッケージの下位互換性を可能な限り確保するために最善を尽くしています。ただし、外部の依存関係によって何かが変更されると、それを制御できない場合があります。このような場合、Nerves コアチームは変更履歴だけでなく、わかりやすいメッセージを考案します。

一例は [VM args] です。Elixir 1.15 および Erlang/OTP 26 をサポートするには、それらのバージョンによりNerves ユーザーは Erlang VM の引数を変更する必要があります。

解決策として、Nerves コア チームは、現在使用されているバージョンに応じて、変更手順を含む適切なメッセージを出力するロジックを実装しました。

https://github.com/nerves-project/nerves/pull/884/files

また、Nerves プロジェクト テンプレートも更新され、`vm.args` ファイルが条件に応じて適切に生成されるようになりました。

https://github.com/nerves-project/nerves_bootstrap/pull/273/files

それに加えて、Nerves プロジェクトは、フレンドリーで熱心なコミュニティによって支えられているオープンソースプロジェクトです。バグや問題が見つかった場合は、Github Issue や Pull Request は歓迎されます。

![CleanShot 2023-07-07 at 23 00 00](https://user-images.githubusercontent.com/7563926/252123039-10d8d4ae-88ef-4ede-9121-378b9648d39a.png)

[VM args]: https://elixir-lang.org/getting-started/mix-otp/config-and-releases.html#vm-args

## 使用されていないアーティファクトを削除

これは任意ですが、使用しなくなったバージョンのダウンロードしたアーティファクトを削除する良い機会です。

Nerves は、Nerves System の依存性を解決するときに、キャッシュミラーの 1 つからシステムとツールチェーンを自動的に取得します。これらのアーティファクトはプロジェクト間で共有するためにローカルの `~/.nerves/artifacts` にキャッシュされています。

それらはいつでも安全に削除することがきます。仮に万一必要なものが削除されても `mix deps.get` を実行すれば再度ダウンロードされます。

```bash
ls ~/.nerves

rm -fr ~/.nerves
```
