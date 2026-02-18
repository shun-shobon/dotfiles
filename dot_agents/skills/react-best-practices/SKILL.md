---
name: react-best-practices
description: Reactを使った実装を行う際のベストプラクティスを適用します。
---

# React Best Practices

## Overview

React実装時に、壊れにくくテストしやすい設計を一貫して適用する。  
UIとロジックを分離し、現代のReactのベストプラクティスであるSuspense/ErrorBoundary中心パターンへ統一する。

## Implementation Rules

### 1) Split UI and Logic (Container/Presentational)

- ロジック担当のContainerと描画担当のPresentationalを必ず分離する。
- API呼び出し、状態遷移、依存注入、外部連携はContainerに寄せる。
- Presentationalはpropsベースの純粋な表示に寄せ、可能な限り副作用を持たせない。
- React非依存のビジネスロジックはTypeScriptモジュールに切り出し、Vitestで単体テストする。
- UIの振る舞い検証はPresentationalから始め、Containerは統合点だけを検証する。

### 2) Organize by Package by Feature

- ディレクトリは責務別ではなく機能別に構成する。
- 各featureを自己完結させ、`components/` `containers/` `hooks/` `state/` `api/` `model/` `__tests__/` などを同居させる。
- feature間の参照は公開エントリ（`index.ts`）経由に限定する。
- 共通化は重複が複数featureで発生してから行う。

推奨構成例:

```text
src/
  features/
    user/
      api/
      components/
      containers/
      model/
      state/
      __tests__/
      index.ts
    dashboard/
      ...
```

### 3) Avoid useEffect by Default

- `useEffect` は外部システムとの同期が必要な場合だけ使う。
- props/stateのミラーリング状態を作らない。導出可能な値はrender中に計算する。
- ユーザー操作起点の処理はイベントハンドラで実行し、Effectに逃がさない。
- サーバー状態の取得を`useEffect + useState`で実装しない。
- React公式のアンチパターンに該当する実装は採用しない。

### 4) Fetch Data with Suspense-first Patterns

- APIフェッチはTanStack QueryまたはJotaiを使う。
- TanStack Queryを使う場合は`useQuery`ではなく`useSuspenseQuery`系を使う。
- `isLoading`分岐を増やさず、`Suspense`境界と`ErrorBoundary`境界で状態を扱う。
- クエリキーと取得ロジックはfeature配下に閉じ、責務を局所化する。
- エラーはAPI層またはContainer境界で正規化し、UI層に漏らしすぎない。

### 5) Manage Shared State with Jotai or Zustand

- ローカル状態で足りる場合はuseStateを優先し、広域状態が必要なときのみJotai/Zustandを使う。
- 大きな単一ストアを避け、feature単位でatom/storeを分割する。
- 依存関係注入が必要な箇所はBunshiを使い、テスト差し替え可能な設計にする。

### 6) Test with Vitest and Storybook

- React非依存のビジネスロジックはVitestでテストする。
- ReactのUIロジックはStorybookのstoriesとinteraction testで検証する。
- `Suspense`/`ErrorBoundary`前提で、成功・失敗・空状態をstoriesとして明示する。
- Containerのテストでは外部依存を注入またはモックし、境界の責務を検証する。

## Workflow

1. feature単位でディレクトリを作成する。
2. `model/` と `api/` にReact非依存ロジックを実装する。
3. Containerでデータ取得・状態遷移・DIを扱う。
4. Presentationalで純粋な描画を実装する。
5. `Suspense` と `ErrorBoundary` を画面境界に配置する。
6. Vitest（ロジック）とStorybook（UI）を追加し、失敗系も含めて検証する。

## Review Checklist

- Container/Presentationalが明確に分離されているか。
- Package by Feature構成になっているか。
- `useEffect` を外部同期以外で使っていないか。
- TanStack Queryで`useSuspenseQuery`系を使っているか。
- `isLoading`依存ではなく`Suspense`/`ErrorBoundary`で状態を表現しているか。
- 広域状態が必要な箇所のみJotai/Zustandを使っているか。
- BunshiでDI可能にして、テスト容易性を確保しているか。
- VitestとStorybookで役割分担したテストになっているか。

## References

- 参照資料は `references/react-guidelines-links.md` を読む。
- 実装判断で迷う場合は、公式Reactドキュメントの方針を優先する。
