-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
--
vim.cmd([[
  augroup QuickFixKeyMappings
    autocmd!
    autocmd FileType qf nnoremap <buffer> <Tab> :cnewer<CR>
    autocmd FileType qf nnoremap <buffer> <S-Tab> :colder<CR>
  augroup END
]])
