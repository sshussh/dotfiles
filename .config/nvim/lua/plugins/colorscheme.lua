return {
  "navarasu/onedark.nvim",
  priority = 1000,
  config = function()
    require("onedark").setup({
      style = "dark", -- Options: dark, darker, cool, deep, warm, warmer
      transparent = true,
      term_colors = true,
      ending_tildes = false,
      cmp_itemkind_reverse = false,

      code_style = {
        comments = "italic",
        keywords = "none",
        functions = "none",
        strings = "none",
        variables = "none",
      },

      lualine = {
        transparent = true,
      },

      diagnostics = {
        darker = true,
        undercurl = true,
        background = false,
      },

      -- Override highlight groups for transparency
      highlights = {
        TabLineFill = { bg = "none" },
        TabLine = { bg = "none" },
        TabLineSel = { bg = "none" },
      },
    })
    require("onedark").load()

    -- Force clear tabline background after colorscheme loads
    vim.api.nvim_set_hl(0, "TabLineFill", { bg = "none" })
    vim.api.nvim_set_hl(0, "TabLine", { bg = "none" })
    vim.api.nvim_set_hl(0, "TabLineSel", { bg = "none" })
  end,
}
