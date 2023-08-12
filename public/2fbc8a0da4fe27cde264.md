---
title: Elixir mix.exsのconfig_providersオプションで設定ファイルの読み込みをカスタマイズ
tags:
  - Erlang
  - Elixir
  - Nerves
  - 40代駆け出しエンジニア
  - AdventCalendar2022
private: false
updated_at: '2022-12-09T10:35:07+09:00'
id: 2fbc8a0da4fe27cde264
organization_url_name: fukuokaex
slide: false
---
[Elixir]の[Mix]はデフォルトで`config/runtime.exs`を読み込みます。さらに任意の設定ファイルも読み込みたい場合は、[mix release]の[`:config_providers`][mix release - Config providers]オプションで設定ファイル読み込みの挙動をカスタマイズすることができます。

[Jason Axelson](https://github.com/axelson)さんが[Code BEAM Americe 2022](https://codebeamamerica.com)で披露されたNervesプロジェクトで[`:config_providers`][mix release - Config providers]が使用されています。参考になります。

https://qiita.com/torifukukaiou/items/4a930c89506c5c968c6f

https://github.com/axelson/vps

[Nerves]ファームウエアで隠しファイルに書かれた設定を`/data`フォルダから読み込むのに利用されているようです。

## [mix release]の[`:config_providers`][mix release - Config providers]オプション

- [Config.Provider behaviour]を実装する設定供給モジュールを含む[タプル][Tuple]の[リスト][List]
- デフォルトは`[]`

```diff_elixir:mix.exs
 defmodule HelloNerves.MixProject do
   use Mix.Project

   ...

   def project do
     [
       app: @app,
       version: @version,
       elixir: "~> 1.12",
       archives: [nerves_bootstrap: "~> 1.9"],
       start_permanent: Mix.env() == :prod,
       deps: deps(),
       releases: [{@app, release()}],
       preferred_cli_target: [run: :host, test: :host]
     ]
   end

   ...

   def release do
     [
+      config_providers: [
+        {Config.Reader, "/data/.target.secret.exs"}
+      ],
       overwrite: true,
       cookie: "#{@app}_cookie",
       include_erts: &Nerves.Release.erts/0,
       steps: [&Nerves.Release.init/1, :assemble],
       strip_beams: [keep: ["Docs"]]
     ]
   end

   ...
 end
```

https://github.com/axelson/vps/blob/e2d2e637a9a769b09d6db491ad768facdda08ae0/mix.exs#L76

## [Config.Provider behaviour]

- システム起動時に外部設定を読み込むAPI（init/1とload/2）
- 通常、[mix release]で使用される

https://github.com/axelson/vps/blob/e2d2e637a9a769b09d6db491ad768facdda08ae0/lib/vps/runtime_config_provider.ex

## [Config.Reader]

- Elixir標準の[Config.Provider behaviour]の実装
- 読み込みたいファイルのパスを指定するだけなら、[Config.Reader]で十分そう

https://github.com/elixir-lang/elixir/blob/0909940b04a3e22c9ea4fedafa2aac349717011c/lib/elixir/lib/config/reader.ex


## [自分で実装する][Custom config provider]

[自分で実装する][Custom config provider]する場合は以下の二つの関数（[Config.Provider callbacks]）を実装します。

- init/1
- load/2

https://github.com/axelson/vps/blob/e2d2e637a9a769b09d6db491ad768facdda08ae0/lib/vps/runtime_config_provider.ex

## ご参考までに

https://speakerdeck.com/elijo/elixirkomiyunitei-falsebu-kifang-guo-nei-onrainbian

https://qiita.com/piacerex/items/e0b6e46b1325bb931122

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

https://qiita.com/piacerex/items/e5590fa287d3c89eeebf

[Dashbit]: https://dashbit.co/
[Elixir]: https://elixir-lang.org/
[Erlang]: https://www.erlang.org/
[Phoenix]: https://www.phoenixframework.org/
[Nerves]: https://hexdocs.pm/nerves
[Livebook]: https://livebook.dev/
[IEx]: https://elixirschool.com/ja/lessons/basics/basics/#%E5%AF%BE%E8%A9%B1%E3%83%A2%E3%83%BC%E3%83%89
[Node | hexdocs]: https://hexdocs.pm/elixir/Node.html
[otp_distribution | elixirschool]: https://elixirschool.com/ja/lessons/advanced/otp_distribution
[Node.ping/1]: https://hexdocs.pm/elixir/Node.html#ping/1
[Node.connect/1]: https://hexdocs.pm/elixir/Node.html#connect/1
[Node.spawn/2]: https://hexdocs.pm/elixir/Node.html#spawn/2
[Node.list/0]: https://hexdocs.pm/elixir/Node.html#list/0
[Node.set_cookie/2]: https://hexdocs.pm/elixir/Node.html#set_cookie/2
[Node.get_cookie/0]: https://hexdocs.pm/elixir/Node.html#get_cookie/0
[epmd]: https://www.erlang.org/doc/man/epmd.html
[rpc]: https://www.erlang.org/doc/man/rpc.html
[erpc]: https://www.erlang.org/doc/man/erpc.html
[phoenix_live_dashboard]: https://github.com/phoenixframework/phoenix_live_dashboard
[phoenix_pubsub]: https://github.com/phoenixframework/phoenix_pubsub
[遠隔手続き呼出し]: https://ja.wikipedia.org/wiki/%E9%81%A0%E9%9A%94%E6%89%8B%E7%B6%9A%E3%81%8D%E5%91%BC%E5%87%BA%E3%81%97
[BEAM (Erlang virtual machine)]: https://en.wikipedia.org/wiki/BEAM_(Erlang_virtual_machine)
[:rpc.call/4]: https://www.erlang.org/doc/man/rpc.html#call-4
[IEx.Helpers.open/1]: https://hexdocs.pm/iex/IEx.Helpers.html#open/1
[Enum.reduce/3]: https://hexdocs.pm/elixir/Enum.html#reduce/3
[IEx.Helpers.h/1]: https://hexdocs.pm/iex/IEx.Helpers.html#h/1
[VS Code]: https://code.visualstudio.com/
[環境変数]: https://ja.wikipedia.org/wiki/%E7%92%B0%E5%A2%83%E5%A4%89%E6%95%B0
[Kernel]: https://hexdocs.pm/elixir/Kernel.html
[出版-購読型モデル]: https://ja.wikipedia.org/wiki/%E5%87%BA%E7%89%88-%E8%B3%BC%E8%AA%AD%E5%9E%8B%E3%83%A2%E3%83%87%E3%83%AB
[pg]: https://www.erlang.org/doc/man/pg.html
[Config.Provider behaviour]: https://hexdocs.pm/elixir/Config.Provider.html
[Config.Provider callbacks]: https://hexdocs.pm/elixir/Config.Provider.html#callbacks
[mix release]: https://hexdocs.pm/mix/Mix.Tasks.Release.html
[Config.Reader]: https://hexdocs.pm/elixir/Config.Reader.html
[mix release - Config providers]: https://hexdocs.pm/mix/Mix.Tasks.Release.html#module-config-providers
[List]: https://hexdocs.pm/elixir/List.html
[Tuple]: https://hexdocs.pm/elixir/Tuple.html
[ビヘイビア]: https://elixirschool.com/ja/lessons/advanced/behaviours
[Mix]: https://hexdocs.pm/mix/Mix.html
[Custom config provider]: https://hexdocs.pm/elixir/Config.Provider.html#module-custom-config-provider
