---
name: nodejs-tech-stack-selection
description: Node.jsプロジェクトで新しく依存関係を入れる際の標準選定ルール。プロジェクト立ち上げ時や機能追加時に、どのライブラリやツールを採用するかを事前に固定し、選定の揺れを防ぎたいときに使う。
---

# Node.js Tech Stack Selection

Node.js プロジェクトで依存関係を選ぶときの既定値を固定する。新規プロジェクトや新機能追加時は、まずこのスキルの標準構成を採用し、明確な理由がある場合だけ例外を検討する。

## 基本方針

- 依存関係は自由比較しない。まず既定の選択肢を採用する。
- 例外は「既定では要件を満たせない」と説明できる場合だけ認める。
- 同じ責務に複数のライブラリを併用しない。
- 新しい依存を入れるときは、どの責務を担うかを先に決めてから 1 つ選ぶ。
- インストールや運用の手順は `nodejs-project-bootstrap` と `pnpm-dependency-ops` に従う。

## 標準構成

- 基本: `Node.js LTS`, `TypeScript`, `pnpm`, `oxlint`, `oxfmt`, `vitest`
- HTTP: `hono`
- ORM: `drizzle`
- log: `consola`
- CLI: `citty`
- スキーマ検証: `zod`
- ライブラリ・アプリビルド: `tsdown`
- 開発実行: `tsx`
- Web: `React`, `tailwind`, `vite`
- API Fetch: `@tanstack/react-query` を使い、`Suspense` を前提に構成する

## 選定ルール

### 基本ツールチェーン

- Node.js のバージョンは LTS を使う。
- 言語は TypeScript を使う。
- パッケージマネージャーは `pnpm` を使う。
- lint / format は `oxlint` と `oxfmt` を使う。
- テストは `vitest` を使う。

### サーバーサイド

- HTTP サーバーが必要なら `hono` を使う。
- ログは `consola` を使う。
- 入出力や環境変数の検証は `zod` を使う。
- DB アクセスは `drizzle` を使う。
- 生 SQL は原則禁止とする。クエリは Drizzle 経由で表現する。

### CLI

- CLI を作るなら `citty` を使う。

### ビルドと実行

- ライブラリやアプリのビルドには `tsdown` を使う。
- 開発時の実行には `tsx` を使う。

### Web フロントエンド

- Web を作るなら `React`, `tailwind`, `vite` を使う。
- API Fetch は `@tanstack/react-query` を使う。
- `@tanstack/react-query` は `Suspense` を前提に構成する。

## 例外ルール

- 既定以外を選ぶ場合は、何が既定で不足するのかを明記する。
- 例外を採用するときは、置き換える責務と理由を 1 行で残す。
- 一時的な好みや慣れだけでは例外にしない。

## 出力フォーマット

依存選定を返すときは、以下の形式を使う。

### 1. 採用する依存

- 追加する責務
- 採用パッケージ名
- 既存の標準構成との関係

### 2. 理由

- この責務の標準選択だから
- 例外なら、既定で足りない理由

### 3. 補足

- 追加で必要な関連依存
- 実装に進む場合に使う関連スキル
