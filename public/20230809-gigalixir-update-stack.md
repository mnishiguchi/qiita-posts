---
title: GigalixirのStackを更新する
tags:
  - Heroku
  - Elixir
  - Phoenix
  - Gigalixir
  - 闘魂
private: false
updated_at: '2023-08-17T11:12:41+09:00'
id: 3b7dc3d377eeb010a70c
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

かなり前に[Gigalixir]にデプロイした[Phoenix]アプリが長い間ほったらかしになっていたので、久しぶりにメンテナンスをしました。
[Elixir]と[Erlang]のバージョンが古かったので最新のものにしようとしましたが、[Gigalixir]の[Stack][Gigalixir Stack]が古くてうまく行きませんでした。
若干戸惑った部分があったので忘備録を残します。

[Gigalixir]: https://www.gigalixir.com/
[Phoenix]: https://www.phoenixframework.org/
[Gigalixir Stack]: https://www.gigalixir.com/docs/config#can-i-choose-my-operating-system-stack-or-image
[Erlang]: https://www.erlang.org/
[Elixir]: https://elixir-lang.org/
[Heroku]: https://www.heroku.com/

本作品は闘魂Elixir #42の成果です。

https://autoracex.connpass.com/event/291942/

これから[Elixir]を始める方にはこのサイトがおすすめです。

https://elixir-lang.info/

[Elixir]とコミュニティの雰囲気をゆるく味わいたい方は「先端ピアちゃん」さんの動画が超オススメです。

https://www.youtube.com/@piacerex

[Elixir]: https://elixir-lang.org/

## 結論

[Gigalixir]にログインしアプリのダッシュボードで[Stack][Gigalixir Stack]のバージョンを確認。
必要であれば最新のものにアップデートする。

![gigalixir-edit-app.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/6178304c-e710-70ef-34d1-e0c73084527f.png)

## Gigalixir Stackとは

端的にいうと[Heroku]が管理しているOSのイメージのようです。

本執筆時点では、`gigalixir-18`と`gigalixir-20`から選択できるようです。

https://devcenter.heroku.com/ja/articles/stack-packages

https://www.gigalixir.com/docs/config#can-i-choose-my-operating-system-stack-or-image

## 戸惑ったこと1

公式ドキュメントのデプロイ手順書に書かれている通り、[Elixir]と[Erlang]のバージョンを変更したら、怒られてしまいました。

https://www.gigalixir.com/docs/getting-started-guide/phoenix-mix-deploy


この部分です。

```bash:デプロイ手順書に書いてあるバージョン
echo "elixir_version=1.15.4" > elixir_buildpack.config
echo "erlang_version=26.0.2" >> elixir_buildpack.config
```

変更前のバージョンは以下の通りでした。

```bash:元のelixir_buildpack.config
elixir_version=1.12.3
erlang_version=23.3.2
```

変更後デプロイすると以下のエラーがでました。

```bash:怒られた内容
...
-----> Checking Erlang and Elixir versions
       Will use the following versions:
       * Stack heroku-18
       * Erlang 26.0.2
       * Elixir v1.15.4
       Sorry, Erlang '26.0.2' isn't supported yet or isn't formatted correctly. For a list of supported versions, please see https://github.com/HashNuke/heroku-buildpack-elixir#version-support
...
```

> Sorry, Erlang '26.0.2' isn't supported yet or isn't formatted correctly.

`Erlang '26.0.2'`はサポートされているはずなのにまだサポートされていないと言い張っています。

> For a list of supported versions, please see https://github.com/HashNuke/heroku-buildpack-elixir#version-support

実際にサポートされているバージョンを確認してみます。エラーメッセージにあるリンク先に行くとまた更に複数のURLがあります。

しばらく戸惑った後にアプリのStackのバージョンを確認してみると、最新のものではありませんでした。

```txt:怒られた内容
...
       * Stack heroku-18 <----------- これ
       * Erlang 26.0.2
       * Elixir v1.15.4
...
```

これが原因でした。Stackのバージョンによりサポートされる依存関係が異なります。

## 戸惑ったこと2

長い間メンテナンスをしていなかったので、アプリ自体が古くなっていました。かなり多くのパッケージが廃れたバージョンを使っていました。

これらを一気にバージョンアップしたところ、デプロイでエラーが連発しました。これはアプリ側の問題で[Gigalixir]とは関係ないため、別の問題として切り分けることにします。

まずは`mix hex.outdated`コマンドで使用しているパッケージのバージョンをリストアップし、あとは地道に丁寧にアップデートしていきます。

![mix-hex-outdated.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/cbd526ae-8134-8afb-7351-a1ee1f704c23.png)

運が良ければ、全部一気にアップデートしても大丈夫かもしれません。今回はだめでした。

```
mix clean --deps
mix deps.unlock --all
mix deps.get
```

## Gigalixirの他のいろんな技

Gigalixirの他のいろんな技については、[Qiitaで「Gigalixir」を検索](https://qiita.com/search?q=Gigalixir)するといくつか記事が見つかります。

https://qiita.com/search?q=Gigalixir

https://qiita.com/torifukukaiou/items/a2b51fb46299762d3ce9

https://qiita.com/nako_sleep_9h/items/77407ec6e79569dc4157

## 他のプラットフォーム

他のプラットフォームを試してみても良いかもしれません。

https://qiita.com/rana_kualu/items/f7fc4916b7dc9797839e

[Elixir]や[Phoenix]界隈では[Phoenix]の作者である[Chris McCord](https://twitter.com/chris_mccord)さんの所属する[Fly.io](https://fly.io/)が人気です。

https://fly.io/blog/how-we-got-to-liveview/

https://qiita.com/search?q=Fly+Elixir
