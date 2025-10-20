-- init.lua

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
-- Disable netrw at start
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1000
-- Global options
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
vim.diagnostic.config({
    virtual_text = true, -- shows inline messages
    signs = true,        -- shows gutter icons
    underline = true,    -- shows squiggly underlines
    update_in_insert = false,
})
-- use spaces instead of tabs
vim.o.expandtab = true

-- number of spaces per indentation level
vim.o.shiftwidth = 4

-- number of spaces for a tab character
vim.o.tabstop = 2

-- when using = for indentation, use 'shiftwidth'
vim.o.smartindent = true
vim.o.autoindent = true

vim.o.showtabline = 2

-- Map Esc in terminal to exit to Normal mode
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]])

-- Lazy.nvim setup
require("lazy").setup({
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        config = true
        -- use opts = {} for passing setup options
        -- this is equivalent to setup({}) function
    },

    {
        'nvim-telescope/telescope.nvim', tag = '0.1.8',

        dependencies = { 'nvim-lua/plenary.nvim' }
    },

    -- Colorscheme
    {
        "ellisonleao/gruvbox.nvim",
        priority = 1000,
        config = function()
            vim.o.background = "dark"
            vim.cmd([[colorscheme gruvbox]])
        end,
    },

    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",
        lazy = false,
        build = ":TSUpdate",
    },

    -- Nvim-tree
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = "nvim-tree/nvim-web-devicons",
        config = function()
            require("nvim-tree").setup({
                sort = { sorter = "case_sensitive" },
                view = { width = 30 },
                renderer = { group_empty = true },
                filters = { dotfiles = true },
            })
        end,
    },

    -- LSP and Mason
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "nvim-lua/plenary.nvim",
        },
        config = function()
            local lspconfig = require("lspconfig")
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- Mason auto-install
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls", "pyright", "ts_ls" },
            })

            -- Lua LSP
            lspconfig.lua_ls.setup({
                capabilities = capabilities,
                settings = { Lua = { diagnostics = { globals = { "vim" } } } }
            })

            -- Python LSP
            lspconfig.pyright.setup({ capabilities = capabilities })

            -- TypeScript/JS LSP
            lspconfig.ts_ls.setup({ capabilities = capabilities })

            -- C/C++ LSP with clangd_extensions


            lspconfig.clangd.setup({
                cmd = { "/usr/bin/clangd" },   -- system clangd
                capabilities = capabilities,
                root_dir = lspconfig.util.root_pattern("compile_commands.json", ".git"),
            })

            -- Optional keymap for clangd
            vim.api.nvim_set_keymap(
                "n",
                "<leader>ch",
                "<cmd>ClangdSwitchSourceHeader<CR>",
                { noremap = true, silent = true }
            )
        end,
    },

    -- Autocompletion
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "buffer" },
                    { name = "path" },
                }),
            })
        end,
    },
})

