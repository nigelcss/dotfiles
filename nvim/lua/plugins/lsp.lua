return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        enabled = false,
      },
      servers = {
        eslint = {},
        cssls = {},
        vtsls = {
          cmd = {
            "yarn",
            "dlx",
            "@vtsls/language-server",
            "--non-interactive",
            "--stdio",
          },
          root_dir = function(fname)
            return require("lspconfig").util.root_pattern(".yarn")(fname)
              or require("lspconfig").util.root_pattern("package.json", "tsconfig.json", ".git")(fname)
          end,
        },
      },
      setup = {
        eslint = function()
          require("lazyvim.util").lsp.on_attach(function(client)
            if client.name == "eslint" then
              client.server_capabilities.documentFormattingProvider = true
            elseif client.name == "vtsls" then
              client.server_capabilities.documentFormattingProvider = false
            end
          end)
        end,
      },
    },
  },
}
