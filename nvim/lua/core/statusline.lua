local ok, palettes = pcall(require, "catppuccin.palettes")
local cp = ok and palettes.get_palette()
	or { blue = "#89b4fa", green = "#a6e3a1", mauve = "#f5c2e7", peach = "#fab387", red = "#f38ba8", mantle = "#181825" }

local modes = {
	n = { " NORMAL ", "StatusNormal", cp.blue },
	i = { " INSERT ", "StatusInsert", cp.green },
	v = { " VISUAL ", "StatusVisual", cp.mauve },
	V = { " V-LINE ", "StatusVisual", cp.mauve },
	["\22"] = { " V-BLOCK ", "StatusVisual", cp.mauve },
	c = { " COMMAND ", "StatusCommand", cp.peach },
	R = { " REPLACE ", "StatusReplace", cp.red },
}

for _, m in pairs(modes) do
	vim.api.nvim_set_hl(0, m[2], { fg = cp.mantle, bg = m[3], bold = true })
end

local function get_statusline_mode()
	local code = vim.api.nvim_get_mode().mode:sub(1, 1)
	local m = modes[code] or { " NORMAL ", "DiagnosticOk" }

	local prefix_str = string.format("%%#%s#%s%%*", m[2], m[1])
	local suffix_str = string.format("%%#%s# %%L:%%c%%*", m[2], m[1])

	return prefix_str, suffix_str
end

local statusline = " %f %m %r %= %y %p%% "

local function update_statusline()
	local cur_win = vim.api.nvim_get_current_win()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_config(win).relative == "" then -- skip floats
			local prefix, suffix

			if win == cur_win then
				prefix, suffix = get_statusline_mode()
			else
				prefix = ""
				suffix = " %L:%c"
			end

			vim.wo[win].statusline = prefix .. statusline .. suffix
		end
	end
end

-- Update mode visual when changing modes and entering a buffer
vim.api.nvim_create_autocmd({ "ModeChanged", "BufEnter", "WinEnter" }, {
	desc = "Update statusline mode indicator",
	group = vim.api.nvim_create_augroup("statusline-mode", { clear = true }),
	callback = update_statusline,
})

update_statusline()
