if vim.fn.exists("+termguicolors") == 1 then
  vim.opt.termguicolors = true
end

pcall(vim.cmd.colorscheme, "dms")
