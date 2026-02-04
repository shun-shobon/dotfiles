local M = {}

function M.setup()
  -- cmp の capabilities を LSP に渡す
  local capabilities = require("cmp_nvim_lsp").default_capabilities()

  -- Diagnostics の表示設定
  vim.diagnostic.config({
    virtual_text = {
      spacing = 2,
      prefix = ">",
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
      border = "rounded",
      source = "if_many",
    },
  })

  -- LSP ヘルスチェック用のコマンド
  vim.api.nvim_create_user_command("LspHealth", "checkhealth vim.lsp", {
    desc = "LSP health check",
  })

  -- LSP キーマップ（対応メソッドのみ設定）
  local on_attach = function(client, bufnr)
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    if client:supports_method("textDocument/definition") then
      map("n", "gd", vim.lsp.buf.definition, "LSP: Go to definition")
    end
    if client:supports_method("textDocument/declaration") then
      map("n", "gD", vim.lsp.buf.declaration, "LSP: Go to declaration")
    end
    if client:supports_method("textDocument/implementation") then
      map("n", "gi", vim.lsp.buf.implementation, "LSP: Go to implementation")
    end
    if client:supports_method("textDocument/references") then
      map("n", "gr", vim.lsp.buf.references, "LSP: References")
    end
    if client:supports_method("textDocument/hover") then
      map("n", "K", vim.lsp.buf.hover, "LSP: Hover")
    end
    if client:supports_method("textDocument/rename") then
      map("n", "<leader>rn", vim.lsp.buf.rename, "LSP: Rename")
    end
    if client:supports_method("textDocument/codeAction") then
      map("n", "<leader>ca", vim.lsp.buf.code_action, "LSP: Code action")
      map({ "n", "v" }, "<D-.>", vim.lsp.buf.code_action, "LSP: Code action")
    end
    if client:supports_method("textDocument/formatting") then
      map("n", "<leader>f", function()
        vim.lsp.buf.format({ async = true, bufnr = bufnr, id = client.id })
      end, "LSP: Format")
    end

    map("n", "<leader>e", vim.diagnostic.open_float, "LSP: Diagnostic float")
    map("n", "[d", vim.diagnostic.goto_prev, "LSP: Prev diagnostic")
    map("n", "]d", vim.diagnostic.goto_next, "LSP: Next diagnostic")
  end

  local base_config = {
    capabilities = capabilities,
    on_attach = on_attach,
  }

  local servers = {
    "lua_ls",
    "ts_ls",
    "eslint",
    "html",
    "cssls",
    "jsonls",
    "tailwindcss",
    "astro",
  }

  local function merge_opts(name)
    local ok, opts = pcall(require, "lsp." .. name)
    if ok then
      return vim.tbl_deep_extend("force", base_config, opts)
    end
    return base_config
  end

  -- Nvim 0.11+ API を優先。古い版はフォールバック
  if vim.lsp.config then
    -- 全サーバ共通のデフォルト
    vim.lsp.config("*", base_config)
    for _, name in ipairs(servers) do
      local ok, opts = pcall(require, "lsp." .. name)
      if ok then
        vim.lsp.config(name, opts)
      end
    end
    vim.lsp.enable(servers)
  else
    local lspconfig = require("lspconfig")
    for _, name in ipairs(servers) do
      lspconfig[name].setup(merge_opts(name))
    end
  end
end

return M
