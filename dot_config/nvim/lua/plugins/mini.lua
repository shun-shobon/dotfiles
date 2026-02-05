-- augroup for this config file
local augroup = vim.api.nvim_create_augroup("plugins/mini.lua", {})

-- wrapper function to use internal augroup
local function create_autocmd(event, opts)
  vim.api.nvim_create_autocmd(event, vim.tbl_extend('force', {
    group = augroup,
  }, opts))
end

return {
  {
    "nvim-mini/mini.nvim",
    version = false,
    priority = 0,
    config = function()
      -- アイコン関連の前提ライブラリ
      require("mini.icons").setup()

      -- 基本設定系
      require("mini.basics").setup({
        options = {
          -- 追加のUI設定を有効化
          extra_ui = true,
        },
        mappings = {
          -- C+hjklでウィンドウ移動やAlt+←↓↑→でリサイズなどのキーバインドを有効化
          windows = true,
        },
        autocommands = {
          -- 行選択時に行番号を相対化
          relnum_in_visual_mode = true,
        },
      })

      -- ステータスラインをかっこよく
      require("mini.statusline").setup()
      -- 画面分割時のボーダーを細くする
      vim.opt.laststatus = 3

      -- 通知をかっこよく
      require("mini.notify").setup()
      vim.notify = require("mini.notify").make_notify({})

      -- 現在カーソルがある単語をハイライト
      require("mini.cursorword").setup()

      -- インデントの深さを分かりやすく
      require("mini.indentscope").setup()

      -- 行末の空白を可視化
      require("mini.trailspace").setup()

      -- スタート画面を追加
      require("mini.starter").setup()

      -- ペアの文字を自動入力
      require("mini.pairs").setup()

      -- 囲み系の操作を追加
      require("mini.surround").setup()

      -- テキストオブジェクトを追加
      require("mini.ai").setup()

      -- コンビネーションキー入力時にヘルプを出す
      local function mode_nx(keys)
        return { mode = "n", keys = keys }, { mode = "x", keys = keys }
      end
      local clue = require("mini.clue")
      clue.setup({
        triggers = {
          -- Leader triggers
          mode_nx("<leader>"),

          -- Built-in completion
          { mode = "i", keys = "<c-x>" },

          -- `g` key
          mode_nx("g"),

          -- Marks
          mode_nx("'"),
          mode_nx('`'),

          -- Registers
          mode_nx('"'),
          { mode = "i", keys = "<c-r>" },
          { mode = "c", keys = "<c-r>" },

          -- Window commands
          { mode = "n", keys = "<c-w>" },

          -- bracketed commands
          { mode = "n", keys = "[" },
          { mode = "n", keys = "]" },

          -- `z` key
          mode_nx("z"),

          -- surround
          mode_nx("s"),

          -- text object
          { mode = "x", keys = "i" },
          { mode = "x", keys = "a" },
          { mode = "o", keys = "i" },
          { mode = "o", keys = "a" },

          -- option toggle (mini.basics)
          { mode = "n", keys = "m" },
        },

        clues = {
          -- Enhance this by adding descriptions for <Leader> mapping groups
          clue.gen_clues.builtin_completion(),
          clue.gen_clues.g(),
          clue.gen_clues.marks(),
          clue.gen_clues.registers({ show_contents = true }),
          clue.gen_clues.windows({ submode_resize = true, submode_move = true }),
          clue.gen_clues.z(),
        },
      })

      -- LSPの設定
      vim.diagnostic.config({
        virtual_text = true
      })
      vim.lsp.config("*", {
        root_markers = { ".git" },
      })
      vim.lsp.config("lua_ls", {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        on_init = function(client)
          if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if path ~= vim.fn.stdpath("config") and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc")) then
              return
            end
          end
          client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
            runtime = { version = "LuaJIT" },
            workspace = {
              checkThirdParty = false,
              library = vim.list_extend(vim.api.nvim_get_runtime_file("lua", true), {
                "${3rd}/luv/library",
                "${3rd}/busted/library",
              }),
            }
          })
        end,
        settings = {
          Lua = {
            diagnostics = {
              -- 未使用変数は冒頭に`_`をつけていれば警告なし
              unusedLocalExclude = { "_*" }
            }
          }
        }
      })
      vim.lsp.enable("lua_ls")
      vim.api.nvim_create_autocmd("LspAttach", {
        group = augroup,
        callback = function(args)
          local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

          vim.keymap.set("n", "grd", function()
            vim.lsp.buf.definition()
          end, { buffer = args.buf, desc = "vim.lsp.buf.definition()" })

          vim.keymap.set("n", "<space>i", function()
            vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
          end, { buffer = args.buf, desc = "Format buffer" })
        end,
      })

      -- 補完の設定
      require("mini.fuzzy").setup()
      require("mini.completion").setup({
        lsp_completion = {
          -- 曖昧な絞り込みに対応
          process_items = MiniFuzzy.process_lsp_items,
        },
      })

      -- 補完精度の向上
      vim.opt.complete = { ".", "w", "k", "b", "u" }
      -- 先頭候補を自動選択しつつ、確定まではバッファに挿入しない
      vim.opt.completeopt = { "menuone", "noinsert", "fuzzy" }
      vim.opt.dictionary:append("/usr/share/dict/words")

      -- キーマップの設定
      local map_multistep = require("mini.keymap").map_multistep
      map_multistep("i", "<CR>", { "pmenu_accept", "minipairs_cr" })
    end,
  },
}
