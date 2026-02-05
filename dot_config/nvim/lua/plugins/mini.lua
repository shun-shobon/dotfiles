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
    end,
  },
}
