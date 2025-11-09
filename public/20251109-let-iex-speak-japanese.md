---
title: Elixir で Open JTalk を使い、IEx に日本語をしゃべらせてみた
tags:
  - mecab
  - Elixir
  - 日本語
  - OpenJTalk
  - iex
private: false
updated_at: '2025-11-09T14:27:34+09:00'
id: becc3c1fa35958921965
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

## はじめに

IEx で日本語音声を発声させてみます。

## TL;DR

まず、Elixir がインストールされていることを確認します。

```bash:ターミナル 
$ elixir --version
Erlang/OTP 28 [erts-16.1.1] [source] [64-bit] [smp:20:20] [ds:20:20:10] [async-threads:1] [jit:ns]

Elixir 1.19.2 (compiled with Erlang/OTP 28)
```

IEx（Elixir の対話シェル）を起動します。

```bash:ターミナル
$ iex
```

そして、日本語をしゃべらせてみましょう。

```elixir:IEx
iex> Mix.install([{:open_jtalk_elixir, "~> 0.3"}])

iex> OpenJTalk.say("元氣ですかあ 、元氣が有れば、なんでもできる!")
```

デモ動画: [![Watch the demo](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/f9bdkpv5fbp7mi2c7vlp.png)](https://github.com/user-attachments/assets/69d2579c-2d6f-47e5-bcfc-16b955ee8df0)

## おわりに

たったこれだけで、日本語の発声ができます。

このライブラリは、友人と組み込み開発に取り組んでいたときに生まれたものです。
よかったら、ラズパイにも日本語を喋らせてみてください。

https://qiita.com/mnishiguchi/items/e7c96c6caae15f16fbbf

https://github.com/piyopiyoex/open_jtalk_elixir
