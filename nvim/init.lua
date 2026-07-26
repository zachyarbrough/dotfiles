vim.g.mapleader = " "

require("core.options")
require("core.keymaps")
require("core.autocmds")

-- plugins
vim.pack.add({
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin", lazy = false, priority = 1000 },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", event = { "BufReadPre", "BufNewFile" } },
	{ src = "https://github.com/stevearc/conform.nvim", event = { "BufReadPre", "BufNewFile" } },
	{ src = "https://github.com/ibhagwan/fzf-lua" },
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/chentoast/marks.nvim" },
	{ src = "https://github.com/zachyarbrough/anchor.nvim" },
})

vim.cmd.colorscheme("catppuccin-macchiato")

require("mason").setup({})

require("lsp")

require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
})

require("fzf-lua").setup({
	defaults = {
		previewer = false,
		formatter = "path.dirname_first",
	},
	winopts = {
		height = 0.45,
		width = 0.80,
		row = 0.50,
		col = 0.50,
		preview = {
			layout = "vertical",
			vertical = "up:70%",
		},
	},

	files = {
		fzf_opts = {
			["--exact"] = "",
			["--no-sort"] = "",
		},
	},
	fzf_colors = {
		["pointer"] = "-1",
	},
})

local signs = {
	add = { text = "+" },
	change = { text = "~" },
	changedelete = { text = "±" },
	untracked = { text = "?" },
}

require("gitsigns").setup({
	current_line_blame = true,

	signs = signs,
	signs_staged = signs,
})

require("oil").setup({
	default_file_explorer = true,
	delete_to_trash = true,
	skip_confirm_for_simple_edits = true,
	view_options = {
		natural_order = true,
	},
})

require("marks").setup({})
-- Schedule wrapper is so the color changes occur after color scheme has loaded
vim.schedule(function()
	vim.api.nvim_set_hl(0, "MarkSignNumHL", { bg = "NONE", ctermbg = "NONE" })
	vim.api.nvim_set_hl(0, "MarkSignHL", { link = "CursorLineNr" })
end)

require("anchor").setup({
	picker_opts = {
		grep = {
			winopts = {
				height = 0.85,
				preview = {
					lagyout = "vertical",
					vertical = "up:70%",
				},
			},
			previewer = "builtin",
		},
	},
	extended_excluded_dirs = { "archived" },
})

-- experimental Neovim 0.12 feature
require("vim._core.ui2").enable({})
