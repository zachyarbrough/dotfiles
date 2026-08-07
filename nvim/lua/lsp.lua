--------------------------------------
--- Auto Installation
--------------------------------------
local registry = require("mason-registry")

local tools = {}

local lsps = {
	"lua-language-server",
	"basedpyright",
	"typescript-language-server",
	"eslint-lsp",
	"html-lsp",
	"css-lsp",
	"tailwindcss-language-server",
	"json-lsp",
}
vim.list_extend(tools, lsps)

local formatters = {
	"stylua",
	"prettier",
	"prettierd",
	"ruff",
}
vim.list_extend(tools, formatters)

-- Auto Install Mason packages
for _, tool in ipairs(tools) do
	local p = registry.get_package(tool)
	if not p:is_installed() then
		p:install()
	end
end

--------------------------------------
--- Configuration
--------------------------------------
vim.lsp.config("lua_ls", {
	root_markers = { ".git", ".luarc.json", ".luarc.jsonc" },
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			workspace = {
				library = {
					vim.api.nvim_get_runtime_file("", true),
					"${3rd}/love2d/library",
				},
				checkThirdParty = false,
			},
			diagnostics = {
				globals = { "vim" },
			},
			telemetry = { enable = false },
		},
	},
})

vim.lsp.config("basedpyright", {
	settings = {
		basedpyright = {
			typeCheckingMode = "standard",
		},
	},
})

vim.lsp.enable({
	"lua_ls",
	"basedpyright",
	"ts_ls",
	"eslint",
	"html",
	"cssls",
	"tailwindcss",
	"jsonls",
})
