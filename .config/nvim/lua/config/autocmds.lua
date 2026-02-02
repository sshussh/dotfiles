local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- General settings group
local general = augroup("General", { clear = true })

-- Highlight on yank
autocmd("TextYankPost", {
	group = general,
	callback = function()
		vim.hl.on_yank({ higroup = "IncSearch", timeout = 200 })
	end,
})

-- Remove whitespace on save
autocmd("BufWritePre", {
	group = general,
	pattern = "*",
	command = [[%s/\s\+$//e]],
})

-- Restore cursor position
autocmd("BufReadPost", {
	group = general,
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Close some filetypes with <q>
autocmd("FileType", {
	group = general,
	pattern = {
		"help",
		"lspinfo",
		"man",
		"notify",
		"qf",
		"checkhealth",
		"startuptime",
		"neotest-output",
		"neotest-output-panel",
		"neotest-summary",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
	end,
})

-- Auto create dir when saving a file
autocmd("BufWritePre", {
	group = general,
	callback = function(event)
		if event.match:match("^%w%w+://") then
			return
		end
		local file = vim.loop.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

-- Check if file changed outside of vim
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = general,
	callback = function()
		if vim.o.buftype ~= "nofile" then
			vim.cmd("checktime")
		end
	end,
})

-- Resize splits if window got resized
autocmd("VimResized", {
	group = general,
	callback = function()
		local current_tab = vim.fn.tabpagenr()
		vim.cmd("tabdo wincmd =")
		vim.cmd("tabnext " .. current_tab)
	end,
})

-- Set specific options for certain filetypes
autocmd("FileType", {
	group = general,
	pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact", "json", "yaml", "lua" },
	callback = function()
		vim.opt_local.tabstop = 2
		vim.opt_local.shiftwidth = 2
		vim.opt_local.softtabstop = 2
	end,
})
