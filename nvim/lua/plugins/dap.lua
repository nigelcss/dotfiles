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
  },
}
