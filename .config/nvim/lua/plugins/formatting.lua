return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = "",
      desc = "Format buffer",
    },
  },
  opts = {
    formatters_by_ft = {
      python = { "ruff_format", "ruff_fix" },
      rust = { "rustfmt" },
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
      json = { "prettier" },
      yaml = { "prettier" },
      html = { "prettier" },
      css = { "prettier" },
      markdown = { "prettier" },
      go = { "gofmt", "goimports" },
      lua = { "stylua" },
    },
    format_on_save = {
      timeout_ms = 3000,
      lsp_fallback = true,
    },
    formatters = {
      ruff_format = {
        command = "ruff",
        args = { "format", "--stdin-filename", "$FILENAME", "-" },
        stdin = true,
      },
      ruff_fix = {
        command = "ruff",
        args = { "check", "--fix", "--stdin-filename", "$FILENAME", "-" },
        stdin = true,
      },
    },
  },
  init = function()
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}
