---
title: Git sparse-checkout を利用して PelemayBackend の OnnxToAxonBench のみをダウンロード
tags:
  - Git
  - Elixir
  - ONNX
  - Pelemay
  - 闘魂
private: false
updated_at: '2023-07-02T07:43:56+09:00'
id: 750ac1cd62abff7c38f5
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
[git sparse-checkout] という技を[とある「誰得」Qiita 記事](https://qiita.com/torifukukaiou/items/cebf4729fb4368a68d8a)からまなびました。ありがとうございます。早速使ってみようと思います。

[PelemayBackend] プロジェクトは複数のサブプロジェクトで構成されています。それらのうち一つだけ読み込みたい時に [git sparse-checkout] を活用できそうです。

[git sparse-checkout]: https://git-scm.com/docs/git-sparse-checkout
[PelemayBackend]: https://github.com/zeam-vm/pelemay_backend
[PelemayBackend(第2版)のコンセプト]: https://zacky1972.github.io/blog/2023/05/26/pelemay_backend.html

https://qiita.com/torifukukaiou/items/cebf4729fb4368a68d8a

https://git--scm-com.translate.goog/docs/git-sparse-checkout?_x_tr_sl=en&_x_tr_tl=ja

## 実行環境

```bash
$ sw_vers
ProductName:		macOS
ProductVersion:		13.4
BuildVersion:		22F66

$ elixir --version
Erlang/OTP 26 [erts-14.0.2] [source] [64-bit] [smp:10:10] [ds:10:10:10] [async-threads:1] [jit]

Elixir 1.15.1 (compiled with Erlang/OTP 26)

$ git --version
git version 2.40.1

```

## PelemayBackend

> 産業用コントローラやスマートフォン，Apple Silicon 等で広く用いられる ARMv8 CPU で行う機械学習や画像処理を並列化・高速化する研究です。

詳しくは [PelemayBackend(第2版)のコンセプト]をご覧ください。

https://github.com/zeam-vm/pelemay_backend

https://kochi-embedded-meeting.connpass.com/event/284564/

## Git sparse-checkout


プロジェクトの一部のディレクトリだけを取り込むことができるようです。大きめのプロジェクトの一部分だけが欲しい場合に便利そうです。

先ずは原典に当たるのが得策だと思います。

https://git-scm.com/docs/git-sparse-checkout

日本語の Qiita 記事も幾つか見つかりました。

https://qiita.com/search?sort=&q=git+sparse-checkout

Gitのバージョンにより使えるコマンドが異なるので注意が必要です。（例：`git sparse-checkout add` は、`2.26` から）古い記事をみるとかえって混乱するかもしれません。

## 論よりRUN

適宜、実験用ディレクトリを用意してください。

```bash
$ mkdir tmp
$ cd tmp
```

`--sparse` オプションをつけて `git clone` します。

```bash
$ git clone --sparse git@github.com:zeam-vm/pelemay_backend.git
```

余談ですが、これらのオプションを追加すると、さらにダウンロードの容量を減らせるようです。大きなプロジェクトで何かを一度きりで試したい場合に良いかもしれません。

- `--depth=1` - [コミット履歴]を削減　（shallow clone）
- `--filter=blob:none` - バイナリデータを削減（blobless clone）

```bash
$ git clone --sparse --depth=1 --filter=blob:none git@github.com:zeam-vm/pelemay_backend.git
```

[コミット履歴]: https://git-scm.com/book/ja/v2/Git-の基本-コミット履歴の閲覧

Github のこの記事に詳しく書かれています。

https://github.blog/2020-12-21-get-up-to-speed-with-partial-clone-and-shallow-clone

ダウンロードされたファイル構造をみてみます。
入れ子になっているサブプロジェクトは含まれていないようです。

```bash
$ tree ~/tmp/pelemay_backend
/Users/mnishiguchi/tmp/pelemay_backend
├── CITATION.cff
├── LICENSE
├── Makefile
├── README.md
├── mix.exs
├── mix.lock
└── publish.exs

1 directory, 7 files
```

`pelemay_backend` ディレクトリの中に入り、`git sparse-checkout add` コマンドを用いてサブプロジェクトを取り込みます。

```bash
$ cd pelemay_backend
$ git sparse-checkout add benchmarks/onnx_to_axon_bench
```

`benchmarks/` 配下の `onnx_to_axon_bench` プロジェクトが取り込めました。

```bash
$ tree ~/tmp/pelemay_backend
/Users/mnishiguchi/tmp/pelemay_backend
├── CITATION.cff
├── LICENSE
├── Makefile
├── README.md
├── benchmarks
│   └── onnx_to_axon_bench
│       ├── LICENSE
│       ├── README.md
│       ├── lib
│       │   ├── onnx_to_axon_bench
│       │   │   └── utils
│       │   │       └── http.ex
│       │   └── onnx_to_axon_bench.ex
│       ├── mix.exs
│       ├── mix.lock
│       └── test
│           ├── onnx_to_axon_bench_test.exs
│           └── test_helper.exs
├── mix.exs
├── mix.lock
└── publish.exs

7 directories, 15 files
```

[Elixir] を実行できる環境が必要ですが、せっかくダウンロードしたのベンチマークを RUN してみます。

```elixir
$ cd benchmarks/onnx_to_axon_bench

# 依存関係を解決
$ mix deps.get

# ベンチマークをRUN
$ mix run -e "OnnxToAxonBench.run"
```

## Elixir の Mix.install で似たようなことをやってみる

[Elixir]: https://elixir-lang.org/
[Mix.install/2]: https://hexdocs.pm/mix/Mix.html#install/2
[mix deps - git options]: https://hexdocs.pm/mix/Mix.Tasks.Deps.html#module-git-options-git
[IEx]: https://elixirschool.com/ja/lessons/basics/basics#%E5%AF%BE%E8%A9%B1%E3%83%A2%E3%83%BC%E3%83%89-2

[Elixir] 言語では [Mix.install/2] 関数を用いて [IEx] いう対話シェルから第三者パッケージをダウンロードすることができます。

[Mix.install/2] には[いろんなオプション][mix deps - git options]がありますが、その中に `sparse` オプションがあります。


`iex` コマンドで [IEx] を起動します。


```elixir
$ iex
Erlang/OTP 26 [erts-14.0.2] [source] [64-bit] [smp:10:10] [ds:10:10:10] [async-threads:1] [jit]

Interactive Elixir (1.15.1) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)>
```

以下のコードを貼り付けます。

```elixir
Mix.install([
  {
    :onnx_to_axon_bench,
    github: "zeam-vm/pelemay_backend",
    sparse: "benchmarks/onnx_to_axon_bench"
  }
])

result = OnnxToAxonBench.run; :ok
```

最後の `; :ok` は `OnnxToAxonBench.run/0` 関数の巨大な戻り値を印字させないための技です。これが印字されてしまうとベンチマークの結果が見えなくなってしまうためです。

結果はこんな感じです。

![CleanShot 2023-06-07 at 08.32.35.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/66e8100a-ce5e-dff6-742f-1afaaa693223.png)

![CleanShot 2023-06-07 at 08.30.23.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/bb8dd61e-4f0b-e6be-09c5-cbb9e0e51394.png)

https://qiita.com/mnishiguchi/items/96bccd30d211e9f88bc3

## コミュニティ

本記事は以下のコミュニティでの活動成果です。
元氣と刺激をいただきありがとうございます。

### 闘魂

https://autoracex.connpass.com/event/285476/

https://qiita.com/torifukukaiou/items/b6361f98194f3687a13c

https://qiita.com/torifukukaiou/items/4481f7884a20ab4b1bea

https://note.com/awesomey/n/n4d8c355bc8f7

### Elixir 言語でワクワク

https://qiita.com/piacerex/items/09876caa1e17169ec5e1

https://elixir-lang.info/topics/entry_column

https://speakerdeck.com/elijo/elixirkomiyunitei-falsebu-kifang-guo-nei-onrainbian

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd


![](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/dc1ddba7-ab4c-5e20-1331-143c842be143.jpeg)


