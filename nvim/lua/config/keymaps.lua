-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>t", vim.cmd.UndotreeToggle)

vim.keymap.set("n", "<C-h>", vim.cmd.TmuxNavigateLeft)
vim.keymap.set("n", "<C-j>", vim.cmd.TmuxNavigateDown)
vim.keymap.set("n", "<C-k>", vim.cmd.TmuxNavigateUp)
vim.keymap.set("n", "<C-l>", vim.cmd.TmuxNavigateRight)

vim.keymap.set("n", "<A-h>", vim.cmd.TmuxResizeLeft)
vim.keymap.set("n", "<A-j>", vim.cmd.TmuxResizeDown)
vim.keymap.set("n", "<A-k>", vim.cmd.TmuxResizeUp)
vim.keymap.set("n", "<A-l>", vim.cmd.TmuxResizeRight)
