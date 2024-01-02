return {
  "folke/zen-mode.nvim",
  opts = {
    plugins = {
      tmux = { enabled = true },
      wezterm = {
        enabled = true,
        font = "+0", -- (10% increase per step)
      },
    },
  },
}
