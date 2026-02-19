---
name: nodejs-project-bootstrap
description: Node.jsプロジェクトを新規作成する場合と依存関係を追加する場合の手順。
---

# Node.js Project Bootstrap

## 基本手順

1. `mise` で使用バージョンを確認する。

```bash
mise latest node@lts
mise latest pnpm@latest
```

2. `.tool-versions` に Node.js の具体的バージョンを書く。

- `lts` や `latest` は書かない。
- 形式:

```text
node <lts-version>
```

3. `mise` で Node.js をインストールする。

```bash
mise install
```

4. `package.json` を作る。

- `type: "module"` を必須にする。
- `packageManager` に pnpm の具体的バージョンを書く。
- `version` は通常 `0.1.0` から始める。ワークスペースルートでは省略可。
- 公開しないプロジェクトは `private: true` を付与する。
- テンプレート:

```json
{
  "name": "<name>",
  "version": "0.1.0",
  "type": "module",
  "description": "<description>",
  "author": "NISHIZAWA Shuntaro <me@s2n.tech>",
  "license": "MIT",
  "private": true,
  "packageManager": "pnpm@<latest-version>"
}
```

5. `pnpm-workspace.yaml` を作り、セキュリティ設定を有効化する。

```yaml
minimumReleaseAge: 1440
saveExact: true
strictDepBuilds: true
trustPolicy: no-downgrade
trustPolicyIgnoreAfter: 10080
```

## TypeScript 導入ルール

- Node.js プロジェクトでは、ツール制約で不可能な設定ファイルを除き TypeScript を使う。
- `tsconfig.json` は手書きでオプションを埋めず、必ず `@tsconfig/*` を `extends` で利用する。
- 型チェックは厳格運用を前提にし、`@tsconfig/strictest` を併用する。

1. TypeScript 関連の依存を追加する。

- Node.js プロジェクト:

```bash
pnpm add -D typescript @tsconfig/node-lts @tsconfig/strictest
```

- Vite + React プロジェクト:

```bash
pnpm add -D typescript @tsconfig/vite-react @tsconfig/strictest
```

2. `tsconfig.json` は `extends` で構成する。

- Node.js プロジェクト例:

```json
{
  "extends": [
    "@tsconfig/node-lts/tsconfig.json",
    "@tsconfig/strictest/tsconfig.json"
  ]
}
```

- Vite + React プロジェクト例:

```json
{
  "extends": [
    "@tsconfig/vite-react/tsconfig.json",
    "@tsconfig/strictest/tsconfig.json"
  ]
}
```

- 追加オプションが必要な場合のみ、最小限の項目を上書きする。

## 依存追加ルール

- 依存追加は必ず `pnpm add <package-name>` または `pnpm add -D <package-name>` を使う。
- `package.json` の `dependencies` / `devDependencies` を手で書き換えない。
- 理由: 古いバージョン参照やフィールド順の破壊を防ぐ。

## ERR_PNPM_IGNORED_BUILDS 対応

`ERR_PNPM_IGNORED_BUILDS` が出たら、`pnpm-workspace.yaml` の `allowBuilds` で許可または拒否する。

```yaml
allowBuilds:
  esbuild: true # 許可する場合
  sharp: false # 拒否する場合
```

## 許可・拒否の判断基準

- 一般的で用途が明確なパッケージは許可する。
- 未知・不審なパッケージ、またはビルドスクリプト不要に見えるパッケージは拒否寄りで確認する。
- まず `node_modules/.pnpm/<package-name>@<version>/node_modules/<package-name>/package.json` を開き、`postinstall`（必要なら `preinstall` / `install`）を確認する。
- インストールスクリプトが不審なら、即座にアンインストールしてユーザーに報告する。

```bash
pnpm remove <package-name>
```

## 注意

- Node.js の固定は `.tool-versions` で行う。`mise.toml` は使わない。
- pnpm の固定は `.tool-versions` ではなく `package.json` の `packageManager` で行う。
- `pnpm create` は使用しないこと。テンプレートではなく自分でプロジェクトを作成する。
