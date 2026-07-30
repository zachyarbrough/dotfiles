--------------------------------------
--- Auto Installation
--------------------------------------
local registry = require("mason-registry")

local tools = {}

local lsps = {
	"lua-language-server",
	"basedpyright",
	"typescript-language-server",
	"json-lsp",
	"html-lsp",
	"css-lsp",
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
	root_markers = { ".git" },
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
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

vim.lsp.enable({ "lua_ls", "ts_ls", "basedpyright", "jsonls", "html", "cssls" })
