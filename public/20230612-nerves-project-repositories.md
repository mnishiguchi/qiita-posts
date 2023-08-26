---
title: Nervesプロジェクトのリポジトリを観察
tags:
  - GitHub
  - Elixir
  - 組み込み
  - Nerves
private: false
updated_at: '2023-06-12T03:42:56+09:00'
id: e5815670297796aba784
organization_url_name: fukuokaex
slide: false
---
[Nervesチーム][Nerves] がどのように開発を進めているのか、どのように [Hex] パッケージをリリースしているのかを知るために、リポジトリをざーっと観察してみました。あくまで個人のメモです。[Nervesチーム][Nerves] の見解ではありません。

## Nervesとは

一言で言うと「Elixir で IoT！？ナウでヤングで cool な Nerves フレームワーク」です。

https://twitter.com/torifukukaiou/status/1201266889990623233

https://nerves-project.org

https://nerves-jp.connpass.com

https://www.slideshare.net/takasehideki/elixiriotcoolnerves-236780506

https://www.slideshare.net/YutakaKikuchi1/elixir-on-elixir-and-embedded-systems

https://qiita.com/pojiro/items/e4a724934feae93180b0

https://qiita.com/pojiro/items/fee4b0bd45eb655613da

https://www.meetup.com/nerves

https://www.youtube.com/channel/UCGN8sxQ5kyk6Ziqma_FEnMA

[Nerves]: https://nerves-project.org
[Hex]: https://hex.pm/docs/publish#submitting-the-package

## 観察するリポジトリ

[Nerves プロジェクト][Nerves]は、各機能に集中して取り組めるよう、複数のリポジトリに分散されて開発されています。Nervesチームは[少なくとも50個ほどのリポジトリ](https://github.com/nerves-project/nerves#nerves-projects)を管理しています。今回は以下の2つの主要リポジトリに焦点を当てます。

- [nerves-project/nerves]
  - [Nerves プロジェクト][Nerves]への入り口であり、コアツールとドキュメントを提供
- [nerves-project/nerves_system_br]
  - Nerves Systems 用の [Buildroot] ベースのビルド プラットフォーム

[nerves-project/nerves]: https://github.com/nerves-project/nerves/commits/main
[nerves-project/nerves_system_br]: https://github.com/nerves-project/nerves_system_br/commits/main
[Buildroot]: https://buildroot.org/

## コミット履歴

- `main` ブランチには[分岐][git merge]がなく、履歴が綺麗に一直線になっています
- [プルリクエスト]が完了した際に、[スカッシュ マージ]されているようです

[git merge]: https://www.atlassian.com/ja/git/tutorials/making-a-pull-request
[プルリクエスト]: https://www.atlassian.com/ja/git/tutorials/making-a-pull-request
[スカッシュ マージ]: https://learn.microsoft.com/ja-jp/azure/devops/repos/git/merging-with-squash

### [nerves-project/nerves]

![nerves-commits 2023-06-06 at 08.09.53.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/570f5e56-e87e-1ecf-4e5a-d3293f2b4efb.png)

### [nerves-project/nerves_system_br]

![nerves_system_br-commits 2023-06-06 at 08.06.31.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/d1024539-6719-9769-5165-11ac15e731e9.png)

## コミットメッセージ

- 特にコミットメッセージをどう書くかについて規約は設けてないようです
- リリース時は一貫して `v<major>.<minor>.<patch> release` という書式の[タグ][git tag]に対応するコミットメッセージになっています

[git tag]: https://www.atlassian.com/ja/git/tutorials/inspecting-a-repository/git-tag

## バージョン表記

- [Nerves プロジェクト][Nerves]におけるバージョン表記は基本的に[セマンティック バージョニング]に準拠しているようです
- [バッカス・ナウア記法]でバージョン番号を示します

[セマンティック バージョニング]: https://semver.org/lang/ja/
[バッカス・ナウア記法]: https://semver.org/lang/ja/#semver%E3%83%90%E3%83%BC%E3%82%B8%E3%83%A7%E3%83%B3%E3%82%92%E8%A1%A8%E3%81%99%E3%83%90%E3%83%83%E3%82%AB%E3%82%B9%E3%83%8A%E3%82%A6%E3%82%A2%E8%A8%98%E6%B3%95
[セマンティック バージョニングのFAQ]: https://semver.org/lang/ja/#faq

https://semver.org/lang/ja

https://dev.classmethod.jp/articles/versoning-with-pictures

## 0.y.zのような初期の開発フェーズにおけるバージョン

[セマンティック バージョニングのFAQ]に要注目です。世の中にはメジャーリリースされていないパッケージがすくなくありません。
その意味を理解する必要があると思います。

> `0.y.z`のような初期の開発フェーズにおけるバージョンの取り扱いはどのようにすべきでしょうか？
> 　一番簡単な方法は`0.1.0`からで開発版をリリースし、その後のリリースのたびにマイナーバージョンを上げていけばよいでしょう。
>
> `1.0.0`のリリースはいつすべきでしょうか？
> 　もし既にプロダクション用途であなたのソフトウェアが利用されているのなら、それは`1.0.0`であるべきでしょう。
> またもし安定したAPIを持ち、それに依存しているユーザーが複数いるのなら、それは`1.0.0`であるべきでしょう。
> もし後方互換性について多大な心配をしているのなら、それは`1.0.0`であるべきでしょう。

[Hex](https://hex.pm/docs/publish#adding-metadata-to-code-classinlinemixexscode)もそれに言及しています。

>  All Hex packages are required to follow semantic versioning. While your package version is at major version "0", any breaking changes should be indicated by incrementing the minor version. For example, `0.1.0` -> `0.2.0`.

メジャーリリース前にパッチバージョンを使ってはいけないのです！

この点で [Nerves] いくつかのパッケージには厳密に言うと[セマンティック バージョニング]でないものがありますが、プロダクションで使用されているパッケージを徐々にメジャーリリースする方向で進んでいます。メジャーリリース後にも既存のユーザもサポートするために、Nerves 関連のパッケージの依存性には複数のバージョンに対応できるよう以下のように`or`を用いているものがあります。

```
circuits_i2c ~> 1.0 or ~> 0.3.0
```

https://hex.pm/packages/bmp280/0.2.12

## Git タグ

[バッカス・ナウア記法]でバージョン番号を示し、接頭辞`v`をつけたものが、[Git タグ][git tag]になります。

https://github.com/nerves-project/nerves/tags

## Github のリリース

[Git タグ][git tag] に対応する [Github リリース]と言うものがあります。各バージョンのコードやビルド結果などをそこからダウンロードすることができます。

https://github.com/nerves-project/nerves/releases

[git tag]: https://www.atlassian.com/ja/git/tutorials/inspecting-a-repository/git-tag
[Github リリース]: https://docs.github.com/ja/repositories/releasing-projects-on-github/about-releases

## Hex パッケージの出版

[Hex のドキュメント](https://hex.pm/docs/publish#submitting-the-package)に従って行います。
ドキュメントは [ex_doc](https://hexdocs.pm/ex_doc/readme.html) パッケージを用いて生成できます。

https://hex.pm/docs/publish#submitting-the-package

https://hexdocs.pm/ex_doc/readme.html

https://hexdocs.pm/elixir/writing-documentation.html

## 解析ツール

[mix format]、[credo]、[dialyzer] が使用されています。これらがCIで実行されます。

https://github.com/nerves-project/nerves/blob/main/.circleci/config.yml#L34-L41

以前は [excoveralls] も使用されていましたが、執筆時点で OTP 26 でうまくイゴかない問題があり、これを使わない方向で進んでます。

[dialyzer]: https://hexdocs.pm/dialyxir/readme.html
[credo]: https://hexdocs.pm/credo/overview.html
[excoveralls]: https://hexdocs.pm/excoveralls/readme.html
[mix format]: https://hexdocs.pm/mix/main/Mix.Tasks.Format.html

## mix env

[Hex] 関連の操作に関しては開発や本番とは別の`docs`と言う環境（[Mix environments]）を設けています。

```elixir
...
      preferred_cli_env: %{
        credo: :test,
        docs: :docs,
        "hex.publish": :docs,
        "hex.build": :docs
      },
...
```

https://github.com/nerves-project/nerves/blob/770e75323506efa63fbe7ca485e855321a0685c7/mix.exs#L21

[Mix environments]: https://hexdocs.pm/mix/Mix.html#module-environments

## 継続的インテグレーション (CI)

執筆時点では、[継続的インテグレーション (CI)] には [Circle CI] が使用されています。

https://github.com/nerves-project/nerves/blob/main/.circleci/config.yml

[Circle CI]: https://circleci.com/docs/config-intro/
[継続的インテグレーション (CI)]: https://circleci.com/ja/continuous-integration/

## Dependabot で依存関係のアップデート

https://docs.github.com/ja/code-security/dependabot/dependabot-version-updates/configuring-dependabot-version-updates

https://github.com/nerves-project/nerves/blob/main/.github/dependabot.yml

## コミュニティ

ぜひお気軽にお立ち寄りください。

https://qiita.com/piacerex/items/09876caa1e17169ec5e1

https://elixir-lang.info/topics/entry_column

https://speakerdeck.com/elijo/elixirkomiyunitei-falsebu-kifang-guo-nei-onrainbian

https://nerves-jp.connpass.com

https://okazakirin-beam.connpass.com/

https://kochi-embedded-meeting.connpass.com

https://autoracex.connpass.com

https://qiita.com/piacerex/items/09876caa1e17169ec5e1

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

https://qiita.com/torifukukaiou/items/4481f7884a20ab4b1bea

https://note.com/awesomey/n/n4d8c355bc8f7

![](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/dc1ddba7-ab4c-5e20-1331-143c842be143.jpeg)
