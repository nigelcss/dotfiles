-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>o", vim.cmd.AerialToggle, { desc = "Toggle Aerial" })
vim.keymap.set("n", "<leader>n", vim.cmd.UndotreeToggle, { desc = "Toggle Undotree" })
vim.keymap.set("n", "<leader>C", "<cmd>ChatGPT<cr>", { desc = "ChatGPT" })

vim.keymap.set("n", "<C-h>", ":diffget local<CR>", { desc = "Get LOCAL" })
vim.keymap.set("n", "<C-j>", "]c", { desc = "Prev Change" })
vim.keymap.set("n", "<C-k>", "[c", { desc = "Next Change" })
vim.keymap.set("n", "<C-l>", ":diffget remote<CR>", { desc = "Get REMOTE" })

vim.keymap.set({ "n", "i", "v" }, "<A-h>", vim.cmd.TmuxResizeLeft, { desc = "Resize Left" })
vim.keymap.set({ "n", "i", "v" }, "<A-j>", vim.cmd.TmuxResizeDown, { desc = "Resize Down" })
vim.keymap.set({ "n", "i", "v" }, "<A-k>", vim.cmd.TmuxResizeUp, { desc = "Resize Up" })
vim.keymap.set({ "n", "i", "v" }, "<A-l>", vim.cmd.TmuxResizeRight, { desc = "Resize Right" })
