---
title: 'Elixir/Nerves: GenServerでLivebook上の記号を点滅させる'
tags:
  - Elixir
  - Unicode
  - Nerves
  - Livebook
private: false
updated_at: '2024-07-24T18:15:08+09:00'
id: 89d50244f7ca783f686c
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

[Kino]: https://hexdocs.pm/kino/Kino.html
[Kino.Frame]: https://hexdocs.pm/kino/Kino.Frame.html
[Livebook]: https://livebook.dev/
[Elixir]: https://elixir-lang.org/
[Nerves]: https://nerves-project.org/
[Nerves Livebook]: https://github.com/nerves-livebook/nerves_livebook
[GenServer]: https://hexdocs.pm/elixir/GenServer.html
[circuits_gpio]: https://hexdocs.pm/circuits_gpio/readme.html
[GPIO]: https://en.wikipedia.org/wiki/General-purpose_input/output
[myasu]: https://twitter.com/etcinitd
[nako_sleep_9h]: https://twitter.com/nako_sleep_9h
[Unicode]: https://ja.wikipedia.org/wiki/Unicode
[ブレッドボード]: https://ja.wikipedia.org/wiki/%E3%83%96%E3%83%AC%E3%83%83%E3%83%89%E3%83%9C%E3%83%BC%E3%83%89
[:global]: https://www.erlang.org/doc/apps/kernel/global.html

## はじめに

先日、「[GenServer でブレットボード上の LED を点滅させる](https://qiita.com/mnishiguchi/items/ad5199c6dc19e5fc4769)」ということを楽しみました。

https://qiita.com/mnishiguchi/items/ad5199c6dc19e5fc4769

早速、読者の@zacky1972 さんから[お便り](https://qiita.com/mnishiguchi/items/ad5199c6dc19e5fc4769#comment-d299d12e174efd15650d)をいただきました。有難うございます。

> 記事ありがとうございます！
>
> 本記事の拡張として，複数の LED それぞれを，異なる周期で点滅できると，たとえばリズムマシンみたいなものを作ることができそうで楽しそうです．

いただいたアイデアから着想を得て、先日書いたコードをちょこっと拡張してみました。

## やること

- 永久に点滅させるロジックを備えた [GenServer] を書く
- [GenServer] のワーカープロセスを任意の名前で登録できるようにする
- [ブレッドボード]上の LED の代わりに、[Livebook] 上で Unicode の記号を使って点滅アニメーションを描画する

![fake-blinky-on-livebook 2024-06-25 at 16.37.08.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/895ca1fd-cad8-5a33-79bb-093a889f5373.gif)

## LED の代わりに使う Unicode の記号

[ブレッドボード]上の LED の代わりに[Unicode]の記号を使ってアニメーション効果で点滅を表現してみようと思います。LED っぽい円形の記号を使ってみます。円形の記号は「Unicode 25A0-25FF Geometric Shapes」にいくつかありました。

[![](https://upload.wikimedia.org/wikipedia/commons/4/4c/UCB_Geometric_Shapes.png)](https://commons.wikimedia.org/wiki/Unicode_circle_shaped_symbols)

## Livebook

今回は [GPIO] を使わないので Raspberry Pi で動く[Nerves Livebook] ではなく、MacBook 上の普通の [Livebook] を使おうと思います。

## Kino

> Client-driven interactive widgets for Livebook.
>
> Kino is the library used by Livebook to render rich and interactive outputs directly from your Elixir code.

[Kino]を使うと[Livebook]上で[Elixir] コードから対話形式の出力をレンダリングさせることができるそうです。ここでは[Kino.Frame]を使ってアニメーション効果で LED が点滅しているような見た目を表現してみようと思います。

https://github.com/livebook-dev/livebook/blob/e414e5557c679ef7f4dd39e8939cfc1c4f43ef18/lib/livebook/notebook/learn/kino/intro_to_kino.livemd?plain=1#L11

## GenServer のプロセスを登録する方法

[GenServer]にはいろんな使い方がありますが、今回は[:global]モジュールを使ってプロセスに名前をつけて登録します。

https://hexdocs.pm/elixir/GenServer.html#module-name-registration

https://qiita.com/mnishiguchi/items/833a6e14511f084438d1

## Kino.Frame の操作をモジュールにまとめる

[前回](https://qiita.com/mnishiguchi/items/ad5199c6dc19e5fc4769)、[circuits_gpio]を使って [GPIO]を操作したときのと同じインターフェースにしました。

```elixir
defmodule KinoBlink do
  def open(name) do
    kino_frame = Kino.Frame.new()
    Kino.render(kino_frame)

    {:ok, {name, kino_frame}}
  end

  def close(_name) do
    :ok
  end

  def toggle({name, kino_frame}, 1), do: off({name, kino_frame})
  def toggle({name, kino_frame}, 0), do: on({name, kino_frame})
  def toggle({name, kino_frame}, _), do: on({name, kino_frame})

  def on({name, kino_frame}) do
    Kino.Frame.render(kino_frame, "#{name}  ◉︎")

    {:ok, 1}
  end

  def off({name, kino_frame}) do
    Kino.Frame.render(kino_frame, "#{name}  ◎︎")

    {:ok, 0}
  end
end
```

## GenServer

```elixir
defmodule BlinkServer do
  use GenServer, restart: :temporary

  require Logger

  @run_interval_ms 1000

  ## global process registry

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

  ## Client

  @doc """
  Start a BlinkServer for the provided GPIO pin. It lets the LED blink forever.

  ### Examples

      iex>  BlinkServer.start_link(led_pin: "GPIO17")

  """
  def start_link(opts) do
    led_pin = Access.fetch!(opts, :led_pin)

    case whereis(led_pin) do
      nil ->
        {:ok, pid} = GenServer.start_link(__MODULE__, opts, [])
        register_process(pid, led_pin)

      pid ->
        {:ok, pid}
    end
  end

  @doc """
  Stop a running BlinkServer for the provided GPIO pin.

  ### Examples

      iex>  BlinkServer.stop("GPIO17")

  """
  def stop(led_pin) do
    case whereis(led_pin) do
      nil ->
        {:error, :process_not_found}

      pid ->
        GenServer.stop(pid)
    end
  end

  ## Callbacks

  @impl true
  def init(opts) do
    led_pin = Access.fetch!(opts, :led_pin)

    initial_state = %{
      gpio_ref: nil,
      led_state: 0,
      led_pin: led_pin
    }

    {:ok, initial_state, {:continue, :init_gpio}}
  end

  @impl true
  def handle_continue(:init_gpio, state) do
    case KinoBlink.open(state.led_pin) do
      {:ok, gpio_ref} ->
        new_state = %{state | gpio_ref: gpio_ref}

        send(self(), :toggle_led_state)

        {:noreply, new_state}

      {:error, error} ->
        {:stop, error}
    end
  end

  @impl true
  def handle_info(:toggle_led_state, state) do
    {:ok, new_led_state} = KinoBlink.toggle(state.gpio_ref, state.led_state)

    new_state = %{state | led_state: new_led_state}

    Process.send_after(self(), :toggle_led_state, @run_interval_ms)

    {:noreply, new_state}
  end

  @impl true
  def terminate(reason, state) do
    KinoBlink.close(state.gpio_ref)
    Logger.debug("terminated #{state.led_pin}: #{reason}")

    :ok
  end
end
```

## 論より Run

```elixir
Logger.configure(level: :debug)

led_pins = ["GPIO15", "GPIO16", "GPIO17", "GPIO18"]

for led_pin <- led_pins do
  BlinkServer.start_link(led_pin: led_pin)
  Process.sleep(250)
end

Process.sleep(10_000)

for led_pin <- led_pins do
  BlinkServer.stop(led_pin)
end
```

## Wrapping up

LED 点滅のような簡単な制御であれば、こんな感じでハードウエアなしに [Livebook] 上でテストできそうですね！

:tada::tada::tada:
