# セマンティックコミットの分割例

## 目次

- [例 1: 認証機能の追加](#例-1-認証機能の追加)
- [例 2: バグ修正とリファクタリングの混在](#例-2-バグ修正とリファクタリングの混在)
- [例 3: 複数の独立した機能追加](#例-3-複数の独立した機能追加)
- [例 4: 機能追加に混ざった機械的な整形](#例-4-機能追加に混ざった機械的な整形)

## 例 1: 認証機能の追加

分割前:

```text
src/auth/login.ts
src/auth/register.ts
src/auth/password.ts
src/api/auth-routes.ts
src/db/migrations/001_users.sql
src/db/models/user.ts
tests/auth/login.test.ts
tests/auth/register.test.ts
docs/authentication.md
package.json
.env.example
```

分割後:

```text
feat: 認証用のユーザースキーマを追加
- src/db/migrations/001_users.sql
- src/db/models/user.ts

feat: ログインと登録処理を追加
- src/auth/login.ts
- src/auth/register.ts
- src/auth/password.ts
- src/api/auth-routes.ts

test: 認証処理のテストを追加
- tests/auth/login.test.ts
- tests/auth/register.test.ts

docs: 認証設定の説明を追加
- docs/authentication.md
- .env.example
```

`package.json` は、その依存関係を最初に必要とするコミットに含める。複数のグループが同じ依存関係を等しく必要とする場合は、実装コミットの前に小さな `build:` コミットを作る。

## 例 2: バグ修正とリファクタリングの混在

分割前:

```text
src/user/service.ts       # バグ修正とリファクタリング
src/user/validator.ts     # 抽出した helper
src/auth/middleware.ts    # バグ修正
tests/user.test.ts        # リファクタリング後のテスト
tests/auth.test.ts        # バグの回帰テスト
docs/user-api.md
```

分割後:

```text
fix: 認証ミドルウェアの検証漏れを修正
- src/auth/middleware.ts
- tests/auth.test.ts
- src/user/service.ts の bug-fix hunk のみ

refactor: ユーザー検証ロジックを分離
- src/user/service.ts の refactor hunk のみ
- src/user/validator.ts
- tests/user.test.ts

docs: ユーザーAPIの説明を更新
- docs/user-api.md
```

`git add -p src/user/service.ts` またはパッチステージングを使い、バグ修正とリファクタリングが同じコミットに入らないようにする。

## 例 3: 複数の独立した機能追加

分割前:

```text
src/profile/*
src/notification/*
src/dashboard/*
tests/profile.test.ts
tests/notification.test.ts
tests/dashboard.test.ts
package.json
```

分割後:

```text
feat: プロフィール管理を追加
- src/profile/*
- tests/profile.test.ts

feat: 通知送信を追加
- src/notification/*
- tests/notification.test.ts

feat: ダッシュボードウィジェットを追加
- src/dashboard/*
- tests/dashboard.test.ts
```

依存関係の変更は、それを最初に必要とする機能コミットに含める。共有依存で、単体でもレビュー可能な場合は、先行する `build:` コミットを作る。

## 例 4: 機能追加に混ざった機械的な整形

分割前:

```text
src/messages/compose.tsx  # 新機能
src/messages/list.tsx     # フォーマットのみ
src/messages/types.ts     # 新機能用の型
```

分割後:

```text
feat: メッセージ作成画面を追加
- src/messages/compose.tsx
- src/messages/types.ts

style: メッセージ一覧の整形を適用
- src/messages/list.tsx
```

別々にレビューできるフォーマット変更は、機能コミットに隠さず分ける。
