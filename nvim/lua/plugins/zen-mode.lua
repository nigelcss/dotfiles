return {
  "folke/zen-mode.nvim",
  opts = {
    window = {
      backdrop = 0.925,
      width = 160,
    },
    plugins = {
      tmux = { enabled = true },
      wezterm = {
        enabled = true,
        font = "+0", -- (10% increase per step)
      },
    },
  },
}
