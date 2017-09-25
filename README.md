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
