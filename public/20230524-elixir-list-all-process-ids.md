---
title: Elixir 全プロセスIDのリストを取得
tags:
  - Erlang
  - Elixir
  - iex
  - 分散システム
  - Livebook
private: false
updated_at: '2023-09-03T05:51:35+09:00'
id: 990be2c72cb526681d0b
organization_url_name: fukuokaex
slide: false
---

[elixir]で開発しているときに[プロセスID][Processes]を見失ってしまうことはないでしょうか。そういうときはとりあえず全プロセスIDのリストの取得すると何か手がかりが見つかるかもしれません。

https://qiita.com/torifukukaiou/items/17d55cf896c24b13350e

この記事を読んで知りました。

https://samuelmullen.com/articles/elixir-processes-observability/

<!-- begin hyperlink list -->

[elixir]: https://elixir-lang.org/
[erlang]: https://www.erlang.org/
[phoenix]: https://www.phoenixframework.org/
[nerves]: https://hexdocs.pm/nerves
[livebook]: https://livebook.dev/
[iex]: https://elixirschool.com/ja/lessons/basics/basics/#%E5%AF%BE%E8%A9%B1%E3%83%A2%E3%83%BC%E3%83%89
[GenServer]: https://hexdocs.pm/elixir/GenServer.html
[ETS]: https://elixir-lang.org/getting-started/mix-otp/ets.html
[Erlangの公式ドキュメント]: https://www.erlang.org/doc/man/ets.html
[Elixir School]: https://elixirschool.com/ja/lessons/storage/ets
[:ets.fun2ms/1]: https://www.erlang.org/doc/man/ets.html#fun2ms-1
[Match Spec]: https://www.erlang.org/doc/apps/erts/match_spec.html
[ex2ms]: https://hex.pm/packages/ex2ms
[Ex2ms.fun/1]: https://hexdocs.pm/ex2ms/Ex2ms.html#fun/1
[:sys.get_state/1]: https://www.erlang.org/doc/man/sys.html#get_state-1
[Map]: https://hexdocs.pm/elixir/Map.html
[Process.list/0]: https://hexdocs.pm/elixir/Process.html#list/0
[Process.info/2]: https://hexdocs.pm/elixir/Process.html#info/2
[Processes]: https://elixir-lang.org/getting-started/processes.html
<!-- end hyperlink list -->

## 論よりRUN (IEx)

早速[IEx]を開きます。

```bash:terminal
iex
```

[IEx]が印字できるリスト長の制限を無効化。デフォルトでは50個まで。

```elixir:IEx
IEx.configure inspect: [limit: :infinity]
```

現在の環境で存在している全てのプロセスIDを取得する。
[Process.list/0]と[Process.info/2]を組み合わせて有用な情報を取得。

```elixir:IEx
for pid <- Process.list() do
  {_, registered_name} = Process.info(pid, :registered_name)
  {pid, registered_name}
end
```

![](https://user-images.githubusercontent.com/7563926/240624656-8455a80c-e509-4fa3-b39c-c1551918dee8.png)

## 論よりRUN (Livebook)

Livebook で RUN する場合は、Kino のデータテーブルを使うと結果が見やすくなります。

```elixir:Livebook
Mix.install([{:kino, "~> 0.10.0"}])

Process.list()
|> Enum.map(fn pid -> [{:pid, pid}, Process.info(pid, :registered_name)] end)
|> Kino.DataTable.new()
```

![CleanShot 2023-05-24 at 09.42.44.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/b75f7509-943b-8b32-c963-c4e1c1bb5cd1.png)

## ご参考までに

https://qiita.com/piacerex/items/e0b6e46b1325bb931122

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

https://qiita.com/piacerex/items/e5590fa287d3c89eeebf
