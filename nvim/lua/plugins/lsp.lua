return {
  {
    "neovim/nvim-lspconfig",
    init = function()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      keys[#keys + 1] = { "gr", "<cmd>Telescope lsp_references show_line=false<cr>", desc = "Find References" }
      keys[#keys + 1] = { "gd", "<cmd>Telescope lsp_definitions show_line=false<cr>", desc = "Goto Definition" }
    end,
  },
}
