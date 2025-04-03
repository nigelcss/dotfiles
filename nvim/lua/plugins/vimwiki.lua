return {
  "vimwiki/vimwiki",
  init = function()
    vim.g.vimwiki_list = {
      { path = "~/vimwiki", syntax = "markdown", ext = ".md" },
    }
    vim.g.vimwiki_global_ext = 0
    vim.g.vimwiki_map_prefix = "<leader>W"
  end,
}
