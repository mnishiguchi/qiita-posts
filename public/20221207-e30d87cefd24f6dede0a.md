---
title: 'Elixir :inetモジュールのインターネット関連の関数'
tags:
  - Erlang
  - Elixir
  - ipv4
  - 40代駆け出しエンジニア
  - AdventCalendar2022
private: false
updated_at: '2022-12-07T10:29:58+09:00'
id: e30d87cefd24f6dede0a
organization_url_name: fukuokaex
slide: false
---
[Erlang]の[inet]モジュールにインターネット関連の関数があります。いくつか挙げてみます。

https://www.erlang.org/doc/man/inet.html

## [:inet.ip_address型]

[Erlang]ではIPアドレスは整数の[Tuple]として扱われるようです。

```elixir:IPv4の例
{10, 0, 0, 202}
```

```elixir:IPv6の例
{65152, 0, 0, 0, 47655, 60415, 65227, 8746}
```

## [:inet.ntoa/1]

[:inet.ip_address型]のIPアドレスを、[IPv4]または[IPv6]アドレス文字列に変換します。
文字列と言っても[Erlangの文字列]は[Elixir]でいう[Charlist]です。

```elixir:IEx IPv4の例
iex> :inet.ntoa({10, 0, 0, 202})
'10.0.0.202'
```

```elixir:IEx IPv6の例
iex> :inet.ntoa({65152, 0, 0, 0, 47655, 60415, 65227, 8746})
'fe80::ba27:ebff:fecb:222a'
```

## [:inet.gethostbyname/1]

指定されたホスト名を持つホストのhostentレコードを返します。

```elixir:IEx IPv4の例
iex> :inet.gethostbyname('elixir-lang.org')
{:ok,
 {:hostent, 'elixir-lang.org', [], :inet, 4,
  [
    {185, 199, 108, 153},
    {185, 199, 111, 153},
    {185, 199, 110, 153},
    {185, 199, 109, 153}
  ]}}
```

```elixir:IEx IPv6の例
iex> :inet.gethostbyname('elixir-lang.org', :inet6)
{:ok,
 {:hostent, 'elixir-lang.org',
  ['elixir-lang.org', 'elixir-lang.org', 'elixir-lang.org'], :inet6, 16,
  [
    {9734, 20672, 32768, 0, 0, 0, 0, 339},
    {9734, 20672, 32771, 0, 0, 0, 0, 339},
    {9734, 20672, 32769, 0, 0, 0, 0, 339},
    {9734, 20672, 32770, 0, 0, 0, 0, 339}
  ]}}
```

## [:inet.port/1]

- ソケットのポート番号を返します。

```elixir:IEx
iex> {:ok, socket} = :gen_tcp.listen(0, [])
{:ok, #Port<0.6>}

iex> {:ok, port_number} = :inet.port(socket)
{:ok, 56106}

iex> :gen_tcp.close(socket)
:ok
```

[:inet.sockname/1]という似たような関数もあります。

```elixir:IEx
iex> {:ok, {ip_address, port_number}} = :inet.sockname(socket)
{:ok, {{0, 0, 0, 0}, 56114}}
```

## [:inet.info/1]

ソケットに関するさまざまな情報を返します。

```elixir:IEx
iex> :inet.info(socket)
%{
  counters: %{
    recv_avg: 0,
    recv_cnt: 0,
    recv_dvi: 0,
    recv_max: 0,
    recv_oct: 0,
    send_avg: 0,
    send_cnt: 0,
    send_max: 0,
    send_oct: 0,
    send_pend: 0
  },
  input: 0,
  links: [#PID<0.111.0>],
  memory: 40,
  monitors: [],
  output: 0,
  owner: #PID<0.111.0>,
  states: [:listen, :open]
}
```

## [:inet.getifaddrs/0]

- インターフェイス名とインターフェイスのアドレスを含む2要素の[Tuple]のリストを返します。

```elixir:IEx
iex(15)> {:ok, if_list} = :inet.getifaddrs()
{:ok,
 [
   {
    # インターフェイス名
    'lo0',
    # インターフェイスのアドレス
    [
      flags: [:up, :loopback, :running, :multicast],
      addr: {127, 0, 0, 1},
      netmask: {255, 0, 0, 0},
      addr: {0, 0, 0, 0, 0, 0, 0, 1},
      netmask: {65535, 65535, 65535, 65535, 65535, 65535, 65535, 65535},
      addr: {65152, 0, 0, 0, 0, 0, 0, 1},
      netmask: {65535, 65535, 65535, 65535, 0, 0, 0, 0}
    ]},
    ...
 ]}
```

## [inets]モジュール

（[inet]モジュールと名前が似ているのでややこしいですが、）[inets]モジュールは、起動や停止など、`:inets`アプリケーションを操作する基本的なAPIを提供するそうです。

[Elixir]のソースコードにも1箇所出てきます。 何をやっているのかよく理解していませんが、HTTPクライアントの[httpc]を使う前に`:inets`アプリケーションを起動して、使った後に停止しているように見えます。

```elixir
  defp read_httpc(path) do
    {:ok, _} = Application.ensure_all_started(:ssl)
    {:ok, _} = Application.ensure_all_started(:inets)

    # Starting an HTTP client profile allows us to scope
    # the effects of using an HTTP proxy to this function
    {:ok, _pid} = :inets.start(:httpc, profile: :mix)

    ...

    try do
      case httpc_request(request, http_options) do
        {:error, {:failed_connect, [{:to_address, _}, {inet, _, reason}]}}
        when inet in [:inet, :inet6] and
               reason in [:ehostunreach, :enetunreach, :eprotonosupport, :nxdomain] ->
          :httpc.set_options([ipfamily: fallback(inet)], :mix)
          request |> httpc_request(http_options) |> httpc_response()

        response ->
          httpc_response(response)
      end
    after
      Logger.configure(level: level)
      :inets.stop(:httpc, :mix)
    end
  end
```

https://github.com/elixir-lang/elixir/blob/7850bdd7e882815eefd1ba4b16871b32521b8bf8/lib/mix/lib/mix/utils.ex#L646-L684

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
[:inet.gethostbyname/1]: https://www.erlang.org/doc/man/inet.html#gethostbyname-1
[:inet.getifaddrs/0]: https://www.erlang.org/doc/man/inet.html#getifaddrs-0
[:inet.info/1]: https://www.erlang.org/doc/man/inet.html#info-1
[:inet.ip_address型]: https://www.erlang.org/doc/man/inet.html#type-ip_address
[:inet.ntoa/1]: https://www.erlang.org/doc/man/inet.html#ntoa-1
[:inet.port/1]: https://www.erlang.org/doc/man/inet.html#port-1
[:inet.sockname/1]: https://www.erlang.org/doc/man/inet.html#sockname-1
[Charlist]: https://elixir-lang.org/getting-started/binaries-strings-and-char-lists.html#charlists
[Erlangの文字列]: https://www.erlang.org/doc/man/erlang.html#type-string
[inet]: https://www.erlang.org/doc/man/inet.html
[IPv4]: https://ja.wikipedia.org/wiki/IPv4
[IPv6]: https://ja.wikipedia.org/wiki/IPv6
[Tuple]: https://hexdocs.pm/elixir/Tuple.html
[inets]: https://www.erlang.org/doc/man/inets.html
[httpc]: https://www.erlang.org/doc/man/httpc.html
