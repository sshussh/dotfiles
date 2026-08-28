-- Matugen's runtime colorscheme is intentionally separate from this user config.
local matugen_runtime = vim.fn.expand("~/.config/matugen/runtime/vim")

if vim.fn.isdirectory(matugen_runtime) == 1 then
  vim.opt.runtimepath:prepend(matugen_runtime)
end

if vim.fn.exists("+termguicolors") == 1 then
  vim.opt.termguicolors = true
end

pcall(vim.cmd.colorscheme, "matugen")
