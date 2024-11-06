---
title: RubyのパターンマッチでJSONのパース処理
tags:
  - Ruby
  - JSON
  - パターンマッチング
private: false
updated_at: '2024-11-15T10:02:12+09:00'
id: d1f8fecdcabb53a7ace0
organization_url_name: haw
slide: false
ignorePublish: false
---
## はじめに

先日、Ruby でパターンマッチを試し、複雑なロジックを簡潔で明確なコードで表現できる強力なツールになり得ることを知りました。

実践的なプログラムでもどんどん試していきます！

https://qiita.com/mnishiguchi/items/53b55deae8e033562a55

## パターンマッチをどこでどうつかうか

パターンマッチの使いみちはいくつか考えられますが、個人的に特に氣に入ったのは深い入れ子構造の Hash や Array の値からの取得です。

## API レスポンスとして返ってきた JSON から値を取り出す

API によってはレスポンスの JSON が複雑な構造をしている場合があります。
例えば、[PocketSign API](https://buf.build/pocketsign/apis)には以下のように入れ子の深いレスポンスが返るものがあります。

```rb
response = <<~RESPONSE
{
  "results": [
    {
      "digitalSignature": {
        "result": {
          "verification": {
            "id": "80375018-3502-4eb7-b422-0898dcf140b5",
            "result": "RESULT_OK",
            "hashAlgorithm": "HASH_ALGORITHM_SHA256",
            "digest": "MV9b23bQeMQ7isAGTkoBZGErH853yGk0W/yUx1iU7dM=",
            "signature": "n4bVa46x6/Ud44p7+zHMPpsTjZG7yqtnqc2Wlcr...",
            "createdAt": "2023-09-02T20:15:27.613966Z"
          },
          "certificate": {
            "id": "1845533e-42ae-42db-9ed5-862dece5a4e3",
            "type": "TYPE_JPKI_CARD_DIGITAL_SIGNATURE",
            "createdAt": "2023-07-31T11:00:11.506906Z"
          },
          "certificateStatus": {
            "id": "b3ee5560-206b-4871-aa67-a47389fbafd6",
            "status": "STATUS_GOOD",
            "checkMethod": "CHECK_METHOD_CRL",
            "checkPurpose": "CHECK_PURPOSE_SIGNATURE_VERIFICATION",
            "sourceUpdatedAt": "0001-01-01T00:00:00Z",
            "createdAt": "2023-09-02T20:15:27.613966Z"
          },
          "certificateContent": {
            "subject": "OU=P8N for digital signature+OU=PocketSign Inc.,O=P8N-MOCK,C=JP",
            "validity": {
              "notBefore": "2022-06-06T04:56:54Z",
              "notAfter": "2027-06-05T04:56:54Z"
            },
            "crlDistributionPoint": "CN=City-0 CRLDP,OU=Prefecture-0,OU=CRL Distribution Points,OU=P8N for digital signature,O=P8N-MOCK,C=JP",
            "jpkiCardDigitalSignatureContent": {
              "commonName": "ナカモト　サトシ",
              "substituteCharacterOfCommonName": "0000",
              "gender": "2",
              "dateOfBirth": "118991201",
              "address": "福岡県飯塚市幸袋576-14 e-ZUKAトライバレーセンター",
              "substituteCharacterOfAddress": "0000000000000000000000000"
            }
          }
        }
      }
    }
  ]
}
RESPONSE
```

### Enumerable モジュールのメソッドや dig メソッドを使ったやり方

まずはパターンパターンマッチを使わない場合のやり方を考えてみようと思います。

パターンマッチを使わない場合は、[Enumerable](https://ruby-doc.org/3.3.6/Enumerable.html)モジュールのメソッドや[dig](https://ruby-doc.org/3.3.6/dig_methods_rdoc.html)メソッドを用いて狙った値を取得することができます。

```rb
require 'json'
parsed_body = JSON.parse(response)

digital_signature_result =
  parsed_body
    .fetch('results')
    .find { |result| result.key?('digitalSignature') }
    .fetch('digitalSignature')

verification_result = digital_signature_result.dig("result", "verification", "result")
#=> "RESULT_OK"
```

```rb
require 'json'
parsed_body = JSON.parse(response)

verification_result =
  parsed_body.dig("results", 0, "digitalSignature", "result", "verification", "result")
#=> "RESULT_OK"
```

### パターンマッチを使ったやり方

パターンをマッチを使うと、以下のようにデータ構造を明示した上で深い入れ子構造の中の値を変数に代入することができます。

データ構造が見て取れるのでうまく行けばドキュメントとしての機能も果たせるのではと期待しています。

```rb
require 'json'
parsed_body = JSON.parse(response, symbolize_names: true)

parsed_body => {
  results: [
    {
      digitalSignature: {
        result: {
          verification: {
            result: verification_result
          }
        }
      }
    },
    *_other_results
  ]
}

verification_result
#=> "RESULT_OK"
```

:::note warn
ハッシュのパターンマッチで使えるキーはシンボルのみなので注意してください。
:::

異常系のレスポンスにも対応したい場合は、正常系と異常系の両方のパターンを指定します。

```rb
get_verification_result = 
  lambda do |results|
    case results
    # 署名が正常に作成された場合
    in [
      {
        digitalSignature: {
          result: {
            verification: {
              result: verification_result
            }
          }
        }
      },
      *_
    ]
      verification_result
    # 署名が正常に作成されなかった場合
    in [
      {
        digitalSignature: {
          error: _
        }
      },
      *_
    ]
      "署名が正常に作成されませんでした"
    end
  end

require 'json'
parsed_body = JSON.parse(response, symbolize_names: true)
get_verification_result.call(parsed_body.fetch(:results))
#=> "RESULT_OK"

get_verification_result.call([{
  digitalSignature: {
    error: {
      code: 9,
      message: "The request cannot proceed. Please refer to the documentation for more details."
    }
  }
}])
#=> "署名が正常に作成されませんでした"
```

APIから想定外のレスポンスが返って来てパターンにマッチしない場合は、エラー(`NoMatchingPatternError`)となります。このエラーを回避したい場合は「その他の条件」として`else`節を指定します。

![image.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/97117d5b-5e3a-db09-bb2f-f3588b680bb1.png)

## 一つ氣になること

シンボルってガベージ・コレクションされるのでしたっけ？

ハッシュのパターンマッチで使えるキーはシンボルのみなので、でっかいJSONをまるごとシンボルキーに変更したら楽なのですが、果たしてそれで大丈夫なのでしょうか？

## Symbol GC

公式ドキュメントによるとシンボルはガベージ・コレクションされるようです。

> 2.2.0 以降においては、テーブルに記録された情報は Ruby によって GC されます。すなわち、ある使わなくなったシンボルのテーブル上の情報はGCによって削除されます。

https://docs.ruby-lang.org/ja/latest/class/Symbol.html

とはいえ、一時的でも知らないところで要らないシンボルが生成されるのは氣持ち悪いのでHashのシンボルキー化のスコープはなるべく必要最低限に狭めたほうが良さそうな氣がしています。

## さいごに

パターンマッチの活用方法の一つとしてでっかいJSONから値を取り出すことをやってみました。

同僚が Elixir や Rust のパターンマッチを利用してスマートに課題解決しているのをみたことがあります。

https://qiita.com/haw_ohnuma/items/dd329bc9c5da78967e7c#fizz-buzz

https://qiita.com/torifukukaiou/items/966b71497f04c7fb5882

https://qiita.com/torifukukaiou/items/a273565bd2643c4017c1#elixir

これからも引き続きいろんな場面でパターンマッチを試していこうと思います。
