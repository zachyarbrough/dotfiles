local modes

-- Map the modes object with the appropriate colors
local function set_statusline_highlights()
	local ok, palettes = pcall(require, "catppuccin.palettes")
	local cp = ok and palettes.get_palette()
		or {
			blue = "#89b4fa",
			green = "#a6e3a1",
			mauve = "#f5c2e7",
			peach = "#fab387",
			red = "#f38ba8",
			mantle = "#181825",
		}

	modes = {
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
end

set_statusline_highlights()

-- Get the mode and row:column numbers with correct colors
local function get_statusline_mode()
	local code = vim.api.nvim_get_mode().mode:sub(1, 1)
	local m = modes[code] or modes.n

	local mode = string.format("%%#%s#%s%%*", m[2], m[1])
	local row_col = string.format("%%#%s# %%L:%%c %%*", m[2], m[1])

	return mode, row_col
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
			local mode, row_col

			if win == cur_win then
				mode, row_col = get_statusline_mode()
			else
				mode = ""
				row_col = " %L:%c"
			end

			vim.wo[win].statusline = mode
				.. " %f "
				.. get_git_status()
				.. "%m%r"
				.. get_lsp_status()
				.. " %= %y %p%% "
				.. row_col
		end
	end
end

-- Update git visual when gitsigns updates and changes
local statusline_group = vim.api.nvim_create_augroup("statusline-refresh", { clear = true })

-- Reapply mode highlights on colorscheme change, then redraw
vim.api.nvim_create_autocmd("ColorScheme", {
	desc = "Reapply statusline mode highlights on colorscheme change",
	group = statusline_group,
	callback = function()
		set_statusline_highlights()
		update_statusline()
	end,
})

-- Update git visual when git signs updates and changes
vim.api.nvim_create_autocmd("User", {
	desc = "Update statusline  indicator",
	group = statusline_group,
	pattern = { "GitSignsUpdate", "GitSignsChanged" },
	callback = function()
		update_statusline()
	end,
})

-- Update mode visual when changing modes and entering a buffer
vim.api.nvim_create_autocmd({ "ModeChanged", "BufEnter", "WinEnter", "TermClose", "DiagnosticChanged" }, {
	desc = "Update statusline mode indicator",
	group = statusline_group,
	callback = function()
		-- Schedule update due to race-prone errors with the terminal
		vim.schedule(update_statusline)
	end,
})

update_statusline()
