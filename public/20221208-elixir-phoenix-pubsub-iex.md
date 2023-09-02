---
title: Elixir IExでphoenix_pubsubを使いメッセージの出版・購読を楽しむ
tags:
  - Erlang
  - Elixir
  - Phoenix
  - PubSub
  - 分散システム
private: false
updated_at: '2023-08-24T09:33:01+09:00'
id: 73fc5c088d0f933bcf05
organization_url_name: fukuokaex
slide: false
---
[Phoenix]アプリで[phoenix_pubsub]を用いて[メッセージを出版・購読するパターン][出版-購読型モデル]がよく見られます。

https://github.com/phoenixframework/phoenix_pubsub

実は、[phoenix_pubsub]は[Phoenix]アプリ以外でも利用することができ、どんな[Elixir]プロジェクトからでも同様のメッセージのやり取りをすることができます。

これから[Elixir]を始める方にはこのサイトがおすすめです。

https://elixir-lang.info/

[Elixir]とコミュニティの雰囲気をゆるく味わいたい方は「先端ピアちゃん」さんの動画が超オススメです。

https://www.youtube.com/@piacerex

## 実験：一つのIEx上でphoenix_pubsub

対話Elixirシェル[IEx]で試してみます。　ターミナルを開き、[IEx]を起動します。

```sh:ターミナル
iex
```

[phoenix_pubsub]をインストールします。

```elixir:IEx
iex> Mix.install([{:phoenix_pubsub, "~> 2.0"}])
```

`Phoenix.PubSub.Supervisor`を起動します。
通常はElixirプロジェクトの`Supervisor`の子プロセスとして`Phoenix.PubSub.Supervisor`を起動することが多いと思いますが、ここでは手動で立ち上げます。

```elixir:IEx
iex> Phoenix.PubSub.Supervisor.start_link(name: :my_pubsub)
```

余談ですが`Phoenix.PubSub.Supervisor`のソースコードは[IEx.Helpers.open/1](https://hexdocs.pm/iex/IEx.Helpers.html#open/1)コマンドで開くことができます。

```elixir:IEx
iex> open Phoenix.PubSub.Supervisor
```

https://qiita.com/mnishiguchi/items/e62280edae8b2009384a

話題を決めます。

```elixir:IEx
iex> topic = "闘魂Elixir"
```

話題を購読します。

```elixir:IEx
iex> Phoenix.PubSub.subscribe(:my_pubsub, topic)
```

話題に対してメッセージを出版します。

```elixir:IEx
iex> Phoenix.PubSub.broadcast(:my_pubsub, topic, "元氣があればなんでもできる！")
```

郵便受けを確認します。

```elixir:IEx
iex> flush
"元氣があればなんでもできる！"
:ok
```

ノードは任意の話題を購読するとその話題に対して出版されたメッセージを受け取ることができます。

:tada::tada::tada:

ただ自分で自分で出版したメッセージを自分で購読しても面白くないので、ノードを2つ（`hoge`ノードと`piyo`ノード）立ち上げて同じことをやってみます。ノードは別々のPCでもOKです。

`hoge`ノードがある話題を購読し、`piyo`ノードが同じ話題に対してメッセージを出版したら、それがの`hoge`ノード郵便受けに届くはずです。

## 実験：二つのノードでphoenix_pubsub 1

`hoge`ノードを立ち上げます。

```sh:CMD
iex --sname hoge@localhost --cookie awesome_cookie
```

別のシェルで`piyo`ノードを立ち上げます。

```sh:CMD
iex --sname piyo@localhost --cookie awesome_cookie
```

両方のノードで[phoenix_pubsub]をインストールして（同じ名前の）`Phoenix.PubSub.Supervisor`を起動します。

```elixir:hoge
iex(hoge@localhost)> Mix.install([{:phoenix_pubsub, "~> 2.0"}])

iex(hoge@localhost)> Phoenix.PubSub.Supervisor.start_link(name: :my_pubsub)
```

```elixir:piyo
iex(piyo@localhost)> Mix.install([{:phoenix_pubsub, "~> 2.0"}])

iex(piyo@localhost)> Phoenix.PubSub.Supervisor.start_link(name: :my_pubsub)
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
iex(hoge@localhost)> Phoenix.PubSub.subscribe(:my_pubsub, "闘魂Elixir")
:ok
```

`piyo`ノードで`"闘魂Elixir"`という話題に対してメッセージを出版します。

```elixir:piyo
iex(piyo@localhost)> Phoenix.PubSub.broadcast(:my_pubsub, "闘魂Elixir", "元氣があればなんでもできる！")
```

`hoge`ノードの郵便受けを確認。

```elixir:hoge
iex(hoge@localhost)> flush
"元氣があればなんでもできる！"
:ok
```

`piyo`ノードが出版したメッセージが`hoge`ノードの郵便受けに届きました。

:tada::tada::tada:

[出版-購読型モデル]ではノードからノードに直接メッセージを送るのではなく、ある話題に興味のある購読者が一斉にメッセージを受け取ることができます。

## 実験：二つのノードでphoenix_pubsub 2

同じことをもっと簡単にできればと思い、コードをパッケージ化しました。

https://github.com/mnishiguchi/kantan_cluster

```elixir:hoge
iex

iex(hoge@localhost)> Mix.install([{:kantan_cluster, "~> 0.5.0"}])
iex(hoge@localhost)> KantanCluster.start_node(sname: :hoge, cookie: :awesome_cookie)
iex(hoge@localhost)> KantanCluster.subscribe("闘魂Elixir")
```

```elixir:piyo
iex

iex(piyo@localhost) Mix.install([{:kantan_cluster, "~> 0.5.0"}])
iex(piyo@localhost) KantanCluster.start_node(sname: :piyo, cookie: :awesome_cookie)
iex(piyo@localhost) KantanCluster.broadcast("闘魂Elixir", "元氣があればなんでもできる！")
```

```elixir:hoge
iex(hoge@localhost)> flush
"元氣があればなんでもできる！"
:ok
```

簡単に[出版-購読型モデル]を楽しめました！

https://qiita.com/mnishiguchi/items/e854de2626028b9ea830

:tada::tada::tada:

## :erpc.call/4で遠隔手続き呼出し

それに対して、直接特定のノードにメッセージを送りたいときは[:erpc.call/4]を用いた[遠隔手続き呼出し]が便利そうです。

https://qiita.com/mnishiguchi/items/e8018b7f981472d2fbf7

[phoenix_pubsub]は[Erlang]の[pg]モジュールを使って実装されているようです。詳しいことは知りません。

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
[:erpc.call/4]: https://www.erlang.org/doc/man/erpc.html#call-4
[IEx.Helpers.open/1]: https://hexdocs.pm/iex/IEx.Helpers.html#open/1
[Enum.reduce/3]: https://hexdocs.pm/elixir/Enum.html#reduce/3
[IEx.Helpers.h/1]: https://hexdocs.pm/iex/IEx.Helpers.html#h/1
[VS Code]: https://code.visualstudio.com/
[環境変数]: https://ja.wikipedia.org/wiki/%E7%92%B0%E5%A2%83%E5%A4%89%E6%95%B0
[Kernel]: https://hexdocs.pm/elixir/Kernel.html
[出版-購読型モデル]: https://ja.wikipedia.org/wiki/%E5%87%BA%E7%89%88-%E8%B3%BC%E8%AA%AD%E5%9E%8B%E3%83%A2%E3%83%87%E3%83%AB
[pg]: https://www.erlang.org/doc/man/pg.html
