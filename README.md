# piyopiyo

[![Build Status](https://travis-ci.org/pepabo-mobile-app-training/hiyoko.svg?branch=master)](https://travis-ci.org/pepabo-mobile-app-training/hiyoko)

## 開発環境準備

### Carthage

#### Carthageをインストールする

ライブラリの管理は[Carthage](https://github.com/Carthage/Carthage)を使用します。
`brew install carthage`

#### Carthageでライブラリ管理

- `carthage update --platform ios`：新たにライブラリを追加した時
- `carthage bootstrap --platform iOS`：すでにあるライブラリをChecked outする時　

### SwiftLint

コードの品質チェックは[SwiftLint](https://github.com/realm/SwiftLint)を使用します。
`brew install swiftlint`

ルールを削除したり、変更したりするときは`.swiftlint.yml`に記述します。
ルールの詳細は、[SwiftLint/Rules.md](https://github.com/realm/SwiftLint/blob/master/Rules.md)に記載があります。

### 環境変数の設定

[Twitter API](https://developer.twitter.com/en.html)の使用のために以下の２つを環境変数として設定します。

- Consumer Key (API Key)
- Consumer Secret (API Secret)


Xcodeのメニューから Product > Scheme > Edit Scheme を選択します。

左サイドメニューから『Run』を選択します。

『Environment Variables』に下記を設定します。

- Name: consumerKey, Value: Consumer Keyの値
- Name: consumerSecret, Value: onsumer Secretの値

