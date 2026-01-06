return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        enabled = false,
      },
      servers = {
        eslint = {
          -- Force eslint to act as a formatter
          on_attach = function(client)
            client.server_capabilities.documentFormattingProvider = true
          end,
        },
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
          -- Prevent vtsls from acting as a formatter
          on_attach = function(client)
            client.server_capabilities.documentFormattingProvider = false
          end,
        },
      },
    },
  },
}
