return {
  {
    -- 補完エンジン
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      -- 補完ソース
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      -- スニペットエンジン + ソース + 既存スニペット集
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
      -- 補完メニューの見た目を整形
      "onsails/lspkind.nvim",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      -- VSCode 形式のスニペットを遅延読み込み
      require("luasnip.loaders.from_vscode").lazy_load()

      -- 使い勝手の良い completeopt を明示
      vim.o.completeopt = "menu,menuone,noselect"

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        -- 補完キーマップ（Insert モード）
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        -- 補完/ドキュメントのウィンドウ枠
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        -- ゴーストテキスト（薄い予測表示）
        experimental = {
          ghost_text = true,
        },
        -- 表示の整形（アイコン + 種類）
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol_text",
            maxwidth = 50,
            ellipsis_char = "...",
          }),
        },
        -- 補完ソース
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip", priority = 750 },
          { name = "path", priority = 500 },
        }, {
          { name = "buffer", priority = 250 },
        }),
        -- ソート順のチューニング
        sorting = {
          priority_weight = 2,
          comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
        },
      })

      -- / と ? の検索補完（バッファ）
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      -- : のコマンド補完（パス + コマンド）
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })
    end,
  },
  {
    -- GitHub Copilot（インライン補完）
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = true,
          auto_trigger = true,
          hide_during_completion = true,
          keymap = {
            accept = "<Tab>",
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<Esc>",
          },
        },
        panel = { enabled = true },
      })
    end,
  },
  {
    -- LSP/DAP/リンターのインストール UI
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup()
    end,
  },
  {
    -- mason と lspconfig を連携し、サーバーを自動インストール
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "tsserver",
          "eslint",
          "html",
          "cssls",
          "jsonls",
          "tailwindcss",
          "astro",
        },
        automatic_installation = true,
      })
    end,
  },
  {
    -- mason で formatter/linter も自動インストール
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason.nvim" },
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          "prettierd",
        },
        auto_update = false,
        run_on_start = true,
      })
    end,
  },
  {
    -- LSP クライアント設定（Nvim 0.11+ では data-only）
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("lsp").setup()
    end,
  },
  {
    -- vim.ui.*（select/input）をフローティング表示に置き換え
    "folke/snacks.nvim",
    event = "VeryLazy",
    opts = {
      input = { enabled = true },
      picker = { enabled = true },
    },
    config = function(_, opts)
      local Snacks = require("snacks")
      Snacks.setup(opts)

      -- vim.ui.input / vim.ui.select を Snacks に差し替え
      if Snacks.input and Snacks.input.enable then
        Snacks.input.enable()
      end
      if Snacks.input and Snacks.input.input then
        vim.ui.input = Snacks.input.input
      end
      if Snacks.picker and Snacks.picker.select then
        vim.ui.select = Snacks.picker.select
      end
    end,
  },
  {
    -- フォーマッタ（Prettier など）
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local conform = require("conform")

      conform.setup({
        formatters_by_ft = {
          javascript = { "prettierd", "prettier" },
          javascriptreact = { "prettierd", "prettier" },
          typescript = { "prettierd", "prettier" },
          typescriptreact = { "prettierd", "prettier" },
          json = { "prettierd", "prettier" },
          jsonc = { "prettierd", "prettier" },
          css = { "prettierd", "prettier" },
          scss = { "prettierd", "prettier" },
          html = { "prettierd", "prettier" },
          markdown = { "prettierd", "prettier" },
          yaml = { "prettierd", "prettier" },
          astro = { "prettierd", "prettier" },
        },
        -- format_on_save は自前で制御（ESLint の fix を先に実行）
        format_on_save = false,
      })

      local function has_eslint(bufnr)
        if vim.lsp.get_clients then
          return #vim.lsp.get_clients({ bufnr = bufnr, name = "eslint" }) > 0
        end
        for _, client in ipairs(vim.lsp.get_active_clients()) do
          if client.name == "eslint" and client.attached_buffers[bufnr] then
            return true
          end
        end
        return false
      end

      local group = vim.api.nvim_create_augroup("FormatOnSave", { clear = true })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = group,
        callback = function(args)
          local bufnr = args.buf

          -- ESLint の fix を先に適用
          if has_eslint(bufnr) then
            vim.lsp.buf.code_action({
              apply = true,
              timeout_ms = 2000,
              context = { only = { "source.fixAll.eslint" } },
            })
          end

          -- その後にフォーマット
          conform.format({
            bufnr = bufnr,
            timeout_ms = 2000,
            lsp_fallback = true,
            quiet = true,
          })
        end,
      })
    end,
  },
}
