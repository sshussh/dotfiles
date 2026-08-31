-- Reload DMS's generated palette after a wallpaper change without disturbing buffers.
local colorscheme = vim.fn.expand("~/.config/nvim/colors/dms.lua")
local colors_dir = vim.fn.fnamemodify(colorscheme, ":h")

if vim.fn.filereadable(colorscheme) ~= 1 or not vim.uv or not vim.uv.new_fs_event then
  return
end

local watcher = vim.uv.new_fs_event()
if not watcher then
  return
end

local pending = false
local function reload_palette()
  if pending then
    return
  end
  pending = true
  vim.schedule(function()
    pending = false
    if vim.fn.filereadable(colorscheme) == 1 then
      pcall(vim.cmd.colorscheme, "dms")
      vim.cmd("redraw")
    end
  end)
end

local started = pcall(watcher.start, watcher, colors_dir, {}, function(error)
  if error then
    return
  end
  reload_palette()
end)
if not started then
  watcher:close()
  return
end

_G.dms_nvim_palette_watcher = watcher
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    if not watcher:is_closing() then
      watcher:stop()
      watcher:close()
    end
  end,
})
