-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.snacks_animate = false

-- indentation --
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true

vim.opt.tabstop = 2

vim.g.ai_cmp = false

-- Don't auto-cd into project subdirectories so grep/find searches the full project
vim.g.root_spec = { "cwd" }

-- vim.keymap.set({ "n", "x", "o" }, "<C-f>", function()
--   require("flash").jump()
-- end, { desc = "Flash Jump" })
