-- Highlight yanked text for better visual feedback
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Toggle realtive and absolute line numbers
local number_toggle = vim.api.nvim_create_augroup("number-toggle", { clear = true })

vim.api.nvim_create_autocmd({ "CmdlineEnter", "InsertEnter" }, {
	desc = "Toggl absolute line numbers",
	group = number_toggle,
	pattern = "*",
	callback = function()
		if vim.wo.number then
			vim.wo.relativenumber = false
			vim.cmd.redraw()
		end
	end,
})

vim.api.nvim_create_autocmd({ "CmdlineLeave", "InsertLeave" }, {
	desc = "Toggl relative line numbers",
	group = number_toggle,
	pattern = "*",
	callback = function()
		if vim.wo.number then
			vim.wo.relativenumber = true
			vim.cmd.redraw()
		end
	end,
})

--------------------------------------
--- Tree-Sitter configuration
--------------------------------------
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("native-treesitter-all", { clear = true }),
	pattern = "*", -- Matches every single file type
	callback = function(args)
		-- Don't open tree-sitter if file is larger than 1MB
		local max_filesize = 1024 * 1024 -- 1 MB
		local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))

		if ok and stats and stats.size > max_filesize then
			return
		end

		-- Safely run Tree-sitter for normal-sized files
		pcall(vim.treesitter.start, args.buf)
	end,
})

--------------------------------------
--- Markdown formatting
--------------------------------------
-- Strike through and grey out - [-] tasks in markdown
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
	desc = "Strikethrough and grey out - [-] tasks in markdown",
	group = vim.api.nvim_create_augroup("markdown-strike-tasks", { clear = true }),
	pattern = { "*.md" },
	callback = function()
		vim.fn.matchadd("markdownStrike", "- \\[-\\].*")
		local comment = vim.api.nvim_get_hl(0, { name = "Comment" })
		vim.api.nvim_set_hl(0, "markdownStrike", {
			fg = comment.fg,
			strikethrough = true,
		})
	end,
})

-- Toggle concealment for symbols like bold (**), and inline code (```)
local conceal_toggle = vim.api.nvim_create_augroup("markdown-conceal", { clear = true })

vim.api.nvim_create_autocmd("InsertEnter", {
	desc = "Show raw markdown in insert mode",
	group = conceal_toggle,
	pattern = { "*.md" },
	callback = function()
		vim.opt_local.conceallevel = 0
	end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "InsertLeave" }, {
	desc = "Hide markdown symbols",
	group = conceal_toggle,
	pattern = { "*.md" },
	callback = function()
		vim.opt_local.conceallevel = 2
	end,
})

---------------------------------------
--- TMUX
---------------------------------------
local function sync_tmux_bg()
	local bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
	if bg then
		local hex = string.format("#%06x", bg)
		vim.fn.system(
			"tmux set -g status-style 'bg="
				.. hex
				.. ",fg=white'; "
				.. "tmux set -g message-style 'bg="
				.. hex
				.. ",fg=white'; "
				.. "tmux set -g message-command-style 'bg="
				.. hex
				.. ",fg=white'"
		)
	end
end

local tmux_group = vim.api.nvim_create_augroup("tmux-background", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
	desc = "Sync tmux status background with nvim or terminal",
	group = tmux_group,
	callback = sync_tmux_bg,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
	desc = "Set tmux status background to terminal",
	group = tmux_group,
	callback = function()
		vim.fn.system(
			"tmux set -g status-style 'bg=default,fg=white'; "
				.. "tmux set -g message-style 'bg=default,fg=white'; "
				.. "tmux set -g message-command-style 'bg=default,fg=white'"
		)
	end,
})
