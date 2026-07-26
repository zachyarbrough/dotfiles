vim.opt.wrap = false
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true

vim.cmd("filetype plugin indent on")

vim.opt.autoindent = true
vim.opt.smartindent = true

vim.opt.winborder = "rounded"

vim.opt.ignorecase = true -- Case insensitive search
vim.opt.smartcase = true -- Case sensitive if uppercase in search
vim.opt.hlsearch = false -- Don't highlight search results

vim.opt.backup = false -- Don't create backup files
vim.opt.writebackup = false -- Don't create backup before writing
vim.opt.swapfile = false -- Don't create swap files
vim.opt.undofile = true -- Persistent undo

-- Configures the behavior of the insert mode completion menu
vim.opt.completeopt = "menu,menuone,noselect,popup"
vim.o.autocomplete = true
-- Make omnicomplete reference the active LSP server for suggestions
vim.opt.complete:append("o")

-- Netrw Explorer
vim.g.netrw_liststyle = 3

-- Enable virtual text for in-line lsp warnings/errors
vim.diagnostic.config({
	virtual_text = true,
})
