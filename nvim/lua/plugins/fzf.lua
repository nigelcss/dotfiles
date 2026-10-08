-- Grepping ~ feeds fzf every match under the home directory, which fzf holds in
-- memory until the picker closes (once grew to 6.5 GB), so ask first.
local function confirm_home(command, opts)
  local picker = LazyVim.pick(command, opts)
  return function()
    local dir = (opts and opts.root == false) and vim.uv.cwd() or LazyVim.root()
    if vim.fs.normalize(dir) == vim.fs.normalize(vim.env.HOME) then
      if vim.fn.confirm("Grep the entire home directory?", "&Yes\n&No", 2) ~= 1 then
        return
      end
    end
    picker()
  end
end

return {
  "ibhagwan/fzf-lua",
  keys = {
    { "<leader>gd", false },
    { "<leader>gD", false },
    { "<leader>/", LazyVim.pick("live_grep", { root = false }), desc = "Grep (Root Dir)" },
    { "<leader><space>", LazyVim.pick("files", { root = false }), desc = "Find Files (Root Dir)" },
    -- find
    { "<leader>ff", LazyVim.pick("files", { root = false }), desc = "Find Files (Root Dir)" },
    { "<leader>fF", LazyVim.pick("files"), desc = "Find Files (cwd)" },
    { "<leader>fg", "<cmd>FzfLua git_files<cr>", desc = "Find Files (git-files)" },
    { "<leader>fr", LazyVim.pick("oldfiles", { cwd = vim.uv.cwd() }), desc = "Recent (cwd)" },
    { "<leader>fR", "<cmd>FzfLua oldfiles<cr>", desc = "Recent" },
    -- git
    { "<leader>sg", LazyVim.pick("live_grep", { root = false }), desc = "Grep (Root Dir)" },
    { "<leader>sG", LazyVim.pick("live_grep"), desc = "Grep (cwd)" },
    { "<leader>sw", confirm_home("grep_cword", { root = false }), desc = "Word (Root Dir)" },
    { "<leader>sW", confirm_home("grep_cword"), desc = "Word (cwd)" },
    { "<leader>sw", confirm_home("grep_visual", { root = false }), mode = "v", desc = "Selection (Root Dir)" },
    { "<leader>sW", confirm_home("grep_visual"), mode = "v", desc = "Selection (cwd)" },
  },
}
