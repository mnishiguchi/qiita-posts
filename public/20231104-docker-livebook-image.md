---
title: Elixir Livebook の Docker イメージの在処
tags:
  - 初心者
  - Elixir
  - Docker
  - Phoenix
  - Livebook
private: true
updated_at: '2023-11-05T09:27:20+09:00'
id: 93fca196918f911b3c2d
organization_url_name: null
slide: false
ignorePublish: false
---

[Elixir]製のノートブックツール [Livebook] の最新版 [Docker] イメージはどこで入手できるのでしょうか。

## 結論

最新のイメージは Github リポジトリのこのリンクで検索できます。

https://github.com/livebook-dev/livebook/pkgs/container/livebook

[Livebook の README] にヒントがあります。

## 古いイメージ

Dockerhub にもありますが、執筆時点（2023年11月）では何ヶ月も更新されていない状態です。

https://hub.docker.com/r/livebook/livebook/tags

## Livebookを試してみる

有志の方々が、[Elixir]言語、[Livebook]を楽しく学べるよう多数のコラムを執筆してくださっています。

ご興味のある方は、ぜひ検索してみてください。

https://qiita.com/tags/livebook

https://qiita.com/RyoWakabayashi/items/e8a5253e9f5f8305579b

https://qiita.com/westbaystars/items/cb29c24ae7f3efafd81d

https://qiita.com/torifukukaiou/items/beea66ad4c9629fa826e

https://moneyforward-dev.jp/entry/2023/08/31/100000

[Elixir] 言語を使ってサーバーの費用を **$2 Million/年** 節約できたというウワサがあります。

https://paraxial.io/blog/elixir-savings


本記事は [autoracex #253](https://autoracex.connpass.com/event/298184/) の成果です。ありがとうございます。

https://autoracex.connpass.com/

[Livebook の README]: https://github.com/livebook-dev/livebook#docker
[Livebook]: https://livebook.dev/
[Phoenix]: https://www.phoenixframework.org/
[Erlang]: https://www.erlang.org/
[Elixir]: https://elixir-lang.org/
[Docker]: https://docs.docker.jp/get-started/overview.html
