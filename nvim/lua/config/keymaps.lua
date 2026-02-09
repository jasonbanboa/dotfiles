-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- Window navigation with Ctrl + hjkl
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

vim.keymap.set("n", "<leader>s", "<C-w>s", {
  desc = "Open bottom horizontal split",
})
vim.keymap.set("n", "<leader>v", "<C-w>v", {
  desc = "Open right vertical split",
})
