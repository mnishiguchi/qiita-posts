---
title: Elixir GenServerのプロセスをどう管理するか
tags:
  - Erlang
  - Elixir
  - OTP
  - GenServer
private: false
updated_at: '2023-09-03T21:23:58+09:00'
id: 833a6e14511f084438d1
organization_url_name: fukuokaex
slide: false
---
本記事は[「Elixir Advent Calendar 2020」](https://qiita.com/advent-calendar/2020/elixir)の14日目です。

前日は@Sadalsuudさんの「[ElixirからOpenGLを使って3D空間に描画をする](https://qiita.com/Sadalsuud/items/b393bfbdd566ea08ff56)」でした。

本日は、ElixirのGenServerのプロセスをどう管理するかについてまとめてみようと思います。

## はじめに

さて、ElixirのGenServerについて学んだとき、ある程度のところまではスムーズにいったのですが、いくつかモヤモヤすることがありました。
その一つが「GenServerのプロセスをどう管理するか」でした。色々調べて分かってきたので、メモを整理がてらの投稿です。

アイデアの多くは「[Elixir in Action by Saša Juric](https://www.manning.com/books/elixir-in-action-third-edition)」で学んだものですが、勉強のためサンプルコードは手作りしました。

## 色んなプロセス管理方法

### pidを覚えておく

- `GenServer.start_link`の戻り値のpidを何らかの方法で覚えておき、それを用いてプロセスにアクセス
- ひとつのモジュールでいくつでもプロセス生成可能
- プロセスが何らかで停止し、新たに生成された場合、そのpidは使い物にならなくなる

```elixir
defmodule MyGenkiServerBasic do
  use GenServer

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, [], [])
  end

  def hello(pid) do
    GenServer.call(pid, :hello)
  end

  @impl true
  def init(_args) do
    {:ok, "闘魂"}
  end

  @impl true
  def handle_call(:hello, _from, state) do
    {:reply, "元氣ですか #{inspect(self())}", state}
  end
end
```

```elixir
# プロセス起動し、pidを覚えておく。
iex> {:ok, pid} = MyGenkiServerBasic.start_link()
{:ok, #PID<0.111.0>}

# 覚えておいたpidでプロセスにアクセス。
iex> MyGenkiServerBasic.hello(pid)
"元氣ですか"
```

### モジュールのアトムをローカル名として登録

- プロセスが一つしかいらない場合に使えるパターン
- ローカル名はどんなアトムでも良いが、モジュールのアトム（`__MODULE__`）がよく使われる
- ローカル名は分散クラスタを想定しておらず、一つのVMの中でのみ使える

```elixir
defmodule MyGenkiServerLocalName do
  use GenServer

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def hello do
    GenServer.call(__MODULE__, :hello)
  end

  @impl true
  def init(_args) do
    {:ok, "闘魂"}
  end

  @impl true
  def handle_call(:hello, _from, state) do
    {:reply, "元氣ですか #{inspect(self())}", state}
  end
end
```

```elixir
# プロセス起動
iex> MyGenkiServerLocalName.start_link()
{:ok, #PID<0.205.0>}

# プロセスがモジュール名で登録されているので、pidがなくてもプロセスにアクセス可能
iex> MyGenkiServerLocalName.hello()
"元氣ですか"

# ただし、プロセスはひとつしか生成できない
iex> MyGenkiServerLocalName.start_link()
{:error, {:already_started, #PID<0.205.0>}}
```

### 動的に生成されたアトムをローカル名として登録（アンチパターン？）

複数のプロセスを登録したい場合にどうしたら良いのか悩みました。自分で一意のアトムを生成したらローカル名として使えそうな気がしますが、Erlangにはアプリが生成できるアトムの数に上限があるので注意が必要です。アトムは一度生成されるとガーべジコレクトされないので、アトムをIDとして無数に生成できるというのはあまり好ましくなさそうです。

```elixir
# アトム数の上限
iex> :erlang.system_info(:atom_limit)
1048576
```

前もって、いくつくらいプロセスを生成したいのが分かってる場合はこれでもいいかのもしれません。

```elixir
defmodule MyGenkiServerDynamicName do
  use GenServer

  def process_name(id) do
    String.to_atom("#{__MODULE__}_#{id}")
  end

  def start_link(id) do
    GenServer.start_link(__MODULE__, [], name: process_name(id))
  end

  def hello(id) do
    GenServer.call(process_name(id), :hello)
  end

  @impl true
  def init(_args) do
    {:ok, "闘魂"}
  end

  @impl true
  def handle_call(:hello, _from, state) do
    {:reply, "元氣ですか #{inspect(self())}", state}
  end
end
```

```elixir
# 現時点で存在するアトム数
iex> :erlang.system_info(:atom_count)
15802

# プロセスを1000個スタート
(0..999) |> Enum.each(fn x -> MyGenkiServerDynamicName.start_link(x) end)

# アトムが大量に生成される
iex> :erlang.system_info(:atom_count)
16969

# プロセスにアクセスできることを確認
iex> MyGenkiServerDynamicName.hello(1)
"元氣ですか"

iex> MyGenkiServerDynamicName.hello(2)
"元氣ですか"
```

### `Registry`と`via_tuple`を使用する

- `Registry`に複合キー`via_tuple`でプロセスを登録することにより、`via_tuple`でプロセスにアクセス可能
- `via_tuple`という関数名が慣例のようだが、別の関数名でもOK
- `Registry`では複合キーでプロセスを登録できるので、動的にアトムを生成することが不要
- `Registry`のプロセスを先に起動させておくことが必要

```elixir
defmodule MyProcessRegistry do
  def via_tuple(key) when is_tuple(key) do
    {:via, Registry, {__MODULE__, key}}
  end

  def whereis_name(key) when is_tuple(key) do
    Registry.whereis_name({__MODULE__, key})
  end

  def start_link() do
    Registry.start_link(keys: :unique, name: __MODULE__)
  end
end

defmodule MyGenkiServerViaTuple do
  use GenServer

  def via_tuple(id) do
    MyProcessRegistry.via_tuple({__MODULE__, id})
  end

  def whereis(id) do
    case MyProcessRegistry.whereis_name({__MODULE__, id}) do
      :undefined -> nil
      pid -> pid
    end
  end

  def start_link(id) do
    GenServer.start_link(__MODULE__, [], name: via_tuple(id))
  end

  def hello(id) do
    GenServer.call(via_tuple(id), :hello)
  end

  @impl true
  def init(_args) do
    {:ok, "闘魂"}
  end

  @impl true
  def handle_call(:hello, _from, state) do
    {:reply, "元氣ですか #{inspect(self())}", state}
  end
end
```

```elixir
# 現時点で存在するアトム数
iex> :erlang.system_info(:atom_count)
15807

# Registryのプロセスを起動
iex> MyProcessRegistry.start_link()
{:ok, #PID<0.421.0>}

# プロセスを1000個スタート
iex> (0..999) |> Enum.each(fn x -> MyGenkiServerViaTuple.start_link(x) end)
:ok

# （動的アトム使用時と比較して）アトムの生成が抑えられているのを確認
iex> :erlang.system_info(:atom_count)
16019

# プロセスにアクセスできることを確認
iex> MyGenkiServerViaTuple.hello(1)
"元氣ですか"

iex> MyGenkiServerViaTuple.hello(2)
"元氣ですか"
```

### グローバル名で登録

- 複数ノード間で安全にプロセスを共有できる
- クラスター全体にロックがかかるらしい

```elixir
defmodule MyGenkiServerGlobalName do
  use GenServer

  def whereis(id) do
    case :global.whereis_name({__MODULE__, id}) do
      :undefined -> nil
      pid -> pid
    end
  end

  def register_process(pid, id) do
    case :global.register_name({__MODULE__, id}, pid) do
      :yes -> {:ok, pid}
      :no -> {:error, {:already_started, pid}}
    end
  end

  def start_link(id) do
    case whereis(id) do
      nil ->
        {:ok, pid} = GenServer.start_link(__MODULE__, [], [])
        register_process(pid, id)
      pid ->
        {:ok, pid}
    end
  end

  def hello(id) do
    GenServer.call(whereis(id), :hello)
  end

  @impl true
  def init(_args) do
    {:ok, "闘魂"}
  end

  @impl true
  def handle_call(:hello, _from, state) do
    {:reply, "元氣ですか #{inspect(self())}", state}
  end
end
```

ターミナルを２つ使用し、それぞれノード名を指定しIEXシェルを起動。

```elixir
# node1起動
iex --sname node1@localhost
```

```elixir
# node2起動
iex --sname node2@localhost

# node2をnode1に接続すると、それらが一つのクラスタになる。
iex(node2@localhost)> Node.connect(:node1@localhost)
true
```

それぞれのIEXにサンプルコードをコピペし、プロセスが複数のノード（VM）で共有されていることを確認。

<img width="1286" alt="Screen Shot 2020-12-10 at 8 55 20 AM" src="https://user-images.githubusercontent.com/7563926/101781881-5d688a80-3ac6-11eb-86c2-ef130045e85f.png">

## さいごに

きれいにまとまったと自負しています。迷ったらここに来たらいいと思うと気が楽になります。

「[Elixir その2 Advent Calendar 2020](https://qiita.com/advent-calendar/2020/elixir2)」に勉強していて個人的に大事と思った内容を共有しているのでよかったらそちらも御覧ください。本日は「[Elixirの"Hello"と'Hello'](https://qiita.com/mnishiguchi/items/ca56167faee1ceb16c00)」です。

明日は@ringo156さんの「[ElixirでTwitterのbotを作る](https://qiita.com/ringo156/items/79df06dad2c103aa6772)」です。引き続き、Elixirを楽しみましょう。

Happy coding!

- [Elixir その1 Advent Calendar 2020](https://qiita.com/advent-calendar/2020/elixir)
- [Elixir その2 Advent Calendar 2020](https://qiita.com/advent-calendar/2020/elixir2)

## 参考文献

- [Elixir in Action by Saša Jurić - Chapter 12](https://www.manning.com/books/elixir-in-action-second-edition)
- [Converting strings to atoms safely by TODAY I LEARNED](https://til.hashrocket.com/posts/gkwwfy9xvw-converting-strings-to-atoms-safely)
- [Current number of atoms in the atoms table by TODAY I LEARNED](https://til.hashrocket.com/posts/b9giaqz4lc-current-number-of-atoms-in-the-atoms-table)
- [How to start processes with dynamic names in Elixir by Thoughtbot](https://thoughtbot.com/blog/how-to-start-processes-with-dynamic-names-in-elixir)
