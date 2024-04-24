return {
  "ThePrimeagen/harpoon",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = true,
  keys = {
    { "<leader>hm", "<cmd>lua require('harpoon.mark').add_file()<cr>", desc = "Mark file with harpoon" },
    { "<leader>hn", "<cmd>lua require('harpoon.ui').nav_next()<cr>", desc = "Go to next harpoon mark" },
    { "<leader>hp", "<cmd>lua require('harpoon.ui').nav_prev()<cr>", desc = "Go to previous harpoon mark" },
    { "<leader>hh", "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>", desc = "Show harpoon marks" },
  },
  opts = {
    global_settings = {
      mark_branch = true,
    },
    menu = {
      width = 90,
      height = 20,
    },
  },
}
