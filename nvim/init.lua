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

-- Vim settings
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.softtabstop = 4

vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.relativenumber = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

-- Disable netrw because we are using nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Lualine already shows mode
vim.opt.showmode = false

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Remaps

-- Move highlighted lines up and down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
-- Half page nav
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
-- Keep search terms in middle
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Quickfix
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- Delete pasted over text
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Copy to clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Delete without adding to clipboard
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d')

-- Search word
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Make file executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		-- add your plugins here
		{
			"christoomey/vim-tmux-navigator",
			cmd = {
				"TmuxNavigateLeft",
				"TmuxNavigateDown",
				"TmuxNavigateUp",
				"TmuxNavigateRight",
				"TmuxNavigatePrevious",
				"TmuxNavigatorProcessList",
			},
			keys = {
				{ "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
				{ "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
				{ "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
				{ "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
				{ "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
			},
		},
		{ "nvim-tree/nvim-web-devicons", opts = {} },
		{
			"Bekaboo/dropbar.nvim",
			-- optional, but required for fuzzy finder support
			dependencies = {
				"nvim-tree/nvim-web-devicons",
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
			},
			config = function()
				require("dropbar").setup({
					icons = {
						enable = true,
					},
				})
				local dropbar_api = require("dropbar.api")
				vim.keymap.set("n", "<Leader>;", dropbar_api.pick, { desc = "Pick symbols in winbar" })
				vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
				vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Select next context" })
			end,
		},
		{
			"stevearc/conform.nvim",
			event = { "BufWritePre" },
			cmd = { "ConformInfo" },
			keys = {
				{
					-- Customize or remove this keymap to your liking
					"<leader><leader>",
					function()
						require("conform").format({ async = true })
					end,
					mode = "",
					desc = "Format buffer",
				},
			},
			-- This will provide type hinting with LuaLS
			---@module "conform"
			---@type conform.setupOpts
			opts = {
				-- Define your formatters
				formatters_by_ft = {
					lua = { "stylua" },
					python = { "isort", "black" },
					javascript = { "prettierd", "prettier", stop_after_first = true },
				},
				-- Set default options
				default_format_opts = {
					lsp_format = "fallback",
				},
				-- Set up format-on-save
				format_on_save = { timeout_ms = 500 },
				-- Customize formatters
				formatters = {
					shfmt = {
						append_args = { "-i", "2" },
					},
				},
			},
			init = function()
				-- If you want the formatexpr, here is the place to set it
				vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
			end,
		},
		{
			"LunarVim/bigfile.nvim",
		},
		{
			"rachartier/tiny-inline-diagnostic.nvim",
			event = "VeryLazy",
			priority = 1000,
			config = function()
				require("tiny-inline-diagnostic").setup({ preset = "simple" })
				vim.diagnostic.config({ virtual_text = false }) -- Disable Neovim's default virtual text diagnostics
			end,
		},
		{
			"folke/trouble.nvim",
			opts = {}, -- for default options, refer to the configuration section for custom setup.
			cmd = "Trouble",
			keys = {
				{
					"<leader>xx",
					"<cmd>Trouble diagnostics toggle<cr>",
					desc = "Diagnostics (Trouble)",
				},
				{
					"<leader>xX",
					"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
					desc = "Buffer Diagnostics (Trouble)",
				},
				{
					"<leader>cs",
					"<cmd>Trouble symbols toggle focus=false<cr>",
					desc = "Symbols (Trouble)",
				},
				{
					"<leader>cl",
					"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
					desc = "LSP Definitions / references / ... (Trouble)",
				},
				{
					"<leader>xL",
					"<cmd>Trouble loclist toggle<cr>",
					desc = "Location List (Trouble)",
				},
				{
					"<leader>xQ",
					"<cmd>Trouble qflist toggle<cr>",
					desc = "Quickfix List (Trouble)",
				},
			},
		},
		{
			"lukas-reineke/indent-blankline.nvim",
			main = "ibl",
			---@module "ibl"
			---@type ibl.config
			config = function()
				require("ibl").setup({
					indent = { char = "▏" },
					whitespace = {
						remove_blankline_trail = false, -- Ensures guides show on blank lines
					},
					scope = { enabled = false },
				})
			end,
		},
		{
			"nvim-tree/nvim-tree.lua",
			opts = {},
		},
		{
			"tpope/vim-fugitive",
		},
		{
			"mbbill/undotree",
			config = function()
				-- Set a keymap to toggle the Undotree window
				vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Toggle Undotree" })
			end,
		},
		{
			"saghen/blink.cmp",
			dependencies = {
				"saghen/blink.lib",
				-- optional: provides snippets for the snippet source
				"rafamadriz/friendly-snippets",
			},
			-- build = function()
			-- build the fuzzy matcher, wait up to 60 seconds
			-- you can use `gb` in `:Lazy` to rebuild the plugin as needed
			--  require('blink.cmp').build():wait(60000)
			-- end,

			---@module 'blink.cmp'
			---@type blink.cmp.Config
			opts = {
				-- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
				-- 'super-tab' for mappings similar to vscode (tab to accept)
				-- 'enter' for enter to accept
				-- 'none' for no mappings
				--
				-- All presets have the following mappings:
				-- C-space: Open menu or open docs if already open
				-- C-n/C-p or Up/Down: Select next/previous item
				-- C-e: Hide menu
				-- C-k: Toggle signature help (if signature.enabled = true)
				--
				-- See :h blink-cmp-config-keymap for defining your own keymap
				keymap = { preset = "default" },

				-- (Default) Only show the documentation popup when manually triggered
				completion = { documentation = { auto_show = false } },

				-- (Default) list of enabled providers defined so that you can extend it
				-- elsewhere in your config, without redefining it, due to `opts_extend`
				sources = { default = { "lsp", "path", "snippets", "buffer" } },

				-- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
				-- You may use a lua implementation instead by using `implementation = "lua"`
				-- See the fuzzy documentation for more information
				fuzzy = { implementation = "lua" },
			},
		},
		{
			"mason-org/mason-lspconfig.nvim",
			opts = {
				automatic_enable = true,
			},
			dependencies = {
				{ "mason-org/mason.nvim", opts = {} },
				"neovim/nvim-lspconfig",
			},
		},
		{
			"mason-org/mason.nvim",
			opts = {},
		},
		{
			"nvim-treesitter/nvim-treesitter",
			lazy = false,
			build = ":TSUpdate",
			opts = {
				-- LazyVim config for treesitter
				indent = { enable = true }, ---@type lazyvim.TSFeat
				highlight = { enable = true }, ---@type lazyvim.TSFeat
				folds = { enable = true }, ---@type lazyvim.TSFeat
				ensure_installed = {
					"bash",
					"c",
					"diff",
					"html",
					"javascript",
					"jsdoc",
					"json",
					"lua",
					"luadoc",
					"luap",
					"markdown",
					"markdown_inline",
					"printf",
					"python",
					"query",
					"regex",
					"toml",
					"tsx",
					"typescript",
					"vim",
					"vimdoc",
					"xml",
					"yaml",
				},
			},
		},
		{
			"nvim-telescope/telescope.nvim",
			version = "*",
			dependencies = {
				"nvim-lua/plenary.nvim",
				-- optional but recommended
				{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			},
		},
		{
			"nvim-lualine/lualine.nvim",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			opts = { options = { theme = "moonfly", section_separators = "", component_separators = "" } },
		},
		{
			"bluz71/vim-moonfly-colors",
			name = "moonfly",
			lazy = false,
			priority = 1000,
		},
	},
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "moonfly" } },
	-- automatically check for plugin updates
	checker = { enabled = true },
})

-- change some theme colors
require("moonfly").custom_colors({
	grey15 = "#080808",
	grey13 = "#080808",
})

-- lualine
local custom = require("lualine.themes.moonfly")

-- Change the background of lualine_c section for normal mode
custom.normal.c.bg = "#080808"

require("lualine").setup({
	options = { theme = custom },
})

-- Set colorscheme
vim.cmd("colorscheme moonfly")

-- Telescope bindings
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>fg", builtin.git_files, { desc = "Telescope find git files" })
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fs", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
vim.keymap.set("n", "gd", builtin.lsp_definitions, { desc = "Go to definition" })
vim.keymap.set("n", "gi", builtin.lsp_implementations, { desc = "Go to implementation" })

-- vim-tree bindings
local treeapi = require("nvim-tree.api")
vim.keymap.set("n", "<leader>e", treeapi.tree.toggle, { desc = "Toggle nvim-tree" })

-- Python shenanigans
local python_path = vim.fn.system("which python"):gsub("\n", "")
if vim.v.shell_error == 0 then
	vim.g.python3_host_prog = python_path
end
