# コミット分割リファレンス

## 目次

- [よく使う Git コマンド](#よく使う-git-コマンド)
- [チェックポイント方式](#チェックポイント方式)
- [グループ化の優先順位](#グループ化の優先順位)
- [type 選択の目安](#type-選択の目安)
- [Hunk 単位のパッチステージング](#hunk-単位のパッチステージング)
- [安全ルール](#安全ルール)

## よく使う Git コマンド

| 目的 | コマンド |
| --- | --- |
| 変更ファイル一覧 | `git diff HEAD --name-only` |
| 変更種別付きの一覧 | `git diff HEAD --name-status` |
| 変更規模 | `git diff HEAD --stat` |
| 特定ファイルの差分 | `git diff HEAD -- <file>` |
| ステージ済み差分 | `git diff --cached -- <file>` |
| 直近のメッセージ傾向 | `git log --oneline -20` |

## チェックポイント方式

分割コミットを実行する場合は、最初に全差分を 1 つの一時コミットとして保存し、その commit tree を正解として残す。

```bash
git add -A
git commit -m "chore: semantic commit checkpoint"
checkpoint=$(git rev-parse HEAD)
base=$(git rev-parse "${checkpoint}^")
git reset --mixed "$base"
```

その後、通常どおり意味単位で分割してコミットする。すべての分割コミットが終わったら、最終 `HEAD` とチェックポイントを比較する。

```bash
git diff --stat "$checkpoint" HEAD
git diff --exit-code "$checkpoint" HEAD
```

`git diff --exit-code` が成功すれば、分割前の成果物と分割後の成果物は一致している。差分が出た場合は、分割漏れや hunk の取り違えがあるため、差分を確認して停止する。

この方式で `git reset --mixed` してよいのは、直前に自分で作ったチェックポイントコミットだけ。既存のコミットやユーザーの作業を戻すために使わない。

## グループ化の優先順位

1. 機能またはドメインの境界
   - `src/auth/*` は認証領域として扱う
   - `packages/api/*` は API パッケージとして扱う
   - `docs/*` は、特定の実装コミットに強く紐づかない限り docs として扱う

2. 依存関係
   - スキーマや型の変更は、それを必要とするコードと同じグループにする
   - コンポーネントと同じ場所にある style 変更は同じグループにする
   - 生成された API client は、生成元の変更から直接発生している場合だけ同じグループにする

3. 変更種別
   - 1 つの振る舞いだけを検証するテストは、その実装と同じコミット、または直後の `test:` コミットにする
   - CI と自動化は `ci:` にする
   - フォーマットのみの変更は `style:` にする

4. コミットサイズ
   - 1 コミットはおおむね 3 から 8 ファイルを目安にする
   - 10 ファイルを超える場合は、強く結合していない限り分割する
   - 目的が明確なら 1 ファイルだけのコミットでもよい

## type 選択の目安

メッセージは `feat: メッセージ` のように、type と件名だけで書く。scope は原則使わない。

| パターン | type | 補足 |
| --- | --- | --- |
| ユーザーに見える機能追加 | `feat` | UI、エンドポイント、ワークフロー、機能の追加 |
| バグ修正 | `fix` | 強く紐づく回帰テストは含めてよい |
| ドキュメントのみ | `docs` | 無関係な設定変更を混ぜない |
| テストのみ | `test` | 実装コミットの説明に必須でない場合に使う |
| 振る舞いを変えない構造変更 | `refactor` | 機能追加や修正を含めない |
| フォーマットのみ | `style` | コードの振る舞いを変えない |
| ワークフローまたは CI | `ci` | GitHub Actions、リリース自動化、CI script |
| 依存関係またはビルドツール | `build` | build 設定、bundler、package manager |
| リポジトリ保守 | `chore` | なるべく具体的な type を優先する |

## Hunk 単位のパッチステージング

対話的ステージングだけでは扱いにくい場合にのみ使う。

```bash
tmpdir=$(mktemp -d)
git diff HEAD -- path/to/file > "$tmpdir/full.patch"
```

論理グループごとにパッチを作る。各パッチには次を残す。

- `diff --git` ヘッダー
- `---` と `+++` のファイルヘッダー
- 完全な `@@` hunk ヘッダー
- `git apply` に必要な未変更の context 行

1 つのパッチをステージングし、内容を確認する。

```bash
git apply --cached "$tmpdir/group.patch"
git diff --cached -- path/to/file
git diff -- path/to/file
```

パッチ適用に失敗した場合は停止し、`git add -p` を使うかパッチを修正する。不確かな部分ステージングを強行しない。

## 安全ルール

- ユーザーの変更を保持する。分割を楽にするために unstaged / staged の作業を捨てない。
- 既にステージング済みの変更がある場合は、index を触る前にコミット計画へ含めるべきか確認する。
- `git reset --hard`、`git checkout -- <file>` などの破壊的な cleanup を実行しない。
- `git reset --mixed` は、チェックポイント方式で直前に作った一時コミットを戻す場合にだけ使う。
- GPG 署名を無効化しない。
- hook がファイルを変更した場合は、再コミット前に新しい差分を確認する。
- 同じ hook で 2 回失敗した場合は停止し、阻害要因を報告する。
