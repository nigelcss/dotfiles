return {
  "mfussenegger/nvim-dap",
  keys = {
    {
      "<leader>dc",
      function()
        require("dap.ext.vscode").load_launchjs()
        require("dap").continue()
      end,
      desc = "Continue",
    },
    {
      "<C-A-h>",
      function()
        require("dap").step_out()
      end,
      desc = "Step Out",
    },
    {
      "<C-A-j>",
      function()
        require("dap").step_over()
      end,
      desc = "Step Over",
    },
    {
      "<C-A-k>",
      function()
        require("dap").continue()
      end,
      desc = "Continue",
    },
    {
      "<C-A-l>",
      function()
        require("dap").step_into()
      end,
      desc = "Step Into",
    },
  },
}
