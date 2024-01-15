---
title: Elixir Phoenix Gigalixirのデータベースを削除する
tags:
  - Elixir
  - Database
  - Phoenix
  - Gigalixir
private: false
updated_at: '2024-01-30T13:32:15+09:00'
id: bbd218b6f136aa08cf48
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

何ヶ月か前にあるちょっとした[Phoenix]アプリのコードを更新した時にうっかり本番データベースの状態を考慮せずに
スキーマとマイグレーションを変更してしまいました。その結果、本番データベースとスキーマとマイグレーションの間に不整合が発生し、マイグレーションやロールバックができなくなりました。

練習用プロジェクトなのでデータベースを一旦削除して最初から作り直すのが一番早いと思い、そうすることにしました。

[Gigalixir]のデータベースを削除した際に気がついた点をメモします。

## 環境

- macOS        14.2.1 23C71 arm64
- MacBookPro   18,1
- gigalixir    1.9.3
- elixir       1.15.4
- erlang       26.0.2
- phoenix      1.7.10
- postgrex     0.17.4
- phoenix_ecto 4.4.3


## gigalixir

本記事は[Gigalixir]にデプロイしたことがある人を対象にしていますが、まだの方もわかりやすい公式ドキュメントやQiita記事が多数ありますので是非とも挑戦してみてください！

> Gigalixir is a fully-featured, production-stable platform-as-a-service built just for Elixir that saves you money and unlocks the full power of Elixir and Phoenix without forcing you to build production infrastructure or deal with maintenance and operations. For more information, see https://www.gigalixir.com.

> Gigalixir は、Elixir 専用に構築された、フル機能で安定した運用が可能なサービスとしてのプラットフォームであり、運用インフラストラクチャの構築やメンテナンスや運用の負担を強いることなく、コストを節約し、Elixir と Phoenix の能力を最大限に活用できます。 詳細については、https://www.gigalixir.com を参照してください。

https://www.gigalixir.com/docs/

https://hexdocs.pm/phoenix/gigalixir.html

https://zenn.dev/koga1020/books/phoenix-guide-ja-1-7/viewer/gigalixir

https://qiita.com/search?q=gigalixir+DATABASE_URL


## データベースを削除する方法

ふた通りのやり方があるようです。どちらともやり方は簡単です。

1. ターミナルから (CUI; 文字ユーザーインターフェイス)
1. [Gigalixir]のウエブアプリから (GUI; 画像/図形ユーザーインターフェイス)

データベースを削除するため、保存されているデータなどはすべて削除されます。

### ターミナルから

```bash:ターミナル
cd path/to/my_phoenix_app

# データベースの情報を印字し、IDを取得
gigalixir pg

# データベースを削除
gigalixir pg:destroy -a <アプリ名> -d <データベースのID>

# 再度データベースの情報を印字し、データベースが削除されたことを確認
gigalixir pg
```

### Gigalixirのウエブアプリから

1. [Database]タブをクリック
1. [DESTROY]ボタンをクリック
1. 確認のためにデータベース ID を入力
1. [DELETE]ボタンをクリック

![gigalixir-destroy-database 2024-01-29 at 16.08.14--1.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/a0fa22ce-80e2-4909-d1ed-8f43fac8952c.png)

## データベースを再度生成

```bash:ターミナル
cd path/to/my_phoenix_app

# 無料プランのデータベースを生成
gigalixir pg:create --free

# データベースが生成されたか確認
gigalixir pg
```

これであとはいつも通り普通にマイグレーションしたらいいのかなと思ったら、エラーが出ました。

## マイグレーションがうまくいかない


```bash:ターミナル
cd path/to/my_phoenix_app

# マイグレーションを実行
gigalixir ps:migrate
```

![gigalixir-database-failed-to-connect 2024-01-29 at 19.29.15--1.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/2940709a-4c89-28e7-0571-5b2941f1a977.png)

でっかいエラーなので見た目が怖いですが、よくみてみると親切に色んな手がかりを残してくれています。

>
> ** (DBConnection.ConnectionError) connection not available and request was dropped from queue after 2928ms.
> This means requests are coming in and your connection pool cannot serve them fast enough. You can address this by:
>
>   1. Ensuring your database is available and that you can connect to it
>   2. Tracking down slow queries and making sure they are running fast enough
>   3. Increasing the pool_size (although this increases resource consumption)
>   4. Allowing requests to wait longer by increasing :queue_target and :queue_interval
>

特にコードも設定も変えていないので、一つ目の「データベースの存在、接続」である可能性が高いと思われます。

## DATABASE_URLを確認

データベースの設定よくみたら`DATABASE_URL`が正しく設定されていませんでした。

```bash:ターミナル
cd path/to/my_phoenix_app

# 現在の設定を確認
gigalixir config

# データベースの情報を取得
gigalixir pg
```

![gigalixir-database-url 2024-01-29 at 20.35.40--1.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/24244bc1-7648-cb0f-677a-ddc64fbc6528.png)

`DATABASE_URL`の値を正しいものに変更します。

```bash:ターミナル
# DATABASE_URLの値を変更
my_database_url="postgresql://xxxx-user:pw-xxxx@postgres-free-tier-v2020.gigalixir.com:5432/xxxx"
gigalixir config:set DATABASE_URL="$my_database_url"

# データベースの情報が変更されたか確認
gigalixir pg
```

## おまけ：`DATABASE_URL`の値だけを取り出す

ついでに`DATABASE_URL`の値だけを取り出すスクリプトを考えてみました。

`jq`があれば一発です。

```bash:ターミナル
gigalixir config | jq '.DATABASE_URL'
# "postgresql://89296796-ad8c-..."
```

grepの`-o, --only-matching`オプションを活用してこう言うやり方ができるそうです。

```bash:ターミナル
gigalixir config | grep -o '"DATABASE_URL": "[^"]*' | grep -o '[^"]*$'
# postgresql://89296796-ad8c-...
```

https://stackoverflow.com/questions/36073695/how-to-retrieve-single-value-with-grep-from-json

URLの形式が決まっている感じなので、固定のところは正規表現の中で明示してもいいのかもしれません。

```bash:ターミナル
gigalixir config |
  grep -o 'postgresql://[a-z0-9-]*:[a-z0-9-]*@[a-z0-9-]*.gigalixir.com:5432/[a-z0-9-]*'
# postgresql://89296796-ad8c-...
```

こんなことに時間をかけるより切取・貼付をした方が早いですが、勉強になります。きっとどこかで役に立つと信じています。

## 最後に一言

本記事は [闘魂 Elixir #66](https://autoracex.connpass.com/event/308576/) の成果です。ありがとうございます。

https://autoracex.connpass.com/

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)

<!-- begin links -->
[Gigalixir]: https://www.gigalixir.com/docs/
[Docker]: https://docs.docker.jp/get-started/overview.html
[Elixir]: https://elixir-lang.org/
[Erlang]: https://www.erlang.org/
[heroicons_elixir]: https://github.com/mveytsman/heroicons_elixir
[heroicons]: https://heroicons.com/
[Livebook]: https://livebook.dev/
[Phoenix]: https://www.phoenixframework.org/
[Tailwind CSS]: https://tailwindcss.com/
[DaisyUI]: https://daisyui.com/
[mix phx.new]: https://hexdocs.pm/phoenix/Mix.Tasks.Phx.New.html
[phx-docker-compose-new]: https://github.com/mnishiguchi/phx-docker-compose-new
[Docker Compose]: https://docs.docker.jp/compose/
[PostgreSQL]: https://www.postgresql.org/
[Git]: https://git-scm.com/
<!-- end links -->
