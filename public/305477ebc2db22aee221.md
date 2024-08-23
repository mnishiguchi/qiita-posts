---
title: 令和時代のRails アプリに database_cleaner は必要なのか
tags:
  - Rails
  - RSpec
  - ActiveRecord
  - Database
  - DatabaseCleaner
private: false
updated_at: '2024-08-19T13:20:15+09:00'
id: 305477ebc2db22aee221
organization_url_name: haw
slide: false
ignorePublish: false
---

## はじめに

Rails アプリ開発でテスト環境の設定を行う際によく出てくるのものの一つに[database_cleaner]が挙げられます。

過去の Rails のテスト関連の本やネット記事を見ると[database_cleaner]を使うのが作法かのように説明するものが多いです。

しかしながら、中には「[database_cleaner]って要る？」と疑問を投げかけている人も少なからずいます。

https://anti-pattern.com/transactional-fixtures-in-rails

ん、どっち？　現代の Rails アプリに[database_cleaner] は必要なのでしょうか？
氣になったので調査してみました。

[database_cleaner]: https://github.com/DatabaseCleaner/database_cleaner

## 結論

Railsの標準機能`use_transactional_tests`（初期設定: `true`）を使えば、通常は[database_cleaner]が不要であることのようです。

https://github.com/rails/rails/pull/19282

また、[database_cleaner]の作者自身も、[database_cleaner]を作った動機の一つに、Railsの`use_transactional_tests`みたいなことをRails以外のアプリでやりたいことだったと言っています。

https://github.com/DatabaseCleaner/database_cleaner#why

## Rails の`use_transactional_tests` 

実は Rails にはかなり前から[database_cleaner]と同様の機能(Rails のバージョンにより `use_transactional_tests` または `use_transactional_fixtures`)を備えてました。また、 [rspec-rails] も `use_transactional_fixtures` でそれをサポートしています。

`use_transactional_fixtures`という名称が紛らわしかったため、あまり知られてなかったらしいです。Rails ４まで`use_transactional_fixtures`という名称だったので、Rails 標準の fixture を使わない人（例： FactoryBot を使う人）が使えないと勘違いして無効化にする傾向があったそうです。そのため、Rails ５からは`use_transactional_tests`へと名称が変更されたとのことです。

[rspec-rails]: https://github.com/rspec/rspec-rails

## database_cleaner

実は[database_cleaner] の作者は元々Rails にあった`use_transactional_fixtures`のような機能をRailsを使わないアプリで使いたいというのが動機の一つであったとのことです。

> One of my motivations for writing this library was to have an easy way to turn on what Rails calls "transactional_fixtures" in my non-rails ActiveRecord projects.

以下はGoogle Translate の翻訳です。

> このライブラリを作成した動機の 1 つは、Rails 以外の ActiveRecord プロジェクトで Rails が「transactional_fixtures」と呼ぶものを簡単に有効にできるようにすることでした。

https://github.com/DatabaseCleaner/database_cleaner#why

## Rails PR #19282

> This is pretty embarrassing, but I've been using Rails almost since 1.0 and I had no idea that transactional fixtures were running on my tests. I don't use fixtures so I just erroneously assumed that feature didn't work for me. I've been using Database Cleaner unnecessarily for like the last four years. I know, it seems ridiculous, but I talked to a few other fairly savvy Rails users and they had no idea either. I'm beginning to think my misunderstanding is fairly common.

以下はGoogle Translate の翻訳です。

> かなり恥ずかしい話ですが、私は Rails をほぼ 1.0 から使っていますが、テストでトランザクション フィクスチャが実行されていることを知りませんでした。私はフィクスチャを使用していないので、その機能が動作しないものと誤って想定していました。私は過去 4 年間ほど、Database Cleaner を不必要に使用していました。馬鹿げているように思われるかもしれませんが、他のかなり詳しい Rails ユーザー数名と話しましたが、彼らもまったく知りませんでした。私の誤解はかなり一般的であると思い始めています。

https://github.com/rails/rails/pull/19282

本PRはマージされRails５に導入されました。

https://guides.rubyonrails.org/5_0_release_notes.html#active-record-deprecations

## Rail system spec

Rails 5.1でシステムテストが導入される以前は、Capybara を使用して外部ブラウザで JavaScript テストを実行した場合に外部ドライバーが別のプロセスで実行されていたためデータベースが期待どおりにクリーンアップされないという問題が存在し、それを軽減するために[database_cleaner] が一定の役割を果たしていたようです。

Rails システムテストでは、Railsプロセスでドライバーを実行するため、これらの問題は発生しないとのことです。

https://guides.rubyonrails.org/testing.html#system-testing

https://medium.com/table-xi/a-quick-guide-to-rails-system-tests-in-rspec-b6e9e8a8b5f6

https://world.hey.com/dhh/system-tests-have-failed-d90af718

## おわりに

[database_cleaner]をインストールしなくても、Railsのデフォルト機能で同じようなことをRailsがいい感じにやってくれることがわかりました。

他に何か良い情報があれば、ぜひお便りください！
