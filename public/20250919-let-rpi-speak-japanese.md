---
title: Elixir/Nerves で Open JTalk を使い、ラズパイに日本語をしゃべらせてみた
tags:
  - mecab
  - Makefile
  - Elixir
  - OpenJTalk
  - Nerves
private: false
updated_at: '2025-09-22T13:10:57+09:00'
id: e7c96c6caae15f16fbbf
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
[English version](https://dev.to/mnishiguchi/bringing-open-jtalk-to-elixirnerves-make-your-pi-speak-japanese-ml3)

## はじめに

ある日、友人の @kurokouji さんがこうつぶやきました。

> Nerves で動くラズパイを Open JTalk で日本語しゃべらせてみたい。

面白そうですね。やってみましょう。

……とは言ったものの、どうやって実現するのかはまったく分かりませんでした。  
でも、**AI**時代の今なら何とかなるはず。
なにより、[アントニオ猪木（**A**ntonio **I**noki）さん][Antonio Inoki]もこう言ってます。

> 元氣があれば何でもできる

そんなわけで勢いに任せて挑戦してみたわけですが、[Open JTalk]を適切にビルドすること自体がなかなかの深い沼でした。

その試行錯誤のなかで、[Elixir] や [Nerves] と組み合わせて扱いやすくするためのライブラリ[open_jtalk_elixir] を作るに至りました。

このライブラリは：

- [Open JTalk] のネイティブCLIを [Elixir] コンパイル時に自動ビルド
- 必要な辞書・音声資源をあらかじめ同梱（設定不要）
- Linux / macOS / [Nerves] でそのまま動作

本記事では、次のような内容を紹介します：

- [Open JTalk] とは何か？
- [Elixir] から日本語の音声を生成して発話させる方法
- [open_jtalk_elixir] の使い方と設計ポイント
- [Nerves] 対応のための工夫と注意点
- つまずいたポイントや設計の工夫

[Elixir]: https://elixir-lang.org/
[Nerves]: https://nerves-project.org/
[open_jtalk_elixir]: https://hex.pm/packages/open_jtalk_elixir
[Open JTalk]: https://open-jtalk.sp.nitech.ac.jp/ 
[Antonio Inoki]: https://www.google.co.jp/search?q=antonio+inoki
[raspberrypi.org/computers]: https://www.raspberrypi.org/computers
[名古屋工業大学]: https://www.nitech.ac.jp/
[Text to Speech]: https://www.google.com/search?q=text+to+speech+%E3%81%A8%E3%81%AF
[WAVファイル]: https://www.google.com/search?q=WAVファイル+%E3%81%A8%E3%81%AF
[HMM/DNN-based Speech Synthesis System (HTS)]: https://hts.sp.nitech.ac.jp/
[MeCab]: https://taku910.github.io/mecab/
[HTS Engine]: https://hts-engine.sourceforge.net/

## Open JTalk とは

[Open JTalk] は、[名古屋工業大学]で開発された日本語向け[テキスト音声合成（Text to Speech, TTS）][Text to Speech]システムです。

日本語の文章を入力として、自然な[音声波形（WAVファイル）][WAVファイル]を合成できます。

メモリ消費が少なく、組み込み用途にも向いているそうです。

[Open JTalk] は基本的にコマンドラインツールとして提供され、以下の構成で利用されます：
- **Open JTalk 本体**：
  - コマンドラインで動く実行ファイル（テキストを受け取って音声を合成）  
- **MeCab 辞書**：
  - 形態素解析や読み・発音情報を返す[MeCab]用の日本語辞書  
- **HTS 音声データファイル**：
  - [HMMベースの統計的音声合成（HTS）][HMM/DNN-based Speech Synthesis System (HTS)]で使う音声モデルファイル（拡張子は `.htsvoice`）。
  - 例：`mei_normal.htsvoice`（MMDAgent の Mei）

```mermaid
flowchart LR
    A[日本語テキスト] --> B[形態素解析<br>（MeCab）]
    B --> C[発音・アクセント付与]
    C --> D[音声パラメータ生成<br>（HTS 音声モデル）]
    D --> E[音声波形（WAV）]
```

https://open-jtalk.sp.nitech.ac.jp/

## open_jtalk_elixir ライブラリの紹介

[open_jtalk_elixir] は、Open JTalk を [Elixir] から簡単に扱えるようにするためのラッパーライブラリです。

[Open JTalk] は本来 C 言語で実装されたコマンドラインツールであり、辞書や音声モデルの準備・管理、各種オプションの指定などに一定の手間がかかります。
また、[Elixir] 環境に組み込むにはビルドやパス解決などの工夫が必要です。

このライブラリでは、以下のような工夫を通じて、[Open JTalk] を [Elixir] プロジェクトに統合しやすくしています：

- ✅ **Open JTalk のネイティブバイナリを自動ビルド**  
  コンパイル時に必要なバイナリをビルドし、[Elixir] 側からすぐに使えるように配置します。

- ✅ **辞書・音声モデル（HTS Voice）を同梱済み**  
  特別な設定なしで、標準の辞書・音声資源がそのまま使えます。

- ✅ **Linux / macOS / Nerves に対応**  
  Raspberry Pi を含む [Nerves] 環境でも動作確認済みです。

- ✅**シンプルな API**  
  `OpenJTalk.say("元氣ですかあ")` のように、簡単に音声ファイルを出力できます。

裏側では CLI を叩いていますが、[Elixir] らしいインターフェースを通じて扱えるため、  
音声合成を組み込んだアプリケーションの開発が手軽に行えるようになります。

```mermaid
flowchart LR
  A[依存関係を解決] --> B[ネイティブバイナリをビルド]
  B --> C[辞書・音声モデルを配置<br>（priv/ に展開）]
  C --> D[Elixir から利用可能に！]
```

https://github.com/mnishiguchi/open_jtalk_elixir

## 基本的な使い方

まずは、`open_jtalk_elixir` をプロジェクトに追加します。

### 1. `mix.exs` に依存関係を追加

```elixir
def deps do
  [
    {:open_jtalk_elixir, "~> 0.2.0"}
  ]
end
````

```shell
$ mix deps.get
```

### 2. Elixir から呼び出す

ビルドが成功すれば、さっそく以下のように発話テストができます：

```elixir
OpenJTalk.say("元氣ですかあ 、元氣が有れば、何でもできる")
```

この１行で、同梱されている辞書と音声モデルを使って日本語の発話が行われます。

さらに、速度や音程などの調整も可能です：

```elixir
OpenJTalk.say("元氣ですかあ 、元氣が有れば、なんでもできる", rate: 0.5, pitch_shift: -8)
````

この例では、話す速度をゆっくりにし、音程を低めにしています。

詳しいオプションやパラメータの一覧については、[公式ドキュメント](https://hexdocs.pm/open_jtalk_elixir/OpenJTalk.html)をご覧ください。

[![Watch the demo](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/f9bdkpv5fbp7mi2c7vlp.png)](https://github.com/user-attachments/assets/69d2579c-2d6f-47e5-bcfc-16b955ee8df0)

### 3. 対応環境

このライブラリは以下の OS / プラットフォームで動作確認済みです：

* ✅ Linux（x86_64 / ARM）
* ✅ [Nerves]（Raspberry Pi 3, 4 で確認済み）
* ✅ macOS（Intel / Apple Silicon）

:::note warn
### 注意事項

* 環境によっては `make` や `gcc` などの開発ツールの準備が必要です。
* 発話機能の内部で aplay（Linux）などのシステムコマンドを使用するため、再生できない場合はそちらの確認も行ってください。
:::

https://hexdocs.pm/open_jtalk_elixir

## 仕組みと設計ポイント

`open_jtalk_elixir` を開発するうえで特に意識したのは、[Elixir] から簡単に扱えて、どの環境でも同じように動作することでした。  

ここでは設計上の工夫をいくつか紹介します。

### アプローチの選択

[Open JTalk] を [Elixir] から呼び出す方法としては、いくつかの選択肢がありました。

#### NIF（Native Implemented Function）
高速に動作しますが、ネイティブコードがクラッシュすると BEAM VM ごと落ちるリスクがあります。

#### Port
外部プロセスの管理は可能ですが、I/O のやり取りや引数の扱いが煩雑になります。

#### CLI ラッパー（`System.cmd/3`）
シンプルで安全、かつ移植性も高いアプローチです。

今回は CLI ラッパー方式 を採用しました。移植性を確保でき、無理なく[Elixir] の文脈に統合できるシンプルな構成と判断したためです。[Elixir] 側は薄く、ネイティブの沼は外部プロセスに閉じ込める方針です。

### 辞書と音声モデルの同梱

通常の Open JTalk では、ユーザーが MeCab 辞書や HTS 音声モデルを手動で用意し、パス指定する必要があります。

このライブラリでは、標準の辞書と音声モデルをあらかじめ同梱し、導入直後からすぐに使える体験を提供しています。

ただし、[Nerves] などファームウェア環境では容量制約もあります。
そのため、環境変数を使って 外部ファイルを指定できる仕組みも用意し、利便性と柔軟性のバランスを取りました。

### クロスプラットフォーム対応

最も苦労したのは、Linux / macOS / [Nerves] といった異なるプラットフォーム間の差異をどう吸収するかでした。

設計方針としては、[Elixir] コード自体は環境に依存させず、差異はビルドスクリプトや再生コマンド側で吸収するようにしました。

こうした工夫により、[Elixir] 側のコードは一切変更せずに、あらゆる環境で同じように動作することを目指しました。

#### Linux（x86_64 / ARM）

基本的には素直にビルドできますが、ARM 系（Raspberry Pi など）では `config.sub` / `config.guess` を更新しないとconfigure に失敗することがありました。  

#### macOS（Intel / Apple Silicon）

Apple Silicon 環境では静的リンクが難しく、動的リンクに切り替えることで解決しました。  
  
また Linux では `aplay` を使って音声を再生しますが、macOS では存在しません。そこで OS ごとに再生コマンドを切り替える仕組みを最初から組み込み、「音が出ない」トラブルを事前に回避しました。

#### Nerves
  
[Nerves] 向けには、`MIX_TARGET` に応じてクロスコンパイル設定を切り替える必要がありました。

また、辞書や音声ファイルはサイズが大きいため、ファームウェア容量の制約を常に意識する必要があります。必要に応じて外部ファイルを読み込む構成にも対応させています。

### ビルド構成

ビルド周りは環境依存の罠が多く、沼りやすいポイントです。  
そこで本ライブラリでは、すべてを `Makefile` に押し込まず、二層構成*としました。

- **Makefile**
  `mix compile` から呼び出される入口。共通タスクのみを定義してシンプルに保つ。
- **シェルスクリプト**
  実作業（ダウンロード / configure / ビルド / インストール）と OS／ターゲット差分の吸収を担当。

ビルド処理は、途中までの成果があれば自動的にスキップされるように設計しています。流れは以下のとおりです。

1. **ソースの取得**
   公式の Open JTalk / MeCab / HTS Engine / 辞書 / 音声モデルをダウンロードして展開。
   ついでに最新版の `config.sub`/`config.guess` も用意。

2. **スタックの構築**
   MeCab や HTS Engine を静的ライブラリとしてビルドし、再利用できるように配置。

3. **Open JTalk の構成**
   上記ライブラリを参照するようにパスを設定し、環境に応じて configure を実行。

4. **バイナリのビルド & 配置**
   `open_jtalk` バイナリをビルドし、`priv/bin/` に配置。

5. **辞書・音声の導入**
   標準の辞書や音声ファイルを `priv/` にインストール。

この一連は Makefile のターゲットから呼び出され、[Elixir] 側は `mix compile` だけで完走します。
また キャッシュ戦略として、一度ビルドした成果物は `priv/` 配下に保持し、再コンパイルを高速化。必要に応じて `mix clean` や `OpenJTalk.Assets.reset_cache/0` でリセットできます。

ちなみに再生コマンドの選択（`aplay`, `afplay` など）は、[Elixir] 側で `System.find_executable/1` により動的に解決する方針にしました。

### ディレクトリ構成

[Elixir] のソース（`lib/`）、ビルド資源（`vendor/`）、辞書・音声（`priv/`）を分離して管理しています。
C ソースは Open JTalk / MeCab / HTS Engine の 公式配布物をダウンロードして `vendor/` に展開し、そこからビルドします。

```text
.
├── lib/                # Elixir ソースコード
│   └── open_jtalk/     # Elixir 側モジュール
├── priv/               # バイナリ・辞書・音声モデル
│   ├── bin/            # ビルド済み open_jtalk
│   ├── dic/            # MeCab 辞書
│   └── voices/         # HTS Voice
├── scripts/            # ビルド用シェルスクリプト
├── vendor/             # 公式配布の C ソース (Open JTalk / MeCab / HTS Engine)
├── Makefile            # エントリーポイント
└── mix.exs             # Elixir プロジェクト定義
```

## Nerves 対応のポイント

`open_jtalk_elixir` は [Nerves] を意識して設計しています。
基本的には、`MIX_TARGET` を設定して `mix compile` するだけでクロスコンパイルと資産の同梱が完了します。

### 1. クロスコンパイルの流れ

```bash
# 例: Raspberry Pi 4 向け
export MIX_TARGET=rpi4
mix deps.get
mix compile
mix firmware
```

* `MIX_TARGET` を設定すると、[Nerves] 用のツールチェーンが自動で選択されます。
* MeCab / HTS Engine / Open JTalk などの
C言語ライブラリ群も、ターゲット向けに構築され`priv/` に配置されます。

### 2. 辞書・音声の扱い

* デフォルトでは、辞書と音声モデルをあらかじめ同梱しており、設定不要ですぐに使えます。
* ただし、ファームウェアの容量制限が厳しい場合は、同梱を無効にして外部から読み込む構成にも対応できます。

#### 同梱しないでビルド（容量節約）

```bash
MIX_TARGET=rpi4 \
OPENJTALK_BUNDLE_ASSETS=0 \
mix deps.compile open_jtalk_elixir
```

#### 外部ファイルのパスを指定（例：/data）

```elixir
System.put_env("OPENJTALK_CLI",     "/data/open_jtalk/bin/open_jtalk")
System.put_env("OPENJTALK_DIC_DIR", "/data/open_jtalk/dic")
System.put_env("OPENJTALK_VOICE",   "/data/open_jtalk/voices/mei_normal.htsvoice")

OpenJTalk.Assets.reset_cache()
```

### 3. 音声の再生

`OpenJTalk.say/2` は、合成した音声（WAV）を デバイス上の再生コマンドを使って鳴らします。

* Linux/[Nerves]: `aplay`（多くの [Nerves] イメージに標準で含まれています）
* macOS: `afplay`（参考）

もし音が出ない場合は：

* 端末で `aplay /path/to/test.wav` を直接実行して鳴るか確認
* `{:ok, info} = OpenJTalk.info()` を実行し、`audio_player` の `path` が見つかっているか確認
* 音声再生ができない環境では、`to_wav/2` を使って WAV ファイルとして保存し、別の手段で再生

```elixir
{:ok, info} = OpenJTalk.info()
IO.inspect(info.audio_player, label: "audio player")
```

### 4. 実機での最小動作確認

[Nerves] 実機に接続後：

```elixir
{:ok, info} = OpenJTalk.info()

OpenJTalk.say("元氣ですかあ 、元氣が有れば、何でもできる")
```

## おわりに

本記事では、[Elixir] から日本語音声合成を行うためのライブラリ `open_jtalk_elixir` と、その裏側にある設計・工夫について紹介しました。

もともとは「ラズパイで Open JTalk を動かしたい」という軽い問いかけから始まりましたが、
辞書・音声資源の取り扱い、クロスコンパイル、環境ごとのビルド差分など、深い学びのある取り組みとなりました。

[Elixir] / [Nerves] の文脈で日本語音声合成を扱いたい方にとって、少しでも参考になれば幸いです。

もし不具合や改善案などあれば、ぜひ [GitHub Issues](https://github.com/mnishiguchi/open_jtalk_elixir/issues) からお気軽にお知らせください。


```elixir
OpenJTalk.say("元氣ですかあ 、元氣が有れば、何でもできる")
```

https://github.com/piyopiyoex/open_jtalk_elixir



