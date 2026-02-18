# React Guidelines Reference

このファイルは、`react-best-practices` スキルの実装判断基準をまとめる。

## Container/Presentational Pattern

- ロジックとUIを分離する。
- データ取得、状態遷移、依存注入、外部I/OはContainerに集約する。
- Presentationalはprops入力と描画に集中し、副作用を持たせない。
- テストは、非ReactロジックをVitest、UI振る舞いをStorybookで分離する。

## Package by Feature

- ディレクトリは機能単位で分割する。
- 1つのfeatureに `api/` `components/` `containers/` `model/` `state/` `__tests__/` などを同居させる。
- 変更の影響範囲をfeature内に閉じ、探索コストを下げる。

## useEffect Guidance

- https://ja.react.dev/learn/you-might-not-need-an-effect
- 不要なEffectを排除し、render主体の実装へ寄せる。
- 派生可能な状態はrender時に計算し、stateへミラーしない。
- イベント起点の処理はイベントハンドラで実行し、Effectに逃がさない。
- `useEffect + useState` による手動フェッチを避ける。

## Data Fetching and Suspense

- TanStack Queryは`useSuspenseQuery`系を優先する。
- `isLoading`中心の分岐ではなく、`Suspense`と`ErrorBoundary`で状態を扱う。

## State Management and Dependency Injection

- 広域状態はJotaiまたはZustandを使う。
- DIが必要な箇所はBunshiを使い、テストで依存差し替えを可能にする。

## Testing Strategy

- Vitest: React非依存のビジネスロジックを検証する。
- Storybook: React UIロジック（表示状態、操作、境界条件）を検証する。
