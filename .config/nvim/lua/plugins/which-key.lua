return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  opts = {
    plugins = {
      marks = true,
      registers = true,
      spelling = {
        enabled = true,
        suggestions = 20,
      },
      presets = {
        operators = true,
        motions = true,
        text_objects = true,
        windows = true,
        nav = true,
        z = true,
        g = true,
      },
    },
    win = {
      border = "rounded",
      padding = { 2, 2, 2, 2 },
    },
    layout = {
      height = { min = 4, max = 25 },
      width = { min = 20, max = 50 },
      spacing = 3,
      align = "left",
    },
    icons = {
      breadcrumb = "»",
      separator = "➜",
      group = "+",
    },
    show_help = true,
    show_keys = true,
    spec = {
      { "<leader>f", group = "Find/Files" },
      { "<leader>g", group = "Git" },
      { "<leader>c", group = "Code/Quickfix" },
      { "<leader>l", group = "Location list" },
      { "<leader>s", group = "Split" },
      { "<leader>r", group = "Rename/Restart" },
    },
  },
}
