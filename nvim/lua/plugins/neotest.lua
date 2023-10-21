return {
  {
    "nvim-neotest/neotest",
    opts = {
      adapters = {
        ["neotest-go"] = {
          args = { "-tags=test" },
        },
      },
    },
  },
}
