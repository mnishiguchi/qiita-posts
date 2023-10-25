---
title: Elixir libcluster ゴシッププロトコルで複数の分散ノードを自動接続
tags:
  - Erlang
  - Elixir
  - 分散システム
  - libcluster
private: false
updated_at: '2023-08-22T22:17:00+09:00'
id: e854de2626028b9ea830
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---


[Elixir]プログラミングに慣れてくると必ず試してみたくなるのが[OTP の分散機能][elixir school jp otp distribution]だと思います。巷にあるサンプルコードでは[Node.connnect/1]や[Node.ping/1]等を用いて手動でノードを接続するパターンが多いと思いますが、[libcluster]の[Cluster.Strategy.Gossip]を使うと簡単にノードの自動接続ができます。

これから[Elixir]を始める方にはこのサイトがおすすめです。

https://elixir-lang.info/

[Elixir]とコミュニティの雰囲気をゆるく味わいたい方は「先端ピアちゃん」さんの動画が超オススメです。

https://www.youtube.com/@piacerex

## ゴシッププロトコル

> ゴシッププロトコルではランダムに選んだ相手と情報を交換し、自身が持つデータの更新を繰り返す。システムの参加者が不定期的に増減して全体を把握できない状況や、一時的に通信できない場合でも情報を伝搬できる。病気が伝染する様子に似ていることから、エピデミックアルゴリズムとも呼ばれる。--- [ウィキペディア][wiki ja Gossip protocol]

[P2P ネットワーク][wiki ja p2p]で使われるプロトコルらしい。知らんけど。

## libcluster

> This library provides a mechanism for automatically forming clusters of Erlang nodes, with either static or dynamic node membership. It provides a pluggable "strategy" system, with a variety of strategies provided out of the box.

- Erlang ノードのクラスターを自動的に形成するメカニズムを提供
- 静的または動的なノード組織構造に対応可能
- [クラスタリング戦略]システムを提供

https://github.com/bitwalker/libcluster

## Cluster.Strategy.Gossip

[libcluster]で[ゴシッププロトコル][wiki ja Gossip protocol]を使いたい時に使う[クラスタリング戦略]。

いくつか要点を挙げます。

- 同じ[Erlangマジッククッキー]を共有している場合にのみ、それらの間で接続が確立される
- ノードのクラスターが動的に形成される
- 初期設定では暗号化されないが、[クラスタリング戦略]の設定で秘密（`:secret`）を指定することで暗号化が可能

https://hexdocs.pm/libcluster/Cluster.Strategy.Gossip.html

https://www.erlang.org/doc/reference_manual/distributed.html#security

https://ja.wikipedia.org/wiki/マジッククッキー

## 実験

### Elixirプロジェクトを準備

任意のディレクトリで[mix new]コマンドを打ち、実験用のElixirプロジェクトを作ります。

`--sup`オプションをつけると[監視ツリー][elixir school jp otp supervisor]を含むOTPアプリの骨格を生成できます。

```bash
cd path/to/my/workspaces

mix new hello_bunsan --sup
```

### libclusterの設定

お好みのテキストエディターで作ったプロジェクトを開きます。

```bash
cd hello_bunsan

code .
```

`mix.exs`ファイルの依存パッケージリストに[libcluster]を追加します。

```diff_elixir:mix.exs
...
   defp deps do
     [
+      {:libcluster, "~> 3.3"}
     ]
   end
...
```

`lib/hello_bunsan/application.exs`ファイルで[libcluster]の設定を追加します。

```diff_elixir:application.ex
 defmodule HelloBunsan.Application do
   use Application

   @impl true
   def start(_type, _args) do
+    topologies = [
+      gossip_example: [
+        strategy: Cluster.Strategy.Gossip,
+        secret: "my-secret"
+      ]
+    ]

     children = [
+      {Cluster.Supervisor, [topologies, [name: HelloBunsan.ClusterSupervisor]]},
     ]

     opts = [strategy: :one_for_one, name: HelloBunsan.Supervisor]
     Supervisor.start_link(children, opts)
   end
 end
```

### 分散ノードを起動

任意のターミナルでクッキーを指定してElixirアプリとともに`hoge`ノードを起動します。

- `iex`コマンドで[対話Elixirシェル](IEx)を起動
- `--sname hoge`オプションをつけると、`hoge`という名称のノードを起動
- `--cookie genki`オプションをつけると、[Erlangマジッククッキー]を`genki`に設定
- `-S mix`オプションをつけると、Elixirアプリを起動

```bash:terminal1
cd path/to/hello_bunsan

iex --sname hoge --cookie genki -S mix
```

別のターミナルを開きノード名だけ変えて同様の操作をします。

```bash:terminal2
cd path/to/hello_bunsan

iex --sname piyo --cookie genki -S mix
```

これだけで、これらのノードは自動的に接続されます。[Node.list/0]で接続されているノードを確認できます。

```elixir
Node.list
```

:tada::tada::tada:

## 本番環境

ゴシップ戦略はノードで遊ぶ時には便利ですが、本番環境では明示的にノード接続した方が無難かもしれません。

[Cluster.Strategy.Epmd]を使って`:host`オプションで接続するメンバーノード（自分のノードを除く）を指定するとそれらだけに接続することができます。

[Cluster.Strategy.Kubernetes]を使ったやり方はこの記事が参考になるかもしれません。

https://qiita.com/mokichi/items/c3157804faa295ce1574

[Cluster.Strategy.DNSPoll]を使った例もあります。

https://qiita.com/RyoWakabayashi/items/b6888b510b20bb7579e8

## 資料

今回の内容についてはこれらの資料が参考になりました。オススメです。他にもいい情報があればぜひお便りください。

https://til.verschooten.name/til/2023-08-13/lets-talk

https://www.youtube.com/watch?v=zQEgEnjuQsU

[Elixir]: https://elixir-lang.org
[wiki ja p2p]: https://ja.wikipedia.org/wiki/Peer_to_Peer
[wiki ja Gossip protocol]: https://ja.wikipedia.org/wiki/ゴシッププロトコル
[libcluster]: https://github.com/bitwalker/libcluster
[クラスタリング戦略]: https://github.com/bitwalker/libcluster#clustering
[Cluster.Strategy.Gossip]: https://hexdocs.pm/libcluster/Cluster.Strategy.Gossip.html
[Cluster.Strategy.Epmd]: https://hexdocs.pm/libcluster/Cluster.Strategy.Epmd.html
[Cluster.Strategy.Kubernetes]: https://hexdocs.pm/libcluster/Cluster.Strategy.Kubernetes.html
[Cluster.Strategy.DNSPoll]: https://hexdocs.pm/libcluster/Cluster.Strategy.DNSPoll.html
[elixir school jp otp supervisor]: https://elixirschool.com/ja/lessons/advanced/otp_supervisors
[elixir school jp otp distribution]: https://elixirschool.com/ja/lessons/advanced/otp_distribution
[Node.connnect/1]: https://hexdocs.pm/elixir/Node.html#connect/1
[Node.ping/1]: https://hexdocs.pm/elixir/Node.html#ping/1
[Node.list/0]: https://hexdocs.pm/elixir/Node.html#list/0
[Erlangマジッククッキー]: https://www.erlang.org/doc/reference_manual/distributed.html#security
[mix new]: https://hexdocs.pm/mix/Mix.Tasks.New.html
[対話Elixirシェル]: https://elixirschool.com/ja/lessons/basics/basics#対話モード-2
