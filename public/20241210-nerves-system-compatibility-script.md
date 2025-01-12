---
title: Nerves System の互換表を自動生成するスクリプト
tags:
  - Linux
  - Elixir
  - IoT
  - Nerves
private: false
updated_at: '2025-01-24T09:09:30+09:00'
id: d87563e9f8063e9f1165
organization_url_name: fukuokaex
slide: true
ignorePublish: false
---
## はじめに

以前 Nerves 公式ドキュメントに掲載されている [Nerves System の互換表] についてご紹介させていただきました。  
今回は、その互換表がどのように作成されているのかを解説したいと思います。

https://qiita.com/mnishiguchi/items/fcb12612e34c9eb85106

---

## Nerves System 互換表 とは？

各 Nerves System の対応バージョン（Elixir, OTP, Linux, etc.）を一覧で確認できる互換表です。

https://hexdocs.pm/nerves/systems.html#compatibility

![image.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/63b0bef0-a20c-318a-fe65-07ad87298bb0.png)

---

## nerves_system_compatibility.exs スクリプト とは

このスクリプトの主な役割は、Nerves 公式リポジトリからシステム情報を収集し、各リリースの詳細情報（バージョン情報、依存関係など）を解析して、互換表 に必要なデータを出力形式に整形することです。このスクリプトをもちいることで、互換表 の更新が効率的に行えます

https://github.com/nerves-project/nerves/blob/v1.11.2/scripts/nerves_system_compatibility.exs

---

## どうやってデータを取得しているか

[nerves_system_compatibility.exs] スクリプトがどのようにして各データを収集しているのか見てみます。

---

### Nerves バージョン

#### 取得元

- 各 Nerves System リポジトリの `mix.exs` ファイル
- 例: https://github.com/nerves-project/nerves_system_rpi5/blob/4feeb66840149189a96dcd3123a329b8122b02b5/mix.exs#L70

#### 収集方法

- [get_nerves_version_for_target/2](https://github.com/nerves-project/nerves/blob/v1.11.2/scripts/nerves_system_compatibility.exs#L300) 関数を参照

---

### Linux カーネルバージョン

#### 取得元

- 各 Nerves System リポジトリの `nerves_defconfig` ファイル
- 例: https://github.com/nerves-project/nerves_system_rpi5/blob/4feeb66840149189a96dcd3123a329b8122b02b5/nerves_defconfig#L34

#### 収集方法

- [get_linux_version_for_target/2](https://github.com/nerves-project/nerves/blob/v1.11.2/scripts/nerves_system_compatibility.exs#L435) 関数を参照

---

### Buildroot バージョン

#### 取得元

- [nerves_system_br]リポジトリの `create-build.sh` スクリプト
- 例: https://github.com/nerves-project/nerves_system_br/blob/4c0bc21c221d459d9fa6d33832d6a1d9b6a3f211/create-build.sh#L16

#### 収集方法

- [get_buildroot_version/1](https://github.com/nerves-project/nerves/blob/v1.11.2/scripts/nerves_system_compatibility.exs#L319) 関数を参照

---

### OTP バージョン

#### 取得元

- [nerves_system_br]リポジトリの`.tool-versions` ファイル
  - 例: https://github.com/nerves-project/nerves_system_br/blob/4c0bc21c221d459d9fa6d33832d6a1d9b6a3f211/.tool-versions#L1

[nerves_system_br] は開発時期よって若干プロジェクトの構成が変わっているので、バージョンによって取得元を切り替えています。

- Dockerfile
- パッチファイル

#### 収集方法

- [get_otp_version_from_nerves_system_br_tool_versions/1](https://github.com/nerves-project/nerves/blob/v1.11.2/scripts/nerves_system_compatibility.exs#L357) 関数を参照

---

## おわりに

この[nerves_system_compatibility.exs]スクリプトは、Nerves プロジェクトに貢献するために作成しました。

特に、Nerves プロジェクトのコアチームが[Nerves System の互換表]を効率的に更新するための内部ツールとして役立っています。スクリプトを使うことで、正確で最新の情報を簡単に収集・整理できる仕組みを提供しています。

何か氣づいた点や改善のアイデアがあれば、お便りいただけると嬉しいです。

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)

<!--- begin-reusable-links --->

[nerves_system_br]: https://github.com/nerves-project/nerves_system_br
[nerves_systems]: https://github.com/nerves-project/nerves_systems
[qiita_article]: https://qiita.com/mnishiguchi/items/206961699345ee8cf528
[pr_1028]: https://github.com/nerves-project/nerves/pull/1028
[releases]: https://github.com/nerves-project/nerves_systems/releases
[hexdocs_advanced]: https://hexdocs.pm/nerves/advanced-configuration.html#content
[hexdocs_customizing]: https://hexdocs.pm/nerves/customizing-systems.html#content
[hexdocs_overview]: https://hexdocs.pm/nerves/overview.html
[nerves_project]: https://github.com/nerves-project
[Nerves System の互換表]: https://hexdocs.pm/nerves/systems.html#compatibility
[nerves_system_compatibility.exs]: https://github.com/nerves-project/nerves/blob/v1.11.2/scripts/nerves_system_compatibility.exs

<!--- end-reusable-links --->
