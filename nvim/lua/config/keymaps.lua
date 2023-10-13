-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>n", vim.cmd.UndotreeToggle, { desc = "Toggle Undotree" })

vim.keymap.set("n", "<C-h>", vim.cmd.TmuxNavigateLeft, { desc = "Navigate Left" })
vim.keymap.set("n", "<C-j>", vim.cmd.TmuxNavigateDown, { desc = "Navigate Down" })
vim.keymap.set("n", "<C-k>", vim.cmd.TmuxNavigateUp, { desc = "Navigate Up" })
vim.keymap.set("n", "<C-l>", vim.cmd.TmuxNavigateRight, { desc = "Navigate Right" })

vim.keymap.set({ "n", "i", "v" }, "<A-h>", vim.cmd.TmuxResizeLeft, { desc = "Resize Left" })
vim.keymap.set({ "n", "i", "v" }, "<A-j>", vim.cmd.TmuxResizeDown, { desc = "Resize Down" })
vim.keymap.set({ "n", "i", "v" }, "<A-k>", vim.cmd.TmuxResizeUp, { desc = "Resize Up" })
vim.keymap.set({ "n", "i", "v" }, "<A-l>", vim.cmd.TmuxResizeRight, { desc = "Resize Right" })

vim.keymap.set("n", "<C-A-h>", vim.cmd.DapStepOut, { desc = "Step Out" })
vim.keymap.set("n", "<C-A-j>", vim.cmd.DapStepOver, { desc = "Step Over" })
vim.keymap.set("n", "<C-A-k>", vim.cmd.DapContinue, { desc = "Continue" })
vim.keymap.set("n", "<C-A-l>", vim.cmd.DapStepInto, { desc = "Step Into" })
