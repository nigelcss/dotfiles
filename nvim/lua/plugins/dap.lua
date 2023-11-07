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
      "<S-M-h>",
      function()
        require("dap").step_out()
      end,
      desc = "Step Out",
    },
    {
      "<S-M-j>",
      function()
        require("dap").step_over()
      end,
      desc = "Step Over",
    },
    {
      "<S-M-k>",
      function()
        require("dap").continue()
      end,
      desc = "Continue",
    },
    {
      "<S-M-l>",
      function()
        require("dap").step_into()
      end,
      desc = "Step Into",
    },
  },
}
