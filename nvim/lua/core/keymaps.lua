-- Moving visual selection
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Keep cursor in the middle when jumping page blocks
vim.keymap.set("n", "<C-d>", "10jzz")
vim.keymap.set("n", "<C-u>", "10kzz")

-- Keep cursor in the middle when searching
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Marks
vim.keymap.set("n", "M", "'", { desc = "Jump to Mark" })

-- Argument list (native non-persistant Harpoon-like integration)
vim.keymap.set("n", "<leader>aa", function()
	vim.cmd("argadd %")
	vim.cmd("argdedup")
end, { desc = "Add file to arglist" })

vim.keymap.set("n", "<leader>ad", function()
	vim.cmd("argdelete %")
end, { desc = "Delete file from arglist" })

-- Set keymaps for argument list <leader>{1-5}
for i = 1, 5 do
	vim.keymap.set("n", "<leader>" .. i, function()
		vim.cmd("silent! " .. i + 1 .. "argument")
	end, { desc = "Open file for arglist " .. (i + 1) })
end

-- LSP keymaps
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "gh", vim.lsp.buf.hover, { desc = "View quick definition" })

-- Open diagnostic float on normal mode <leader>e
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })

--------------------------------------
-- conform.nvim
--------------------------------------
-- Format buffer based on LSP formatter
vim.keymap.set("n", "==", function()
	require("conform").format({
		async = true,
		lsp_format = "fallback", -- Uses LSP formatting *only* if Conform has no formatter configured
	})
end, { desc = "Format buffer with Conform" })

--------------------------------------
-- gitsigns
--------------------------------------
local function gitsigns()
	return require("gitsigns")
end

vim.keymap.set("n", "<leader>ts", function()
	gitsigns().toggle_signs()
end, { desc = "Toggle git signs" })

vim.keymap.set("n", "<leader>tb", function()
	gitsigns().toggle_current_line_blame()
end, { desc = "Toggle git blame" })

vim.keymap.set("n", "<leader>gp", function()
	gitsigns().preview_hunk()
end, { desc = "Preview hunk changes" })

vim.keymap.set("n", "<leader>ga", function()
	gitsigns().stage_hunk()
end, { desc = "Stage hunk changes" })

vim.keymap.set("n", "<leader>gA", function()
	gitsigns().stage_buffer()
end, { desc = "Stage buffer changes" })

-- Navigat git hunks without overriding :diff view keymaps
vim.keymap.set("n", "]c", function()
	if vim.wo.diff then
		vim.cmd.normal({ "]c", bang = true })
	else
		gitsigns().nav_hunk("next")
	end
end, { desc = "Go to next hunk" })

vim.keymap.set("n", "[c", function()
	if vim.wo.diff then
		vim.cmd.normal({ "[c", bang = true })
	else
		gitsigns().nav_hunk("prev")
	end
end, { desc = "Go to previous hunk" })

--------------------------------------
--- oil.nvim
--------------------------------------
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

--------------------------------------
-- anchor
--------------------------------------
local function anchor()
	return require("anchor")
end

vim.keymap.set("n", "<leader>al", function()
	anchor().toggle_list()
end, { desc = "Open anchor list" })

vim.keymap.set("n", "<leader>gw", function()
	anchor().toggle_worktrees()
end, { desc = "Open git worktrees list" })

vim.keymap.set("n", "<leader>f0", function()
	anchor().return_to_cwd()
end, { desc = "Return back to cwd" })

-- Set keymaps for <leader>f{1-5}
for i = 1, 5 do
	vim.keymap.set("n", "<leader>f" .. i, function()
		anchor().open(i)
	end, { desc = "Open fuzzy finder for anchor " .. i })
end

-- Set keymaps for <leader>g{1-5}
for i = 1, 5 do
	vim.keymap.set("n", "<leader>ag" .. i, function()
		anchor().grep(i)
	end, { desc = "Open fuzzy finder live grep for anchor " .. i })
end

--------------------------------------
-- fzf-lua
--------------------------------------
local function fzf()
	return require("fzf-lua")
end

local expanded_opts = {
	winopts = {
		height = 0.85,
		preview = {
			layout = "vertical",
			vertical = "up:70%",
		},
	},
}

-- LSP
vim.keymap.set("n", "gr", function()
	fzf().lsp_references(vim.tbl_extend("force", expanded_opts, {
		ignore_current_line = true,
		previewer = "builtin",
	}))
end, { desc = "Browse LSP references" })

-- files
vim.keymap.set("n", "<leader>ff", function()
	fzf().files()
end, { desc = "Find files in current project" })

vim.keymap.set("n", "<leader>fo", function()
	fzf().oldfiles()
end, { desc = "Browse recently opened files" })

vim.keymap.set("n", "<leader>f.", function()
	fzf().files({ cwd = "~/.dotfiles" })
end, { desc = "Find files in dotfiles directory" })

-- grep
vim.keymap.set("n", "<leader>fg", function()
	fzf().live_grep(vim.tbl_extend("force", expanded_opts, {
		previewer = "builtin",
	}))
end, { desc = "Grep for text in current project" })

vim.keymap.set("n", "<leader>fb", function()
	fzf().lgrep_curbuf(vim.tbl_extend("force", expanded_opts, {
		previewer = "builtin",
	}))
end, { desc = "Grep for text in current project" })

-- git
vim.keymap.set("n", "<leader>gs", function()
	fzf().git_status(vim.tbl_extend("force", expanded_opts, {
		previewer = "git_diff",
	}))
end, { desc = "View git status" })

vim.keymap.set("n", "<leader>gb", function()
	fzf().git_branches(expanded_opts)
end, { desc = "View git branches" })

vim.keymap.set("n", "<leader>gc", function()
	fzf().git_commits(expanded_opts)
end, { desc = "View git commits" })

-- misc
vim.keymap.set("n", "<leader>fa", function()
	fzf().args()
end, { desc = "Browse argslist" })

vim.keymap.set("n", "<leader>fj", function()
	fzf().jumps()
end, { desc = "Browse jumpslist" })

vim.keymap.set("n", "<leader>fm", function()
	fzf().marks({
		marks = "%a",
		sort = true,
	})
end, { desc = "Browse custom marks" })

vim.keymap.set("n", "<leader>fh", function()
	fzf().help_tags()
end, { desc = "Browse neovim's documentation" })
