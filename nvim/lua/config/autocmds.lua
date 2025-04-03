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

vim.cmd("cabbrev stop echo 'Suspending disabled'")

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.tmpl",
  callback = function()
    vim.bo.filetype = "gotmpl"
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "gotmpl",
  callback = function()
    vim.bo.expandtab = true
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 4
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.bo.expandtab = false
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.softtabstop = 2
  end,
})
