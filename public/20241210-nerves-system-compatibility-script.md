---
title: Nerves System の互換表を自動生成するスクリプト
tags:
  - Linux
  - Elixir
  - IoT
  - Nerves
private: false
updated_at: '2024-12-10T13:28:23+09:00'
id: d87563e9f8063e9f1165
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
## はじめに

以前 Nerves 公式ドキュメントに掲載されている [Nerves System の互換表] についてご紹介させていただきました。  
今回は、その互換表がどのように作成されているのかを解説したいと思います。

https://qiita.com/mnishiguchi/items/fcb12612e34c9eb85106

## Nerves System 互換表 とは？

各 Nerves System の対応バージョン（Elixir, OTP, Linux, etc.）を一覧で確認できる互換表です。

https://hexdocs.pm/nerves/systems.html#compatibility

## nerves_system_compatibility.exs スクリプト とは？

このスクリプトの主な役割は、Nerves 公式リポジトリからシステム情報を収集し、各リリースの詳細情報（バージョン情報、依存関係など）を解析して、互換表 に必要なデータを出力形式に整形することです。このスクリプトをもちいることで、互換表 の更新が効率的に行えます

https://github.com/nerves-project/nerves/blob/v1.11.2/scripts/nerves_system_compatibility.exs

## データの取得元

以下に、[nerves_system_compatibility.exs] スクリプトが各データを収集する際の具体的な参照元を示します。

### **Elixir/OTP バージョン**

#### **収集方法**

各 Nerves System のリポジトリでバージョンごとに `mix.exs` をチェックアウトし、`:nerves` のバージョンを解析して Elixir/OTP の互換性を確認します。

[get_nerves_version_for_target/2](https://github.com/nerves-project/nerves/blob/v1.11.2/scripts/nerves_system_compatibility.exs#L300) 関数を使用して、以下のように `mix.exs` からバージョン情報を取得します：

```elixir
def get_nerves_version_for_target(target, version) do
  cd = "#{@download_dir}/nerves_system_#{target}"
  cmd = "cd #{cd} && git checkout v#{version} > /dev/null 2>&1 && grep :nerves, mix.exs"
  ...
end
```

### **Linux カーネルバージョン**

#### **収集方法**

[nerves_system_br] のバージョンを特定し、それに基づいてリポジトリ内の設定ファイル `nerves_defconfig` から Linux カーネルバージョンを取得します。

[get_linux_version_for_target/2](https://github.com/nerves-project/nerves/blob/v1.11.2/scripts/nerves_system_compatibility.exs#L435) 関数を用いてバージョン情報を取得します。

```elixir
def get_linux_version_for_target(target, version) do
  cd = "#{@download_dir}/nerves_system_#{target}"
  cmd = "cd #{cd} && git checkout v#{version} > /dev/null 2>&1 && cat nerves_defconfig"
  ...
end
```

### **Buildroot バージョン**

#### **収集方法**

[nerves_system_br] のリポジトリから `create-build.sh` スクリプトや設定ファイルを解析して Buildroot バージョンを特定します。

[get_buildroot_version/1](https://github.com/nerves-project/nerves/blob/v1.11.2/scripts/nerves_system_compatibility.exs#L319) 関数が以下のように機能します。

```elixir
def get_buildroot_version(nerves_system_br_version) do
  cd = "#{@download_dir}/nerves_system_br"
  cmd = "cd #{cd} && git checkout v#{nerves_system_br_version} > /dev/null 2>&1 && grep NERVES_BR_VERSION create-build.sh"
  ...
end
```

### **OTP バージョン**

#### **収集方法**

`.tool-versions` ファイル、Dockerfile、またはパッチファイルから OTP バージョンを解析します。特定の [nerves_system_br] バージョンに応じて異なる解析手法が適用されます。

以下は[get_otp_version_from_nerves_system_br_tool_versions/1](https://github.com/nerves-project/nerves/blob/v1.11.2/scripts/nerves_system_compatibility.exs#L357) 関数で`.tool-versions` ファイルから OTP バージョンを取得する例です。

```elixir
def get_otp_version_from_nerves_system_br_tool_versions(nerves_system_br_version) do
  cd = "#{@download_dir}/nerves_system_br"
  cmd = "cd #{cd} && git checkout v#{nerves_system_br_version} > /dev/null 2>&1 && cat .tool-versions"
  ...
end
```

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
