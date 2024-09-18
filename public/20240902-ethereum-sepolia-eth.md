---
title: Ethereum 入門者が SepoliaETH を取得
tags:
  - Ethereum
  - DApps
  - testnet
  - sepolia
private: false
updated_at: '2024-09-02T16:29:09+09:00'
id: 1782191dc5c2404b2fc6
organization_url_name: haw
slide: false
ignorePublish: false
---

## はじめに

Ethereum に入門すると、テストネットにデプロイしてみる演習課題がよくあります。テストネットを利用してガス代を支払うためには、テストネットで利用できる ETH トークンを事前に入手しておくことが必須となるため、初学者にとって避けては通れません。

ネット検索すると簡単にできるよと書かれているのですが、残高がゼロでそのアカウントを使って過去に何もしたことのない状態でやるとうまくいかず色々戸惑いました。



勉強した内容を簡単にまとめます。

## テストネット

- 分散型アプリケーション (Dapps) をテストおよび開発するための安全な環境(開発者が実際の Ethereum 資金を危険にさらさない)を提供
- メインネットの動作環境を模倣するように設計されたブロックチェーン
- メインネットとは別の台帳上に存在

## Sepolia テストネット

- Ethereum コア開発者により設計されたテストネット
- テストネットを利用してガス代を支払うためには、テストネットで利用できる ETH トークンを入手しておくことが必須

https://www.alchemy.com/overviews/sepolia-testnet

## SepoliaETH

- Sepolia テストネットでトランザクションを完了するために支払うために使用される通貨
- Sepolia テストネット用の Faucet から取得できる

## Faucet

ネット検索すると色んな Faucet から SepoliaETH を簡単に無償で入手できるとの情報がありますが、過去に Ethereum を使った活動を何もしていない人には利用できないものが多く有りました。Sepolia ETH を無料で取得できるまでに色んな条件が課せられます。ひょっとすると一昔前までは誰でも簡単に使えたのかもしれません。

うまくいっても、1 回あたりに入手できるトークンは少量で、72 時間に 1 回のみ利用可能などの制限を設けている Faucet が多いです。

- https://www.alchemy.com/faucets/ethereum-sepolia
- https://faucet.quicknode.com/ethereum/sepolia
- https://www.infura.io/faucet/sepolia
- https://sepolia-faucet.pk910.de

## Faucet から SepoliaETH を入手するための条件の例

以下に 2024 年 8 月末現在でうまく行かなった例をいくつか挙げます。

### Ethereum メインネット残高が必要

![alchemy-faucet-minimum-eth 2024-08-29 21-07-41.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/1fc978d8-a6c8-353c-7c91-06f67ee6a7eb.png)

https://www.alchemy.com/faucets/ethereum-sepolia

> To prevent bots and abuse, this faucet requires a minimum Ethereum mainnet balance of 0.001 ETH on the wallet address being used.

以下は Google 翻訳による日本語訳です

> ボットや不正使用を防ぐため、このフォーセットでは、使用されているウォレット アドレスに最低 0.001 ETH の Ethereum メインネット残高が必要です。

### メインネットでの過去のアクティビティが十分にあること

![infura-faucet-no-past-activity 2024-08-30 09-23-08.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/684e99dc-ddc2-79d0-576f-20ccfc27794b.png)

https://www.infura.io/faucet/sepolia

> No Past Activity
>
> The address provided does not have sufficient historical activity on the Ethereum Mainnet. Please use a different address to proceed. Read the FAQ below for more information.

以下は Google 翻訳による日本語訳です

> 過去のアクティビティなし
>
> 指定されたアドレスには、Ethereum メインネットでの過去のアクティビティが十分にありません。続行するには、別のアドレスを使用してください。詳細については、以下の FAQ をお読みください。

![quick-node-faucet from 2024-09-02 10-44-07.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/7fefca55-4fa3-2d1d-d972-a583e460be7c.png)

https://faucet.quicknode.com/ethereum/sepolia

> We require wallets to have a more established transaction history, your wallet does not currently meet this criteria.

以下は Google 翻訳による日本語訳です

> ウォレットにはより確立された取引履歴が必要ですが、現在、お客様のウォレットはこの基準を満たしていません。

### その他

- Faucet にはアカウント登録（サインアップ）する必要のあるものが多いです。

## できたこと１

友人が所持している SepoliaETH を送ってくださり、それを無事受け取ることができました。

おかげで Ethereum の演習課題に取り組むことができました。ありがとうございます！

## できたこと２

- [MetaMask 拡張機能](https://metamask.io/download/)をプラウザにインストール
- 暗号資産ウォレットである[MetaMask]で Ethereum のアカウントを作成
- [MetaMask]で Ethereum を少量購入
- [Alchemy]で Alchemy アカウント登録
- [Alchemy]の[Ethereum Sepolia Faucet]で SepoliaETH を取得

[MetaMask]: https://metamask.io/
[Alchemy]: https://www.alchemy.com/faucets/ethereum-sepolia
[Ethereum Sepolia Faucet]: https://www.sepoliafaucet.com/

## おわりに

以上、Ethereumに入門時のSepoliaETH取得の際につまずいたこと、氣が付いたことについてまとめました。

何か良い情報があればぜひお便りください :bow:
