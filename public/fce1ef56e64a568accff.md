---
title: Elixirをデコンパイル（逆コンパイル）
tags:
  - Elixir
  - コンパイル
  - デコンパイル
  - 40代駆け出しエンジニア
  - AdventCalendar2022
private: false
updated_at: '2022-12-07T22:05:56+09:00'
id: fce1ef56e64a568accff
organization_url_name: fukuokaex
slide: false
---

[逆コンパイル]: https://ja.wikipedia.org/wiki/%E9%80%86%E3%82%B3%E3%83%B3%E3%83%91%E3%82%A4%E3%83%A9
[Elixir]: https://elixir-lang.org/
[Erlang]: https://www.erlang.org/
[Phoenix]: https://www.phoenixframework.org/
[Nerves]: https://hexdocs.pm/nerves
[Livebook]: https://livebook.dev/
[IEx]: https://elixirschool.com/ja/lessons/basics/basics/#%E5%AF%BE%E8%A9%B1%E3%83%A2%E3%83%BC%E3%83%89
[Mix.Project]: https://hexdocs.pm/mix/Mix.Project.html
[Mix.Project.config/0]: https://hexdocs.pm/mix/Mix.Project.html#config/0
[Mix.Projec - Invoking this module]: https://hexdocs.pm/mix/Mix.Project.html#module-invoking-this-module
[Application.get_all_env/1]: https://hexdocs.pm/elixir/Application.html#get_all_env/1
[Application.get_env/3]: https://hexdocs.pm/elixir/Application.html#get_env/3
[Application.compile_env!/2]: https://hexdocs.pm/elixir/Application.html#compile_env!/2
[Module attributes]: https://elixir-lang.org/getting-started/module-attributes.html#as-constants
[michalmuskala/decompile]: https://github.com/michalmuskala/decompile
[ElixirのSlack]: https://elixir-slackin.herokuapp.com/

ある日[ElixirのSlack]にて、コンパイルされた[Elixir]モジュールを[逆コンパイル]する方法を見かけたので、遊んでみます。

https://qiita.com/torifukukaiou/items/17d55cf896c24b13350e

## 論よりRUN

### [michalmuskala/decompile]をインストールする

```
mix archive.install github michalmuskala/decompile
```

### Elixirプロジェクトを作る

```sh
❯ mix new toukon

❯ cd toukon

❯ ls
README.md lib       mix.exs   test

❯ cat lib/toukon.ex
defmodule Toukon do
  @moduledoc """
  Documentation for `Toukon`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Toukon.hello()
      :world

  """
  def hello do
    :world
  end
end
```

### コンパイルする

```sh
❯ mix compile

❯ ls
README.md _build    lib       mix.exs   test

❯ tree _build
_build
└── dev
    └── lib
        └── toukon
            ├── consolidated
            │   ├── Elixir.Collectable.beam
            │   ├── Elixir.Enumerable.beam
            │   ├── Elixir.Hex.Solver.Constraint.beam
            │   ├── Elixir.IEx.Info.beam
            │   ├── Elixir.Inspect.beam
            │   ├── Elixir.List.Chars.beam
            │   └── Elixir.String.Chars.beam
            └── ebin
                ├── Elixir.Toukon.beam
                └── toukon.app
```

### 逆コンパイルする

```sh
❯ mix decompile Toukon --to expanded

❯ ls
Elixir.Toukon.ex README.md        _build           lib              mix.exs          test

❯ cat Elixir.Toukon.ex
defmodule Toukon do
  def hello() do
    :world
  end
end
```

## ご参考までに

https://qiita.com/piacerex/items/e0b6e46b1325bb931122

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

https://qiita.com/piacerex/items/e5590fa287d3c89eeebf
