-- Highlight yanked text for better visual feedback
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Toggle absolute line numbers in Insert/Command mode
local number_toggle = vim.api.nvim_create_augroup("number-toggle", { clear = true })

vim.api.nvim_create_autocmd({ "CmdlineEnter", "InsertEnter" }, {
	desc = "Toggl absolute line numbers",
	group = number_toggle,
	callback = function()
		if vim.wo.number then
			vim.wo.relativenumber = false
			vim.cmd.redraw()
		end
	end,
})

-- Toggle relative line numbers
vim.api.nvim_create_autocmd({ "CmdlineLeave", "InsertLeave" }, {
	desc = "Toggle relative line numbers",
	group = number_toggle,
	callback = function()
		if vim.wo.number then
			vim.wo.relativenumber = true
			vim.cmd.redraw()
		end
	end,
})

-- Enable auto completion when typing commands in the command line
vim.api.nvim_create_autocmd("CmdlineChanged", {
	desc = "Enable auto complete when typing commands",
	group = vim.api.nvim_create_augroup("cmdline-auto-complete", { clear = true }),
	pattern = ":",
	callback = function()
		if vim.fn.wildmenumode() == 0 then
			vim.fn.wildtrigger()
		end
	end,
})

--------------------------------------
--- Tree-Sitter configuration
--------------------------------------
vim.api.nvim_create_autocmd("FileType", {
	desc = "Don't open treesitter if file is larger than 1MB",
	group = vim.api.nvim_create_augroup("native-treesitter-all", { clear = true }),
	callback = function(args)
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
local markdown_strike_tasks = vim.api.nvim_create_augroup("markdown-strike-tasks", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
	desc = "Strikethrough and grey out - [-] tasks in markdown",
	group = markdown_strike_tasks,
	pattern = { "*.md" },
	callback = function()
		local comment = vim.api.nvim_get_hl(0, { name = "Comment" })
		vim.api.nvim_set_hl(0, "markdownStrike", {
			fg = comment.fg,
			strikethrough = true,
		})

		if vim.w.markdown_strike_match then
			pcall(vim.fn.matchdelete, vim.w.markdown_strike_match)
		end
		vim.w.markdown_strike_match = vim.fn.matchadd("markdownStrike", [[- \[-\].*]])
	end,
})

vim.api.nvim_create_autocmd({ "BufLeave", "BufWinLeave" }, {
	desc = "Clear strikethrough match when leaving markdown buffer",
	group = markdown_strike_tasks,
	pattern = { "*.md" },
	callback = function()
		if vim.w.markdown_strike_match then
			pcall(vim.fn.matchdelete, vim.w.markdown_strike_match)
			vim.w.markdown_strike_match = nil
		end
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
	if vim.env.TMUX_POPUP then
		return
	end
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
		if vim.env.TMUX_POPUP then
			return
		end
		vim.fn.system(
			"tmux set -g status-style 'bg=default,fg=white'; "
				.. "tmux set -g message-style 'bg=default,fg=white'; "
				.. "tmux set -g message-command-style 'bg=default,fg=white'"
		)
	end,
})
