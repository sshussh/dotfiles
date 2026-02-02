return {
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
            { "folke/neodev.nvim", opts = {} }, -- Better Lua LSP support for Neovim
        },
        config = function()
            -- Setup Mason first
            require("mason").setup({
                ui = {
                    border = "rounded",
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗",
                    },
                },
            })

            require("mason-lspconfig").setup({
                ensure_installed = {
                    "ruff",
                    "rust_analyzer",
                    "ts_ls",
                    "gopls",
                    "lua_ls",
                },
                automatic_installation = true,
            })

            -- LSP keymaps
            local on_attach = function(client, bufnr)
                local map = function(keys, func, desc)
                    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
                end

                map("gd", vim.lsp.buf.definition, "Go to definition")
                map("gD", vim.lsp.buf.declaration, "Go to declaration")
                map("gr", vim.lsp.buf.references, "Go to references")
                map("gi", vim.lsp.buf.implementation, "Go to implementation")
                map("gt", vim.lsp.buf.type_definition, "Go to type definition")
                map("K", vim.lsp.buf.hover, "Hover documentation")
                map("<C-k>", vim.lsp.buf.signature_help, "Signature help")
                map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
                map("<leader>ca", vim.lsp.buf.code_action, "Code action")
                map("<leader>d", vim.diagnostic.open_float, "Show diagnostics")
                map("[d", vim.diagnostic.goto_prev, "Previous diagnostic")
                map("]d", vim.diagnostic.goto_next, "Next diagnostic")
                map("<leader>rs", "<cmd>LspRestart<cr>", "Restart LSP")
            end

            -- Capabilities for autocompletion
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

            -- Diagnostic configuration (using new vim.diagnostic.config signs format)
            vim.diagnostic.config({
                virtual_text = {
                    prefix = "●",
                    source = "if_many",
                },
                float = {
                    border = "rounded",
                    source = "always",
                },
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = " ",
                        [vim.diagnostic.severity.WARN] = " ",
                        [vim.diagnostic.severity.HINT] = "󰠠 ",
                        [vim.diagnostic.severity.INFO] = " ",
                    },
                },
                underline = true,
                update_in_insert = false,
                severity_sort = true,
            })

            -- LSP handlers with borders
            vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
            vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help,
                { border = "rounded" })

            -- Setup language servers
            local lspconfig = require("lspconfig")

            -- Python
            lspconfig.ruff.setup({
                on_attach = on_attach,
                capabilities = capabilities,
                settings = {
                    python = {
                        analysis = {
                            typeCheckingMode = "basic",
                            autoSearchPaths = true,
                            useLibraryCodeForTypes = true,
                            diagnosticMode = "workspace",
                        },
                    },
                },
            })

            -- Rust
            lspconfig.rust_analyzer.setup({
                on_attach = on_attach,
                capabilities = capabilities,
                settings = {
                    ["rust-analyzer"] = {
                        checkOnSave = {
                            command = "clippy",
                        },
                        cargo = {
                            allFeatures = true,
                        },
                    },
                },
            })

            -- TypeScript/JavaScript
            lspconfig.ts_ls.setup({
                on_attach = on_attach,
                capabilities = capabilities,
                settings = {
                    typescript = {
                        inlayHints = {
                            includeInlayParameterNameHints = "all",
                            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                            includeInlayFunctionParameterTypeHints = true,
                            includeInlayVariableTypeHints = true,
                            includeInlayPropertyDeclarationTypeHints = true,
                            includeInlayFunctionLikeReturnTypeHints = true,
                            includeInlayEnumMemberValueHints = true,
                        },
                    },
                    javascript = {
                        inlayHints = {
                            includeInlayParameterNameHints = "all",
                            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                            includeInlayFunctionParameterTypeHints = true,
                            includeInlayVariableTypeHints = true,
                            includeInlayPropertyDeclarationTypeHints = true,
                            includeInlayFunctionLikeReturnTypeHints = true,
                            includeInlayEnumMemberValueHints = true,
                        },
                    },
                },
            })

            -- Go
            lspconfig.gopls.setup({
                on_attach = on_attach,
                capabilities = capabilities,
                settings = {
                    gopls = {
                        analyses = {
                            unusedparams = true,
                        },
                        staticcheck = true,
                        gofumpt = true,
                    },
                },
            })

            -- Lua
            lspconfig.lua_ls.setup({
                on_attach = on_attach,
                capabilities = capabilities,
                settings = {
                    Lua = {
                        runtime = {
                            version = "LuaJIT",
                        },
                        diagnostics = {
                            globals = { "vim" },
                        },
                        workspace = {
                            library = vim.api.nvim_get_runtime_file("", true),
                            checkThirdParty = false,
                        },
                        telemetry = {
                            enable = false,
                        },
                        completion = {
                            callSnippet = "Replace",
                        },
                    },
                },
            })
        end,
    },
}
