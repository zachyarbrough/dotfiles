local ok, palettes = pcall(require, "catppuccin.palettes")
local cp = ok and palettes.get_palette()
	or { blue = "#89b4fa", green = "#a6e3a1", mauve = "#f5c2e7", peach = "#fab387", red = "#f38ba8", mantle = "#181825" }

local modes = {
	n = { " NORMAL ", "StatusNormal", cp.blue },
	r = { " NORMAL ", "StatusNormal", cp.blue },
	rm = { " NORMAL ", "StatusNormal", cp.blue },
	no = { " NORMAL ", "StatusNormal", cp.blue },

	i = { " INSERT ", "StatusInsert", cp.green },
	t = { " TERMINAL ", "StatusInsert", cp.green },

	v = { " VISUAL ", "StatusVisual", cp.mauve },
	V = { " V-LINE ", "StatusVisual", cp.mauve },
	["\22"] = { " V-BLOCK ", "StatusVisual", cp.mauve },

	c = { " COMMAND ", "StatusCommand", cp.peach },
	R = { " REPLACE ", "StatusReplace", cp.red },
}

for _, m in pairs(modes) do
	vim.api.nvim_set_hl(0, m[2], { fg = cp.mantle, bg = m[3], bold = true })
end

-- Get the mode and line_number with correct colors
local function get_statusline_mode()
	local code = vim.api.nvim_get_mode().mode:sub(1, 1)
	local m = modes[code] or modes.n

	local mode = string.format("%%#%s#%s%%*", m[2], m[1])
	local line_num = string.format("%%#%s# %%L:%%c %%*", m[2], m[1])

	return mode, line_num
end

-- Get the git branch and added, modified, deleted lines
local function get_git_status()
	local gitsigns = vim.b.gitsigns_status_dict
	local branch = vim.b.gitsigns_head
	if branch == nil then
		branch = vim.fn.systemlist("git branch --show-current 2>/dev/null")[1]
	end

	if not gitsigns then
		return "[" .. branch .. "]"
	end

	local status = "[" .. branch
	if (gitsigns.added or 0) > 0 then
		status = status .. " %#GitSignsAdd#+" .. gitsigns.added
	end
	if (gitsigns.changed or 0) > 0 then
		status = status .. " %#GitSignsChange#~" .. gitsigns.changed
	end
	if (gitsigns.removed or 0) > 0 then
		status = status .. " %#GitSignsDelete#-" .. gitsigns.removed
	end
	return status .. "%#StatusLine#]"
end

local function get_lsp_status()
	-- Fetch native diagnostic counts for the current buffer
	local counts = vim.diagnostic.count(0)
	if vim.tbl_isempty(counts) then
		return ""
	end

	local err = counts[vim.diagnostic.severity.ERROR] or 0
	local warn = counts[vim.diagnostic.severity.WARN] or 0
	if err == 0 and warn == 0 then
		return ""
	end

	local status = " "
	if err > 0 then
		status = status .. "%#DiagnosticError# " .. err .. " "
	end
	if warn > 0 then
		status = status .. "%#DiagnosticWarn# " .. warn .. " "
	end
	return status .. "%#StatusLine#"
end

local function update_statusline()
	local cur_win = vim.api.nvim_get_current_win()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_config(win).relative == "" then -- skip floats
			local mode, line_num

			if win == cur_win then
				mode, line_num = get_statusline_mode()
			else
				mode = ""
				line_num = " %L:%c"
			end

			vim.wo[win].statusline = mode
				.. " %f %m %r"
				.. get_git_status()
				.. get_lsp_status()
				.. " %= %y %p%% "
				.. line_num
		end
	end
end

-- Update git visual when gitsigns updates and changes
local statusline_group = vim.api.nvim_create_augroup("statusline-refresh", { clear = true })

-- Update git visual when git signs updates and changes
vim.api.nvim_create_autocmd("User", {
	desc = "Update statusline  indicator",
	group = statusline_group,
	pattern = { "GitSignsUpdate", "GitSignsChanged" },
	callback = update_statusline,
})

-- Update diagnostic visual when diagnostics changes
vim.api.nvim_create_autocmd("DiagnosticChanged", {
	desc = "Update statusline diagnostic indicator",
	group = statusline_group,
	callback = update_statusline,
})

-- Update mode visual when changing modes and entering a buffer
vim.api.nvim_create_autocmd({ "ModeChanged", "BufEnter", "WinEnter" }, {
	desc = "Update statusline mode indicator",
	group = statusline_group,
	callback = update_statusline,
})

update_statusline()
