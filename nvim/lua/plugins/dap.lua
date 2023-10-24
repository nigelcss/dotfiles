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
      "<C-Left>",
      function()
        require("dap").step_out()
      end,
      desc = "Step Out",
    },
    {
      "<C-Down>",
      function()
        require("dap").step_over()
      end,
      desc = "Step Over",
    },
    {
      "<C-Up>",
      function()
        require("dap").continue()
      end,
      desc = "Continue",
    },
    {
      "<C-Right>",
      function()
        require("dap").step_into()
      end,
      desc = "Step Into",
    },
  },
}
