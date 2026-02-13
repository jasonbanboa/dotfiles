-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Project-specific indentation settings
-- Detects sellmate projects and sets tabs (width 1) to match .prettierrc
local function set_project_indent()
	local cwd = vim.fn.getcwd()
	-- Check if we're in a sellmate project
	if cwd:match("sellmate") then
		vim.opt_local.expandtab = false -- use tabs
		vim.opt_local.tabstop = 1
		vim.opt_local.shiftwidth = 1
		vim.opt_local.softtabstop = 1
	end
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
	pattern = { "*.vue", "*.js", "*.ts", "*.jsx", "*.tsx", "*.json", "*.html", "*.css", "*.scss" },
	callback = set_project_indent,
})

-- Also set on DirChanged in case user changes directory
vim.api.nvim_create_autocmd("DirChanged", {
	callback = function()
		-- Re-apply to current buffer if it matches
		local ft = vim.bo.filetype
		if vim.tbl_contains({ "vue", "javascript", "typescript", "javascriptreact", "typescriptreact", "json", "html", "css", "scss" }, ft) then
			set_project_indent()
		end
	end,
})
