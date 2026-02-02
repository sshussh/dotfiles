local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Better escape
keymap("i", "jk", "<ESC>", opts)

-- Save file
keymap("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })

-- Quit
keymap("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })

-- Save and quit
keymap("n", "<leader>wq", "<cmd>wq<cr>", { desc = "Save and quit" })

-- Clear search highlight
keymap("n", "<leader>nh", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- Delete single character without copying into register
keymap("n", "x", '"_x', opts)

-- Increment/decrement numbers
keymap("n", "<leader>+", "<C-a>", { desc = "Increment number" })
keymap("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

-- Window management
keymap("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap("n", "<leader>sx", "<cmd>close<cr>", { desc = "Close current split" })

-- Navigate between splits
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Resize with arrows
keymap("n", "<C-Up>", "<cmd>resize +2<cr>", opts)
keymap("n", "<C-Down>", "<cmd>resize -2<cr>", opts)
keymap("n", "<C-Left>", "<cmd>vertical resize -2<cr>", opts)
keymap("n", "<C-Right>", "<cmd>vertical resize +2<cr>", opts)

-- Buffer navigation
keymap("n", "<Tab>", "<cmd>bnext<cr>", { desc = "Next buffer" })
keymap("n", "<S-Tab>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
keymap("n", "<leader>x", "<cmd>bdelete<cr>", { desc = "Close buffer" })
keymap("n", "<leader>X", "<cmd>bdelete!<cr>", { desc = "Force close buffer" })

-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up and down
keymap("v", "J", ":m '>+1<cr>gv=gv", opts)
keymap("v", "K", ":m '<-2<cr>gv=gv", opts)

-- Keep cursor centered when scrolling
keymap("n", "<C-d>", "<C-d>zz", opts)
keymap("n", "<C-u>", "<C-u>zz", opts)

-- Keep cursor centered when searching
keymap("n", "n", "nzzzv", opts)
keymap("n", "N", "Nzzzv", opts)

-- Paste without overwriting register
keymap("v", "p", '"_dP', opts)

-- Better join
keymap("n", "J", "mzJ`z", opts)

-- Quick fix navigation
keymap("n", "<leader>cn", "<cmd>cnext<cr>zz", { desc = "Next quickfix" })
keymap("n", "<leader>cp", "<cmd>cprev<cr>zz", { desc = "Previous quickfix" })

-- Location list navigation
keymap("n", "<leader>ln", "<cmd>lnext<cr>zz", { desc = "Next location" })
keymap("n", "<leader>lp", "<cmd>lprev<cr>zz", { desc = "Previous location" })

-- Select all
keymap("n", "<C-a>", "gg<S-v>G", { desc = "Select all" })
