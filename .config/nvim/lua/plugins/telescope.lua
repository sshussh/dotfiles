return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      defaults = {
        path_display = { "truncate" },
        sorting_strategy = "ascending",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
          },
          vertical = {
            mirror = false,
          },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<C-x>"] = actions.delete_buffer,
            ["<esc>"] = actions.close,
          },
        },
        file_ignore_patterns = {
          "node_modules",
          ".git/",
          "target/",
          "dist/",
          "build/",
          "__pycache__/",
          "%.lock",
        },
      },
      pickers = {
        find_files = {
          hidden = true,
        },
        buffers = {
          initial_mode = "normal",
          sort_lastused = true,
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
    })

    telescope.load_extension("fzf")

    -- Keymaps
    local keymap = vim.keymap.set
    keymap("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
    keymap("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
    keymap("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })
    keymap("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help tags" })
    keymap("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Recent files" })
    keymap("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor" })
    keymap("n", "<leader>fd", "<cmd>Telescope diagnostics<cr>", { desc = "Find diagnostics" })
    keymap("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "Document symbols" })
    keymap("n", "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<cr>", { desc = "Workspace symbols" })
    keymap("n", "<leader>fk", "<cmd>Telescope keymaps<cr>", { desc = "Find keymaps" })
  end,
}
