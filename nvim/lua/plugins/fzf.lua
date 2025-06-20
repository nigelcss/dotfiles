return {
  "ibhagwan/fzf-lua",
  keys = {
    { "<leader>/", LazyVim.pick("live_grep", { root = false }), desc = "Grep (Root Dir)" },
    { "<leader><space>", LazyVim.pick("files", { root = false }), desc = "Find Files (Root Dir)" },
    -- find
    { "<leader>ff", LazyVim.pick("files", { root = false }), desc = "Find Files (Root Dir)" },
    { "<leader>fF", LazyVim.pick("files"), desc = "Find Files (cwd)" },
    { "<leader>fg", "<cmd>FzfLua git_files<cr>", desc = "Find Files (git-files)" },
    { "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent" },
    { "<leader>fR", LazyVim.pick("oldfiles", { cwd = vim.uv.cwd() }), desc = "Recent (cwd)" },
    -- git
    { "<leader>sg", LazyVim.pick("live_grep", { root = false }), desc = "Grep (Root Dir)" },
    { "<leader>sG", LazyVim.pick("live_grep"), desc = "Grep (cwd)" },
    { "<leader>sw", LazyVim.pick("grep_cword", { root = false }), desc = "Word (Root Dir)" },
    { "<leader>sW", LazyVim.pick("grep_cword"), desc = "Word (cwd)" },
    { "<leader>sw", LazyVim.pick("grep_visual", { root = false }), mode = "v", desc = "Selection (Root Dir)" },
    { "<leader>sW", LazyVim.pick("grep_visual"), mode = "v", desc = "Selection (cwd)" },
  },
}
