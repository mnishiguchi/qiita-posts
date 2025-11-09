---
title: mise で fwup をインストールする
tags:
  - asdf
  - Nerves
  - mise
  - fwup
private: false
updated_at: '2025-11-09T18:39:33+09:00'
id: d9481735ca8f31cdb22e
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
## はじめに

[Nerves](https://www.nerves-project.org/) のファームウェア更新ツール [fwup](https://github.com/fwup-home/fwup) を、[mise](https://mise.jdx.dev/) を使ってインストールした手順の記録です。

https://github.com/fwup-home/fwup

筆者の環境は Debian 系ですが、他の OS でも基本的な流れは同じです。

## Installation

まず、fwup の公式ドキュメントでは mise（または asdf）を利用したインストール方法が案内されています。

> If you're already using [asdf](https://asdf-vm.com/) or [mise-en-place](https://mise.jdx.dev/), install `fwup` via [asdf-fwup](https://github.com/fwup-home/asdf-fwup). This will allow you to manage `fwup` versions in your software projects via `.tool-versions` files.
>
> — [fwup README](https://github.com/fwup-home/fwup)

> asdf または mise-en-place を使用している場合は、[asdf-fwup](https://github.com/fwup-home/asdf-fwup) 経由で `fwup` をインストールできます。
> `.tool-versions` ファイルを通じて、プロジェクト単位で fwup のバージョン管理が可能になります。

mise では `.tool-versions` により、プロジェクトごとに異なるバージョンを簡単に切り替えられます。

## asdf-fwup プラグインについて

fwup 用の asdf / mise プラグインは [asdf-fwup](https://github.com/fwup-home/asdf-fwup) です。

> This is the [fwup](https://github.com/fwup-home/fwup) plugin for the [asdf](https://asdf-vm.com/) and [mise-en-place](https://mise.jdx.dev/) package managers.
>
> — [asdf-fwup README](https://github.com/fwup-home/asdf-fwup)

> これは、asdf および mise-en-place 向けの fwup プラグインです。

mise は asdf のプラグインエコシステムをそのまま利用できます。

> mise can use asdf's plugin ecosystem under the hood for backward compatibility.
>
> — [mise plugins](https://mise.jdx.dev/plugins.html#asdf-legacy-plugins)

> mise は下位互換のために、asdf のプラグインエコシステムを内部的に利用できます。

そのため、asdf 用プラグインをそのまま mise で扱えます。

## 依存パッケージについて

各 OS に応じて必要な依存パッケージを事前にインストールしてください。

例として、Debian 系の場合の例は以下のとおりです。

```bash
sudo apt-get install autoconf pkg-config help2man libconfuse-dev libarchive-dev
```

macOS や他の OS を使用している場合は、README の[「Dependencies」セクション](https://github.com/fwup-home/asdf-fwup#dependencies)
を参照してください。

## mise 経由でのインストール

プラグインを追加して、fwup をインストールします。

```bash
mise plugin install fwup https://github.com/fwup-home/asdf-fwup.git
mise use --global fwup@latest
```

これで mise 管理下に fwup が導入され、グローバル環境で利用できるようになります。

## 動作確認

インストールが完了したら、バージョンを確認します。

```bash
fwup --version

mise ls
```

バージョンが表示されればインストール成功です。

## 補足：Nerves 1.12 での改善点

以前は、asdf や mise 経由でインストールした fwup を使用すると `mix burn` 実行時に権限エラーが発生することがあり、[Nerves の Issue #1088](https://github.com/nerves-project/nerves/issues/1088) で報告されました。

https://github.com/nerves-project/nerves/issues/1088

その後、Nerves 1.12 で改良され、asdfでインストールしたfwupでも安全に `mix burn` できるようになりました 🎉

https://hexdocs.pm/nerves/changelog.html#v1-12-0-2025-11-01

## おわりに

fwup は Nerves プロジェクトでのファームウェア更新や SD カード書き込みに欠かせないツールです。
mise と組み合わせることで、プロジェクト単位のバージョン管理をシンプルに実現できます。
また、Nerves 1.12 以降では mise 経由の fwup も安全に利用可能になりました。
