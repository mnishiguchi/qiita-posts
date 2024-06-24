---
title: 'Elixir/Nerves: GenServerでブレットボード上のLEDを点滅させる'
tags:
  - RaspberryPi
  - Elixir
  - IoT
  - Nerves
private: false
updated_at: '2024-06-24T18:50:08+09:00'
id: ad5199c6dc19e5fc4769
organization_url_name: null
slide: false
ignorePublish: false
---

[Elixir]: https://elixir-lang.org/
[Nerves]: https://nerves-project.org/
[Nerves Livebook]: https://github.com/nerves-livebook/nerves_livebook
[GenServer]: https://hexdocs.pm/elixir/GenServer.html
[circuits_gpio]: https://hexdocs.pm/circuits_gpio/readme.html
[GPIO]: https://en.wikipedia.org/wiki/General-purpose_input/output
[myasu]: https://twitter.com/etcinitd
[nako_sleep_9h]: https://twitter.com/nako_sleep_9h

## はじめに

[Nerves] を初めて学ぶとき、ブレッドボード上で LED を点滅させたくなることがあると思います。

やり方は色々考えられますが、今日は [GenServer] を使用した簡単な実装に挑戦してみたいと思います。

本記事は、先週末に参加したイベントでの成果です。[Nerves] 愛好家と東京の秋葉原で買い物を楽しみ、[Nerves]を使った IoT デバイス開発について学びました。主催者の[myasu]さん と [nako_sleep_9h]さんに心から感謝します!

https://piyopiyoex.connpass.com/event/317734

[myasu] さんは電気電子工学についてとても詳しい方で、秋葉原を散策しながら色々教えていただきました。大変勉強になりました。また、[myasu] さんが執筆された Nerves 開発の入門書もあります。

[![](https://nextpublishing.jp/wp-content/uploads/2023/11/N01905.jpg)](https://nextpublishing.jp/book/17353.html)

[nako_sleep_9h] さんは、日本各地で元氣になる楽しい技術イベント（オンライン及びオフライン）を企画し、また司会も務められています。

https://qiita.com/nako_sleep_9h/items/8956a061b014f11cc65c

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">めでたい、光った光った〜<a href="https://twitter.com/hashtag/piyopiyoex?src=hash&amp;ref_src=twsrc%5Etfw">#piyopiyoex</a> <a href="https://t.co/5WBqnFftQU">pic.twitter.com/5WBqnFftQU</a></p>&mdash; nako@9時間睡眠 (@nako_sleep_9h) <a href="https://twitter.com/nako_sleep_9h/status/1804441299258359890?ref_src=twsrc%5Etfw">June 22, 2024</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

## Nerves Livebook

[Nerves] をプラットフォームとして IoT プロジェクトを始めるにはいくつかの方法がありますが、最も簡単な方法の 1 つは、ビルド済みの [Nerves Livebook] ファームウェアを使用することです。[Nerves Livebook] を使用すると、Web ブラウザー上で [Elixir] コーディングを行いながら、Raspberry Pi などのターゲット デバイスを制御できます。

有志の方々が [Nerves Livebook] のセットアップ方法ついてのビデオを制作してくださっています。ありがとうございます。

https://youtu.be/-c4VJpRaIl4?si=XV26RifdxSjKog_L

https://youtu.be/-b5TPb_MwQE?si=nL43DmK7RNIQjOu5

## circuits_gpio を使って LED を操作

[circuits_gpio] は、[Elixir] コードで [GPIO] を制御できるようにするものです。

[Nerves Livebook] には、[circuits_gpio] パッケージを使用して [GPIO] を出力として制御し、LED を点滅させる方法についての良いチュートリアル ノートブックがあります。作業に取り掛かる前に、最低限必要な電気部品と、それらの配線方法を示しています。

https://github.com/nerves-livebook/nerves_livebook/blob/main/priv/samples/basics/blink.livemd

## LED 点滅ロジックを GenServer でラップ

点滅を永遠に繰り返したいが、デバイスを再起動せずにある段階で停止したい場合、LED の点滅を管理する [GenServer] を用意すると便利です。

まず、[GPIO] 関連のロジックをラップする簡単なモジュールを作成し、LED を操作するための関数を定義します。

```elixir
defmodule LedBlink do
  def open(led_pin) do
    Circuits.GPIO.open(led_pin, :output)
  end

  def close(led_pin) do
    Circuits.GPIO.close(led_pin)
  end

  def toggle(gpio, 1), do: off(gpio)
  def toggle(gpio, 0), do: on(gpio)
  def toggle(gpio, _), do: on(gpio)

  def on(gpio) do
    :ok = Circuits.GPIO.write(gpio, 1)

    {:ok, 1}
  end

  def off(gpio) do
    :ok = Circuits.GPIO.write(gpio, 0)

    {:ok, 0}
  end
end
```

次に、LED を永久に点滅させる[GenServer]を作成します。

```elixir
defmodule BlinkServer do
  use GenServer, restart: :temporary

  require Logger

  @run_interval_ms 1000

  ## Client

  @doc """
  Start a BlinkServer for the provided GPIO pin. It lets the LED blink forever.

  ### Examples

      iex>  BlinkServer.start_link(led_pin: "GPIO17")

  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def stop() do
    GenServer.stop(__MODULE__)
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
    case LedBlink.open(state.led_pin) do
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
    {:ok, new_led_state} = LedBlink.toggle(state.gpio_ref, state.led_state)

    new_state = %{state | led_state: new_led_state}
    Logger.debug("toggled LED: #{new_state.led_state}")

    Process.send_after(self(), :toggle_led_state, @run_interval_ms)

    {:noreply, new_state}
  end

  @impl true
  def terminate(reason, state) do
    LedBlink.close(state.gpio_ref)
    Logger.debug("terminated: #{reason}")

    :ok
  end
end
```

## 論より Run

`BlinkServer` の使用方法は次のとおりです。

`BlinkServer` を起動するときに、LED の繋がっている GPIO ピンを指定します。

実行中の `BlinkServer` ワーカーを停止することもできます。

```elixir
Logger.configure(level: :debug)

BlinkServer.start_link(led_pin: "GPIO17")

Process.sleep(10_000)

BlinkServer.stop()
```

今回の `BlinkServer` の実装はシングルトンの [GenServer] です。つまり、複数の `BlinkServer` ワーカーを起動することはできません。そのため、たとえば使用する [GPIO] ピンを変更する場合は、ワーカーを停止し、異なるオプションで新しいワーカーを起動する必要があります。

## Wrapping up

LED を点滅させるシンプルな [GenServer] を作成しました。

世の中にはいろんな LED 点滅のロジックや楽しみ方があります。あなたもぜひ共有してみてください！

https://qiita.com/RyoWakabayashi/items/143fda67a1798bd788b7

https://qiita.com/RyoWakabayashi/items/8119260ceeea462d6b7b

https://qiita.com/RyoWakabayashi/items/281afab89249dbf68cd5

https://qiita.com/GeekMasahiro/items/83b5d51b77e92e3979cc

https://qiita.com/GeekMasahiro/items/837d4e786746b4def02b

https://qiita.com/torifukukaiou/items/91441a14dcf66472af39

https://qiita.com/torifukukaiou/items/2f7c9f460fde510356e8
