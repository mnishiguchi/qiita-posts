---
title: Elixir IExでphoenix_pubsubを使いメッセージを出版・購読
tags:
  - Erlang
  - Elixir
  - Phoenix
  - 40代駆け出しエンジニア
  - AdventCalendar2022
private: false
updated_at: '2022-12-08T11:54:33+09:00'
id: 73fc5c088d0f933bcf05
organization_url_name: fukuokaex
slide: false
---

[Phoenix]アプリで[phoenix_pubsub]を用いて[メッセージを出版・購読するパターン][出版-購読型モデル]がよく見られます。

https://github.com/phoenixframework/phoenix_pubsub

では、[Phoenix]アプリ以外で同様のメッセージのやり取りをするにはどうしたら良いのでしょうか？　

何と[phoenix_pubsub]は単体でどんな[Elixir]プロジェクトからでも利用できるのです。みなさん知ってました？

https://qiita.com/torifukukaiou/items/17d55cf896c24b13350e

一例として、[IEx]でやってみます。

## 一つの[IEx]上で[phoenix_pubsub]

[IEx]を起動します。

```sh:CMD
iex
```

[phoenix_pubsub]をインストールします。

```elixir:IEx
iex> Mix.install([{:phoenix_pubsub, "~> 2.0"}])
```

`Phoenix.PubSub.Supervisor`を起動します。
通常は取説に書いてあるようにプロジェクトの`Supervisor`の子プロセスとして起動するところですが、ここでは手動で立ち上げています。

```elixir:IEx
iex> Phoenix.PubSub.Supervisor.start_link(name: Toukon.PubSub)
```

余談ですが`Phoenix.PubSub.Supervisor`のソースコードは[IEx]のコマンドで開くことができます。

```elixir:IEx
iex> open Phoenix.PubSub.Supervisor
```

https://qiita.com/mnishiguchi/items/e62280edae8b2009384a

話題を決めます。

```elixir:IEx
iex> topic = "闘魂Elixir"
```

購読します。

```elixir:IEx
iex> Phoenix.PubSub.subscribe(Toukon.PubSub, topic)
```

出版します。

```elixir:IEx
iex> Phoenix.PubSub.broadcast(Toukon.PubSub, topic, "完走賞を目指してみましょう！")
```

郵便受けを確認します。

```elixir:IEx
iex> flush
"完走賞を目指してみましょう！"
:ok
```

ノードは任意の話題を購読するとその話題に対して出版されたメッセージを受け取ることができます。

:tada:

ただ自分で自分で出版したメッセージを自分で購読しても面白くないので、ノードを2つ（`hoge`ノードと`piyo`ノード）立ち上げて同じことをやってみます。

`hoge`ノードがある話題を購読し、`piyo`ノードが同じ話題に対してメッセージを出版したら、それがの`hoge`ノード郵便受けに届くはずです。

## 二つのノードで[phoenix_pubsub]

`hoge`ノードを立ち上げます。

```sh:CMD
iex --sname hoge@localhost --cookie mycookie
```

別のシェルで`piyo`ノードを立ち上げます。

```sh:CMD
iex --sname piyo@localhost --cookie mycookie
```

両方のノードで[phoenix_pubsub]をインストールして（同じ名前の）`Phoenix.PubSub.Supervisor`を起動します。

```elixir:hoge
iex(hoge@localhost)> Mix.install([{:phoenix_pubsub, "~> 2.0"}])

iex(hoge@localhost)> Phoenix.PubSub.Supervisor.start_link(name: Toukon.PubSub)
```

```elixir:piyo
iex(piyo@localhost)> Mix.install([{:phoenix_pubsub, "~> 2.0"}])

iex(piyo@localhost)> Phoenix.PubSub.Supervisor.start_link(name: Toukon.PubSub)
```

`hoge`ノードから`piyo`ノードに接続します。

```elixir:hoge
iex(hoge@localhost)> Node.ping(:"piyo@localhost")
:pong

iex(hoge@localhost)> Node.list
[:piyo@localhost]
```

`hoge`ノードで`"闘魂Elixir"`という話題を購読します。

```elixir:hoge
iex(hoge@localhost)> Phoenix.PubSub.subscribe(Toukon.PubSub, "闘魂Elixir")
:ok
```

`piyo`ノードで`"闘魂Elixir"`という話題に対してメッセージを出版します。

```elixir:piyo
iex(piyo@localhost)> Phoenix.PubSub.broadcast(Toukon.PubSub, "闘魂Elixir", "完走賞を目指してみましょう！")
```

`hoge`ノードの郵便受けを確認。

```elixir:hoge
iex(hoge@localhost)> flush
"完走賞を目指してみましょう！"
:ok
```

`piyo`ノードが出版したメッセージが`hoge`ノードの郵便受けに届きました。

:tada:

[出版-購読型モデル]ではノードからノードに直接メッセージを送るのではなく、ある話題に興味のある購読者が一斉にメッセージを受け取ることができます。

それに対して、直接特定のノードにメッセージを送りたいときは[:rpc.call/4]で[遠隔手続き呼出し]が便利そうです。

https://qiita.com/mnishiguchi/items/e8018b7f981472d2fbf7

ちなみに[phoenix_pubsub]は[Erlang]の[pg]モジュールを使って実装されています。詳しいことは知りません。

https://github.com/phoenixframework/phoenix_pubsub/blob/7893228b48752437dff20b269ffdf614e07388dc/lib/phoenix/pubsub/pg2.ex

https://www.erlang.org/doc/man/pg.html


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
