return {
  "stevearc/conform.nvim",
  optional = true,
  opts = {
    formatters_by_ft = {
      ["css"] = { "prettier" },
      ["scss"] = { "prettier" },
      ["yaml"] = { "prettier" },
      ["json"] = { "prettier" },
    },
  },
}
