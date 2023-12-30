return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = false,
  ft = "markdown",
  -- event = {
  -- "BufReadPre " .. vim.fn.expand("~") .. "/Obsidian/default/**.md",
  -- },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    workspaces = {
      {
        name = "default",
        path = "~/Obsidian/default",
      },
    },
  },
}
