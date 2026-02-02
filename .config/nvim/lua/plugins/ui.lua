return {
  -- Lualine (statusline)
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- Custom transparent theme based on onedark
      local colors = {
        blue = "#61afef",
        green = "#98c379",
        purple = "#c678dd",
        cyan = "#56b6c2",
        red = "#e06c75",
        yellow = "#e5c07b",
        fg = "#abb2bf",
        bg = "none",
        inactive_bg = "none",
      }

      local transparent_theme = {
        normal = {
          a = { fg = colors.blue, bg = colors.bg, gui = "bold" },
          b = { fg = colors.fg, bg = colors.bg },
          c = { fg = colors.fg, bg = colors.bg },
        },
        insert = {
          a = { fg = colors.green, bg = colors.bg, gui = "bold" },
          b = { fg = colors.fg, bg = colors.bg },
          c = { fg = colors.fg, bg = colors.bg },
        },
        visual = {
          a = { fg = colors.purple, bg = colors.bg, gui = "bold" },
          b = { fg = colors.fg, bg = colors.bg },
          c = { fg = colors.fg, bg = colors.bg },
        },
        replace = {
          a = { fg = colors.red, bg = colors.bg, gui = "bold" },
          b = { fg = colors.fg, bg = colors.bg },
          c = { fg = colors.fg, bg = colors.bg },
        },
        command = {
          a = { fg = colors.yellow, bg = colors.bg, gui = "bold" },
          b = { fg = colors.fg, bg = colors.bg },
          c = { fg = colors.fg, bg = colors.bg },
        },
        inactive = {
          a = { fg = colors.fg, bg = colors.inactive_bg },
          b = { fg = colors.fg, bg = colors.inactive_bg },
          c = { fg = colors.fg, bg = colors.inactive_bg },
        },
      }

      require("lualine").setup({
        options = {
          theme = transparent_theme,
          globalstatus = true,
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = {
            statusline = { "dashboard", "alpha" },
          },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = {
            { "filename", path = 1 },
          },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        extensions = { "oil", "lazy" },
      })

      -- Clear statusline background
      vim.api.nvim_set_hl(0, "StatusLine", { bg = "none" })
      vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "none" })
    end,
  },

  -- Bufferline (tabs)
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          themable = true,
          numbers = "none",
          close_command = "bdelete! %d",
          right_mouse_command = "bdelete! %d",
          left_mouse_command = "buffer %d",
          middle_mouse_command = nil,
          indicator = {
            icon = "▎",
            style = "icon",
          },
          buffer_close_icon = "󰅖",
          modified_icon = "●",
          close_icon = "",
          left_trunc_marker = "",
          right_trunc_marker = "",
          max_name_length = 30,
          max_prefix_length = 30,
          tab_size = 21,
          diagnostics = "nvim_lsp",
          diagnostics_update_in_insert = false,
          diagnostics_indicator = function(count, level, diagnostics_dict, context)
            local icon = level:match("error") and " " or " "
            return " " .. icon .. count
          end,
          offsets = {
            {
              filetype = "neo-tree",
              text = "File Explorer",
              highlight = "Directory",
              text_align = "left",
            },
          },
          color_icons = true,
          show_buffer_icons = true,
          show_buffer_close_icons = true,
          show_close_icon = true,
          show_tab_indicators = true,
          persist_buffer_sort = true,
          separator_style = "thin",
          enforce_regular_tabs = true,
          always_show_bufferline = true,
          hover = {
            enabled = true,
            delay = 200,
            reveal = { "close" },
          },
        },
        highlights = {
          fill = { bg = "none" },
          background = { bg = "none" },
          tab = { bg = "none" },
          tab_selected = { bg = "none" },
          tab_separator = { bg = "none" },
          tab_separator_selected = { bg = "none" },
          tab_close = { bg = "none" },
          close_button = { bg = "none" },
          close_button_visible = { bg = "none" },
          close_button_selected = { bg = "none" },
          buffer_visible = { bg = "none" },
          buffer_selected = { bg = "none", bold = true, italic = false },
          numbers = { bg = "none" },
          numbers_visible = { bg = "none" },
          numbers_selected = { bg = "none" },
          diagnostic = { bg = "none" },
          diagnostic_visible = { bg = "none" },
          diagnostic_selected = { bg = "none" },
          hint = { bg = "none" },
          hint_visible = { bg = "none" },
          hint_selected = { bg = "none" },
          hint_diagnostic = { bg = "none" },
          hint_diagnostic_visible = { bg = "none" },
          hint_diagnostic_selected = { bg = "none" },
          info = { bg = "none" },
          info_visible = { bg = "none" },
          info_selected = { bg = "none" },
          info_diagnostic = { bg = "none" },
          info_diagnostic_visible = { bg = "none" },
          info_diagnostic_selected = { bg = "none" },
          warning = { bg = "none" },
          warning_visible = { bg = "none" },
          warning_selected = { bg = "none" },
          warning_diagnostic = { bg = "none" },
          warning_diagnostic_visible = { bg = "none" },
          warning_diagnostic_selected = { bg = "none" },
          error = { bg = "none" },
          error_visible = { bg = "none" },
          error_selected = { bg = "none" },
          error_diagnostic = { bg = "none" },
          error_diagnostic_visible = { bg = "none" },
          error_diagnostic_selected = { bg = "none" },
          modified = { bg = "none" },
          modified_visible = { bg = "none" },
          modified_selected = { bg = "none" },
          duplicate_selected = { bg = "none" },
          duplicate_visible = { bg = "none" },
          duplicate = { bg = "none" },
          separator_selected = { bg = "none" },
          separator_visible = { bg = "none" },
          separator = { bg = "none" },
          indicator_visible = { bg = "none" },
          indicator_selected = { bg = "none" },
          pick_selected = { bg = "none" },
          pick_visible = { bg = "none" },
          pick = { bg = "none" },
          offset_separator = { bg = "none" },
          trunc_marker = { bg = "none" },
        },
      })
    end,
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPre", "BufNewFile" },
    main = "ibl",
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = {
        enabled = true,
        show_start = true,
        show_end = false,
      },
      exclude = {
        filetypes = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
      },
    },
  },
}
