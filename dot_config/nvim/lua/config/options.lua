-- バッファやレジスタ内で使用する文字コードを指定
vim.o.encoding = "utf-8"

-- 既存ファイルを開くときにVimが使用する文字コードを判定する順番を指定
vim.o.fileencodings = "utf-8,iso-2033-jp,enc-jp,sjis"

-- viminfoファイルの出力先を変更
vim.o.viminfo = vim.o.viminfo .. ",n" .. vim.fn.stdpath("cache") .. "/info"

-- Undo履歴を永続化
vim.o.undodir = vim.fn.stdpath("cache") .. "/undo"
vim.bo.undofile = true

-- 行番号を表示
vim.wo.number = true

-- スクロールにオフセットを持たせる
vim.wo.scrolloff = 5

-- 自動改行を無効化
vim.bo.textwidth = 0

-- 不可視文字を表示
vim.wo.list = true
-- 不可視文字のスタイルを変更
vim.o.listchars = "tab:»-,trail:-,extends:»,precedes:«,nbsp:%,eol:↵"

-- カーソルラインを表示
vim.wo.cursorline = true

-- タブラインを常に表示
vim.o.showtabline = 2

-- 検索結果を自動ハイライト
vim.o.hlsearch = true

-- 手動インデント時に"shiftwidth"の倍数に丸める
vim.o.shiftround = true

-- 矩形選択時にテキストが存在しない部分でも選択できるようにする
vim.o.virtualedit = "block"

-- バッファを閉じずに隠す
vim.o.hidden = true

-- ファイルを新しく開く代わりにすでに開いてあるバッファを使用する
vim.o.switchbuf = "useopen"

-- 対応する括弧をハイライト表示する
vim.o.showmatch = true
-- ハイライト表示の時間を設定
vim.o.matchtime = 2

-- タブ入力をスペースに置き換え
vim.bo.expandtab = true
-- インデントを考慮して改行する
vim.bo.smartindent = true
-- インデント幅を設定
vim.o.shiftwidth = 2
vim.o.tabstop = 2

-- 補完の仕方を変更
vim.o.completeopt = "menuone,noinsert,noselect"

-- 補完を透過させる
vim.o.pumblend = 10

-- 補完時にメッセージを出さない
vim.o.shortmess = vim.o.shortmess .. "c"

-- フローティングの枠を設定
vim.o.winborder = "rounded"

-- ヘルプの言語を日本語を第一にする
vim.opt.helplang:prepend('ja')
