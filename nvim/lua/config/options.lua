-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.tmux_resizer_resize_count = 3
vim.g.tmux_resizer_vertical_resize_count = 6

vim.opt.incsearch = false

vim.opt.spelllang = "en_us"
vim.opt.spell = true
vim.opt.spelloptions = "camel"

vim.opt.expandtab = false
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smarttab = true

vim.g.vimwiki_map_prefix = "<leader>W"

vim.g.lazygit_config = false
