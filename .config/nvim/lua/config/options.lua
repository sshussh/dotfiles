local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Tabs & indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true

-- Line wrapping
opt.wrap = false

-- Search settings
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Cursor line
opt.cursorline = true

-- Appearance
opt.termguicolors = true
opt.signcolumn = "yes"
opt.colorcolumn = "100"

-- Backspace
opt.backspace = "indent,eol,start"

-- Clipboard (with OSC 52 fallback for Wayland/SSH)
opt.clipboard = "unnamedplus"

-- OSC 52 clipboard support (works in most modern terminals without external tools)
if vim.fn.has("nvim-0.10") == 1 then
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
      ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
    },
  }
end

-- Split windows
opt.splitright = true
opt.splitbelow = true

-- Consider - as part of word
opt.iskeyword:append("-")

-- Scrolloff
opt.scrolloff = 8
opt.sidescrolloff = 8

-- File handling
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undo"

-- Decrease update time
opt.updatetime = 250
opt.timeoutlen = 300

-- Completion
opt.completeopt = "menuone,noselect"

-- Conceal level for markdown etc
opt.conceallevel = 0

-- Mouse
opt.mouse = "a"

-- Fill chars
opt.fillchars = { eob = " " }

-- Show matching brackets
opt.showmatch = true

-- Command line height (0 hides the space below statusline)
opt.cmdheight = 0
