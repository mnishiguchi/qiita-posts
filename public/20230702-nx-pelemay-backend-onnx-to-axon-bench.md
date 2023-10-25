---
title: Elixir Nx Pelemay Backend の OnnxToAxonBench を run して Nx のメモリ消費量を実感する
tags:
  - Elixir
  - FPGA
  - ONNX
  - Pelemay
  - nx
private: false
updated_at: '2023-07-02T07:41:00+09:00'
id: 96bccd30d211e9f88bc3
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

組み込みソフトウェアの有識者や有志の集う高知組み込み会 #6 (2023/06/07 18:00〜) にリモートで参加させていただきました。今回は「[FPGA]と[半導体]」という興味深い話が聞けました。日本語環境でこういった最先端技術の教育を受けられることは大変ありがたいです。ありがとうございます。

https://kochi-embedded-meeting.connpass.com/event/284564

[Elixir]: https://elixir-lang.org/
[FPGA]: https://ja.wikipedia.org/wiki/FPGA
[半導体]: https://ja.wikipedia.org/wiki/%E5%8D%8A%E5%B0%8E%E4%BD%93
[EXLA]: https://hexdocs.pm/exla/EXLA.html
[EXLA.Backend]: https://hexdocs.pm/exla/EXLA.Backend.html
[Nx]: https://hexdocs.pm/nx/Nx.html
[zeam-vm/pelemay_backend]: https://github.com/zeam-vm/pelemay_backend

Elixir言語関連では、登壇者の一人である @zacky1972 先生が、[FPGA] を [Elixir] や [Nx] に関連付けて話をされていました。
そこで現実的に [EXLA.Backend] はメモリ消費量が大きいため、組み込み機器でイゴかすのは厳しいと指摘されていました。論より run 。その時に披露されていたベンチマークを早速 run してみようと思います。

:::note info
@zacky1972 先生からアドバイスをいただきました。ありがとうございます。

> このベンチマークは，EXLAを動かしていません．あくまでNxでの数値です．
なお，EXLAは，Elixirの管理外のメモリを使うので，Bencheeでは，使用メモリを正しく計測できません．

ベンチマークはあくまで目安と考えてください。
:::


## やりかた

まずは [zeam-vm/pelemay_backend] プロジェクトを Github からダウンロード（クローン）します。

```
git clone git@github.com:zeam-vm/pelemay_backend.git
```

ベンチマークを収容するディレクトリに入ります。

```
cd pelemay_backend/benchmarks/onnx_to_axon_bench
```

依存関係を解決し、コンパイルします。

```
mix do deps.get, compile
```

ベンチマークのプログラムを RUN します。

```
mix run -e "OnnxToAxonBench.run"
```

3つのファイルが比較に使用されます。45MB の モデルふたつと 比較的大きめ（171MB）の [ResNet] モデル　のファイルひとつです。この [ResNet] モデルは 1000 クラスの画像を高い精度で分類できるそうです。

[ResNet]: https://github.com/onnx/models/blob/main/vision/classification/resnet/README.md

![CleanShot 2023-06-07 at 08.49.51.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/ecba9caa-40be-c34e-50ec-31be5ba9f674.png)

![CleanShot 2023-06-07 at 08.32.35.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/66e8100a-ce5e-dff6-742f-1afaaa693223.png)

実行環境等がプリントされます。

![CleanShot 2023-06-07 at 19.37.13.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/3cbd11fb-3e02-c1a3-5731-d9f550cef4b4.png)

結果はこんな感じです。

![CleanShot 2023-06-07 at 08.30.23.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/bb8dd61e-4f0b-e6be-09c5-cbb9e0e51394.png)

 [ResNet] モデルを [Nx] でイゴかした場合に 9GB ものメモリを消費しうる事がわかりました。組み込み機器で使うのが容易でない事が想像できます。

## PelemayBackend(第2版)

これを解決し、組み込み機器でもバリバリ [Elixir] と [Nx] で AI できる環境を整える試みが、「PelemayBackend(第2版)」と理解しました。詳しくは [PelemayBackend(第2版)のコンセプト](https://zacky1972.github.io/blog/2023/05/26/pelemay_backend.html) をご覧ください。

## Elixir Chip

以前からウワサになっている Elixir Chip の実現へも着々と進んでいる明るい雰囲気を感じました。夢と希望でいっぱいで元氣がでます。ワクワクします。

https://qiita.com/piacerex/items/b99baebf284243fb6d6b

## コミュニティ

[Elixir]、[Nx] や [PelemayBackend][zeam-vm/pelemay_backend] にご興味のある方はぜひお気軽にお立ち寄りください。

https://qiita.com/piacerex/items/09876caa1e17169ec5e1

https://elixir-lang.info/topics/entry_column

https://speakerdeck.com/elijo/elixirkomiyunitei-falsebu-kifang-guo-nei-onrainbian

