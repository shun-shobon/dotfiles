---
name: pnpm-dependency-ops
description: pnpmの依存追加運用とERR_PNPM_IGNORED_BUILDS対応の共通手順。
---

# pnpm Dependency Ops

## 基本方針

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

- 用途が明確なパッケージでも、`allowBuilds` の判断前に必ず確認を行う。
- まず `node_modules/.pnpm/<package-name>@<version>/node_modules/<package-name>/package.json` を開き、`postinstall` / `preinstall` / `install` を確認する。
- `preinstall` / `install` / `postinstall` で実行されるファイルのパスを特定し、実際のスクリプトファイル本文まで必ず確認する。
- ファイル名や配置は偽装される前提で扱い、名称ではなく中身で許可・拒否を判断する。
- 未知・不審なパッケージ、またはビルドスクリプト不要に見えるパッケージは拒否寄りで確認する。
- インストールスクリプトが不審なら、即座にアンインストールしてユーザーに報告する。

```bash
pnpm remove <package-name>
```
