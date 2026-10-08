return {
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewFileHistory",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
    },
    keys = {
      {
        "<leader>gd",
        function()
          vim.ui.input({ prompt = "Diffview rev/range: ", default = "develop...HEAD" }, function(input)
            if input == nil then
              return
            end
            vim.cmd("DiffviewOpen " .. input)
          end)
        end,
        desc = "Diffview branch/range",
      },
      {
        "<leader>gD",
        "<cmd>DiffviewClose<cr>",
        desc = "Diffview close",
      },
      {
        "<leader>gH",
        "<cmd>DiffviewFileHistory %<cr>",
        desc = "Diffview file history",
      },
    },
    opts = {
      file_panel = {
        win_config = {
          width = 60,
        },
      },
    },
  },
}
