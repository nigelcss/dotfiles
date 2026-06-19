-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set({ "n", "v" }, "<C-z>", "")

vim.keymap.set("n", "ZZ", ":wqa<CR>", { desc = "Save all and quit" })
vim.keymap.set("n", "<C-s>", "<cmd>wa<cr>", { desc = "Write all" })
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "{", "{zz")
vim.keymap.set("n", "}", "}zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<leader>o", vim.cmd.AerialToggle, { desc = "Toggle Aerial" })
vim.keymap.set("n", "<leader>n", vim.cmd.UndotreeToggle, { desc = "Toggle Undotree" })
vim.keymap.set("n", "<leader>C", "<cmd>ChatGPT<cr>", { desc = "ChatGPT" })

vim.keymap.set("n", "<C-h>", ":diffget local<CR>", { desc = "Get LOCAL" })
vim.keymap.set("n", "<C-j>", "]c", { desc = "Prev Change" })
vim.keymap.set("n", "<C-k>", "[c", { desc = "Next Change" })
vim.keymap.set("n", "<C-l>", ":diffget remote<CR>", { desc = "Get REMOTE" })

vim.keymap.set("n", "<leader>d", function()
  local bufs = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buflisted or vim.wo[win].diff then
      local name = vim.api.nvim_buf_get_name(buf)
      if name ~= "" then
        table.insert(bufs, vim.fn.fnameescape(name))
      end
    end
  end
  if #bufs >= 2 then
    vim.cmd("botright split | terminal difft " .. bufs[1] .. " " .. bufs[2])
  else
    vim.notify("Need 2 diff buffers to run difftastic", vim.log.levels.WARN)
  end
end, { desc = "Semantic diff (difftastic)" })

vim.keymap.set({ "n", "i", "v" }, "<A-h>", vim.cmd.TmuxResizeLeft, { desc = "Resize Left" })
vim.keymap.set({ "n", "i", "v" }, "<A-j>", vim.cmd.TmuxResizeDown, { desc = "Resize Down" })
vim.keymap.set({ "n", "i", "v" }, "<A-k>", vim.cmd.TmuxResizeUp, { desc = "Resize Up" })
vim.keymap.set({ "n", "i", "v" }, "<A-l>", vim.cmd.TmuxResizeRight, { desc = "Resize Right" })
