-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local Util = require("lazyvim.util")

vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "{", "{zz")
vim.keymap.set("n", "}", "}zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set(
  "v",
  "<leader>sv",
  "\"zy<cmd>exec 'Telescope grep_string default_text=' . escape(@z, ' ')<cr>",
  { desc = "Visual Selection" }
)

vim.keymap.set("n", "<leader>gf", function()
  Util.terminal(
    { "lazygit", "-f", vim.api.nvim_buf_get_name(0) },
    { cwd = Util.root(), esc_esc = false, ctrl_hjkl = false }
  )
end, { desc = "Lazygit File" })

vim.keymap.set("n", "<leader>os", vim.cmd.ObsidianSearch, { desc = "Search for Note" })
vim.keymap.set("n", "<leader>oq", vim.cmd.ObsidianQuickSwitch, { desc = "Quick Switch" })
vim.keymap.set("n", "<leader>on", vim.cmd.ObsidianNew, { desc = "New Note" })
vim.keymap.set("n", "<leader>of", vim.cmd.ObsidianFollowLink, { desc = "Follow Link" })
vim.keymap.set("n", "<leader>ob", vim.cmd.ObsidianBacklinks, { desc = "Show Backlinks" })
vim.keymap.set("n", "<leader>ot", vim.cmd.ObsidianTemplate, { desc = "Insert Template" })
vim.keymap.set("v", "<leader>ol", vim.cmd.ObsidianLink, { desc = "Link" })
vim.keymap.set("v", "<leader>ow", vim.cmd.ObsidianLinkNew, { desc = "Link New Note" })
vim.keymap.set("n", "<leader>op", vim.cmd.ObsidianPasteImg, { desc = "Paste Image" })
vim.keymap.set("n", "<leader>oo", vim.cmd.ObsidianOpen, { desc = "Open in App" })

vim.keymap.set("n", "<leader>z", vim.cmd.ZenMode, { desc = "Toggle Zen Mode" })

vim.keymap.set("n", "<leader>O", vim.cmd.AerialToggle, { desc = "Toggle Aerial" })

vim.keymap.set("n", "<leader>n", vim.cmd.UndotreeToggle, { desc = "Toggle Undotree" })

vim.keymap.set("n", "<leader>D", vim.cmd.DBUIToggle, { desc = "Toggle Debug UI" })

vim.keymap.set("n", "<leader>C", "<cmd>ChatGPT<cr>", { desc = "ChatGPT" })

vim.keymap.set("n", "<leader>gpl", "<cmd>Octo pr list<cr>", { desc = "list" })
vim.keymap.set("n", "<leader>gpn", "<cmd>Octo pr create<cr>", { desc = "create" })

vim.keymap.set("n", "<C-h>", vim.cmd.TmuxNavigateLeft, { desc = "Navigate Left" })
vim.keymap.set("n", "<C-j>", vim.cmd.TmuxNavigateDown, { desc = "Navigate Down" })
vim.keymap.set("n", "<C-k>", vim.cmd.TmuxNavigateUp, { desc = "Navigate Up" })
vim.keymap.set("n", "<C-l>", vim.cmd.TmuxNavigateRight, { desc = "Navigate Right" })

vim.keymap.set({ "n", "i", "v" }, "<A-h>", vim.cmd.TmuxResizeLeft, { desc = "Resize Left" })
vim.keymap.set({ "n", "i", "v" }, "<A-j>", vim.cmd.TmuxResizeDown, { desc = "Resize Down" })
vim.keymap.set({ "n", "i", "v" }, "<A-k>", vim.cmd.TmuxResizeUp, { desc = "Resize Up" })
vim.keymap.set({ "n", "i", "v" }, "<A-l>", vim.cmd.TmuxResizeRight, { desc = "Resize Right" })
