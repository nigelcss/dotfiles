return {
  "mfussenegger/nvim-dap",
  keys = {
    {
      "<leader>dc",
      function()
        require("dap.ext.vscode").load_launchjs(".config/launch.json")
        require("dap").continue()
      end,
      desc = "Continue",
    },
    {
      "<leader>dR",
      function()
        require("dap").restart()
      end,
      desc = "Restart",
    },
    {
      "<C-M-h>",
      function()
        require("dap").step_out()
      end,
      desc = "Step Out",
    },
    {
      "<C-M-j>",
      function()
        require("dap").step_over()
      end,
      desc = "Step Over",
    },
    {
      "<C-M-k>",
      function()
        require("dap").continue()
      end,
      desc = "Continue",
    },
    {
      "<C-M-l>",
      function()
        require("dap").step_into()
      end,
      desc = "Step Into",
    },
  },
}
