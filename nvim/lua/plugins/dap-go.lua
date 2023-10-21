return {
  {
    "leoluz/nvim-dap-go",
    config = function()
      require("dap-go").setup({
        delve = {
          build_flags = "-tags=test",
        },
      })
    end,
  },
}
