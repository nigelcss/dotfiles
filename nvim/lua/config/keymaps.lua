-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local Util = require("lazyvim.util")

vim.keymap.set("n", "<C-s>", "<cmd>wa<cr>", { desc = "Write all" })
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "{", "{zz")
vim.keymap.set("n", "}", "}zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("v", "<leader>sv", function()
  vim.cmd('normal! "zy')
  local text = vim.fn.getreg("z")
  require("telescope.builtin").grep_string({
    search = text,
  })
end, { desc = "Visual Selection" })

vim.keymap.set("v", "<leader>ss", function()
  vim.cmd('normal! "zy')
  local text = vim.fn.getreg("z")
  require("telescope.builtin").grep_string({
    search = text,
    additional_args = function(opts)
      return { "--glob=*.css", "--glob=*.scss" }
    end,
  })
end, { desc = "Search in stylesheets" })

vim.keymap.set(
  "n",
  "<leader>gg",
  ":!tmux new-window -c " .. vim.fn.getcwd() .. " -- lazygit <CR><CR>",
  { desc = "LazyGit", silent = true }
)

vim.keymap.set("n", "<leader>gf", function()
  local current_file = vim.api.nvim_buf_get_name(0)
  local cwd = vim.fn.getcwd()
  local command = "tmux new-window -c "
    .. vim.fn.shellescape(cwd)
    .. " -- lazygit -f "
    .. vim.fn.shellescape(current_file)
  vim.fn.system(command)
end, { desc = "LazyGit file", silent = true })

vim.keymap.set("n", "<leader>z", vim.cmd.ZenMode, { desc = "Toggle Zen Mode" })

vim.keymap.set("n", "<leader>O", vim.cmd.AerialToggle, { desc = "Toggle Aerial" })

vim.keymap.set("n", "<leader>n", vim.cmd.UndotreeToggle, { desc = "Toggle Undotree" })

vim.keymap.set("n", "<leader>D", vim.cmd.DBUIToggle, { desc = "Toggle Debug UI" })

vim.keymap.set("n", "<leader>C", "<cmd>ChatGPT<cr>", { desc = "ChatGPT" })

vim.keymap.set({ "n", "v" }, "<leader>go", "<cmd>Octo<cr>", { desc = "Octo" })
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
