local autocmd = require("autocmd")

-- 検索時のみ大文字小文字を区別しない
--cmd("autocmd init CmdlineEnter [/?] set ignorecase")
--cmd("autocmd init CmdlineLeave [/?] set noignorecase")
autocmd.create_autocmd("CmdlineEnter", {
  pattern = "[/?]",
  callback = function()
    vim.o.ignorecase = true
  end,
})
autocmd.create_autocmd("CmdlineLeave", {
  pattern = "[/?]",
  callback = function()
    vim.o.ignorecase = false
  end,
})

-- 大文字が含まれる場合は区別する
vim.o.smartcase = true

-- インクリメンタルサーチを有効化
vim.o.incsearch = true

-- バックスラッシュやエクステンションを自動エスケープ
vim.api.nvim_set_keymap(
  "c",
  "/",
  "getcmdtype() == '/' ? '\\/' : '/'",
  { noremap = true, expr = true }
)
vim.api.nvim_set_keymap(
  "c",
  "?",
  "getcmdtype() == '?' ? '\\?' : '?'",
  { noremap = true, expr = true }
)

-- 挿入モード中にjjで<Esc>
vim.api.nvim_set_keymap("i", "jj", "<Esc>", { noremap = true })

-- [Prefix]というマッピングを追加
vim.api.nvim_set_keymap("n", "[Prefix]", "", { noremap = true })
-- <Space>に[Prefix]を割り当て
vim.api.nvim_set_keymap("n", "<Space>", "[Prefix]", {})

-- 表示行でj, k移動
vim.api.nvim_set_keymap("n", "j", "gj", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "k", "gk", { noremap = true, silent = true })

-- vx2で行末まで選択
vim.api.nvim_set_keymap("v", "v", "$h", { noremap = true })

-- Ctrl + hjklでウィンドウ間移動
vim.api.nvim_set_keymap("n", "<C-h>", "<C-w>h", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-j>", "<C-w>j", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-k>", "<C-w>k", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-l>", "<C-w>l", { noremap = true })
-- Ctrl + 矢印キーでウィンドウリサイズ
vim.api.nvim_set_keymap("n", "<S-Left>", "<C-w><", { noremap = true })
vim.api.nvim_set_keymap("n", "<S-Down>", "<C-w>+", { noremap = true })
vim.api.nvim_set_keymap("n", "<S-Up>", "<C-w>-", { noremap = true })
vim.api.nvim_set_keymap("n", "<S-Right>", "<C-w>>", { noremap = true })

-- QuickFix及びHelpではqで閉じる
--cmd("autocmd init FileType help,qf nnoremap <buffer> q <C-w>c")
autocmd.create_autocmd("FileType", {
  pattern = "help,qf",
  callback = function(event)
    vim.api.nvim_set_keymap("n", "q", "<C-w>c", { noremap = true, buffer = event.buf })
  end,
})

-- w!!でスーパーユーザーとして保存
vim.api.nvim_set_keymap("c", "w!!", "w !sudo tee > /dev/null %", {})

-- H, Lで行頭、行末へ移動
vim.api.nvim_set_keymap("n", "H", "^", { noremap = true })
vim.api.nvim_set_keymap("n", "L", "$", { noremap = true })

-- [Prefix] + tでターミナルを開く
vim.api.nvim_set_keymap(
  "n",
  "[Prefix]t",
  "<Cmd>botright 20split +term<CR>i",
  { noremap = true, silent = true }
)

-- make, grepなどのコマンドの後に自動的にQuickFixを開く
--cmd("autocmd init QuickfixCmdPost make,grep,grepadd,vimgrep copen")
autocmd.create_autocmd("QuickfixCmdPost", {
  pattern = "make,grep,grepadd,vimgrep",
  callback = function()
    vim.cmd("copen")
  end,
})

-- フォルダが存在しない場合に自動作成する
autocmd.create_autocmd('BufWritePre', {
  pattern = '*',
  callback = function(event)
    local dir = vim.fs.dirname(event.file)
    local force = vim.v.cmdbang == 1
    if vim.fn.isdirectory(dir) == 0
        and (force or vim.fn.confirm('"' .. dir .. '" does not exist. Create?', "&Yes\n&No") == 1) then
      vim.fn.mkdir(vim.fn.iconv(dir, vim.opt.encoding:get(), vim.opt.termencoding:get()), 'p')
    end
  end,
})
