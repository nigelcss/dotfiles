-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local Util = require("lazyvim.util")

vim.keymap.set({ "n", "v" }, "<C-z>", "<Nop>")

vim.keymap.set("n", "ZZ", ":wqa<CR>", { desc = "Save all and quit" })
vim.keymap.set("n", "<C-s>", "<cmd>wa<cr>", { desc = "Write all" })
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "{", "{zz")
vim.keymap.set("n", "}", "}zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Function to move the current buffer to the next window with a listed buffer
local function MoveBufferToNextWindow()
  local current_win = vim.api.nvim_get_current_win()
  local current_buf = vim.api.nvim_get_current_buf()

  local all_wins = vim.api.nvim_tabpage_list_wins(0)

  local function is_listed_buffer(win)
    local buf = vim.api.nvim_win_get_buf(win)
    return vim.fn.buflisted(buf) == 1
  end

  local wins = {}
  for _, win in ipairs(all_wins) do
    if is_listed_buffer(win) then
      table.insert(wins, win)
    end
  end

  if #wins <= 1 then
    print("No other window with a listed buffer to move to.")
    return
  end

  local current_win_index = nil
  for i, win in ipairs(wins) do
    if win == current_win then
      current_win_index = i
      break
    end
  end

  if not current_win_index then
    print("Current window does not have a listed buffer.")
    return
  end

  local next_win_index = (current_win_index % #wins) + 1
  local next_win = wins[next_win_index]

  -- Save the buffer currently in the next window
  local next_buf = vim.api.nvim_win_get_buf(next_win)

  -- Move the current buffer to the next window
  vim.api.nvim_win_set_buf(next_win, current_buf)

  -- Go back to the current window and restore the previously visited buffer
  vim.api.nvim_set_current_win(current_win)
  vim.cmd("b#")

  -- The above command switches this window to the previously visited buffer
  -- If you'd rather explicitly set a buffer yourself, store it before the swap
  -- and set it here instead of using `b#`.
end

-- Create a keymap to trigger the function (e.g., using <Leader>mb)
vim.keymap.set("n", "<leader>bm", MoveBufferToNextWindow, { desc = "Move buffer", silent = true })

vim.keymap.set("v", "<leader>ss", function()
  vim.cmd('normal! "zy')
  local text = vim.fn.getreg("z")
  require("fzf-lua").grep({
    search = text,
    rg_opts = "--column --line-number --glob=*.css --glob=*.scss",
  })
end, { desc = "Search in stylesheets" })

vim.keymap.set("v", "<leader>sa", function()
  vim.cmd('normal! "zy')

  local hookName = vim.fn.getreg("z")

  local functionName = hookName:gsub("^use", ""):gsub("Query$", ""):gsub("Mutation$", "")
  if #functionName > 0 then
    functionName = functionName:sub(1, 1):lower() .. functionName:sub(2)
  end

  require("fzf-lua").grep({
    search = functionName,
    rg_opts = "--column --line-number --glob=*API.ts",
  })
end, { desc = "Search in APIs" })

vim.keymap.set(
  "n",
  "<leader>gg",
  ":!tmux new-window -c " .. vim.fn.getcwd() .. " -- lazygit <CR><CR>",
  { desc = "LazyGit", silent = true }
)

vim.keymap.set(
  "n",
  "<leader>kk",
  ":!tmux new-window -c " .. vim.fn.getcwd() .. " -- lazydocker <CR><CR>",
  { desc = "LazyDocker", silent = true }
)

vim.keymap.set("n", "<leader>gf", function()
  local current_file = vim.api.nvim_buf_get_name(0)
  local cwd = vim.fn.getcwd()
  local command = "tmux new-window -c "
    .. vim.fn.shellescape(cwd)
    .. " -- lazygit -f "
    .. vim.fn.shellescape(current_file)
  vim.fn.system(command)
end, { desc = "LazyGit file", silent = true })

vim.keymap.set("v", "<leader>gl", function()
  -- Get the buffer number, start line, and start column of the visual selection
  local start_pos = vim.fn.getpos("v")
  local end_pos = vim.fn.getpos(".")

  -- Extract line numbers
  local start_line = start_pos[2]
  local end_line = end_pos[2]

  -- Ensure the start line is less than the end line
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  -- Get the full path of the current file
  local file_path = vim.fn.expand("%:p")

  -- Construct the git log command
  local git_cmd = {
    "git",
    "log",
    "-L",
    start_line .. "," .. end_line .. ":" .. file_path,
  }

  -- Run the command and capture the output
  local output = vim.fn.systemlist(git_cmd)

  -- Check for errors
  if vim.v.shell_error ~= 0 then
    vim.notify("Error running git log:\n" .. table.concat(output, "\n"), vim.log.levels.ERROR)
    return
  end

  -- Create a new buffer in the current window
  vim.cmd("enew") -- Equivalent to :enew command in Vim
  local buf = vim.api.nvim_get_current_buf()

  -- Set buffer options
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = true
  vim.bo[buf].filetype = "git" -- Enables git syntax highlighting

  -- Set buffer name for identification
  vim.api.nvim_buf_set_name(buf, "[Git Log] " .. vim.fn.fnamemodify(file_path, ":t"))

  -- Insert the output into the buffer
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)

  -- Disable modifiable to prevent editing
  vim.bo[buf].modifiable = false

  -- Move cursor to the top of the buffer
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
end, { desc = "Git Log for selected lines", silent = true })

vim.keymap.set("n", "<leader>cg", function()
  local filepath = vim.fn.expand("%:p")
  if filepath == "" then
    vim.notify("No file to format.", vim.log.levels.ERROR)
    return
  end

  vim.cmd("!gofumpt -w " .. vim.fn.fnameescape(filepath))

  vim.cmd("edit!")
end, { desc = "Run gofumpt on the current file" })

-- Cursor maps

local function copyHarpoonMarkedFiles()
  local ok, harpoon = pcall(require, "harpoon")
  if not ok then
    vim.notify("Harpoon is not installed or failed to load", vim.log.levels.ERROR)
    return
  end

  local marksList = harpoon:list()
  if not marksList then
    vim.notify("No harpoon list found", vim.log.levels.WARN)
    return
  end

  local marks = marksList.items
  if not marks or vim.tbl_isempty(marks) then
    vim.notify("No harpoon marked files found", vim.log.levels.WARN)
    return
  end

  local result = {}
  for _, mark in ipairs(marks) do
    local fullPath = mark.value or ""
    if fullPath ~= "" then
      local filename = vim.fn.fnamemodify(fullPath, ":t")
      table.insert(result, "@" .. filename)
    end
  end

  local str = table.concat(result, " ")
  vim.fn.setreg("+", str)

  return str
end

vim.keymap.set("n", "<leader>ac@h", function()
  vim.notify("Copied harpoon marks to clipboard: " .. copyHarpoonMarkedFiles(), vim.log.levels.INFO)
end, { desc = "@ harpoon files" })

vim.keymap.set("n", "<leader>acc", function()
  local file = vim.fn.expand("%:p")
  local line = vim.fn.line(".")
  local col = vim.fn.col(".")
  local cmd = string.format("code . && code -g %s:%d:%d", file, line, col)
  copyHarpoonMarkedFiles()
  os.execute(cmd)
end, { desc = "Open in cursor" })

vim.keymap.set("n", "<leader>O", vim.cmd.AerialToggle, { desc = "Toggle Aerial" })

vim.keymap.set("n", "<leader>n", vim.cmd.UndotreeToggle, { desc = "Toggle Undotree" })

vim.keymap.set("n", "<leader>D", vim.cmd.DBUIToggle, { desc = "Toggle Debug UI" })

vim.keymap.set({ "n", "v" }, "<leader>go", "<cmd>Octo<cr>", { desc = "Octo" })
vim.keymap.set("n", "<leader>gpl", "<cmd>Octo pr list<cr>", { desc = "list" })
vim.keymap.set("n", "<leader>gpn", "<cmd>Octo pr create<cr>", { desc = "create" })

vim.keymap.set("n", "<C-h>", vim.cmd.TmuxNavigateLeft, { desc = "Navigate Left" })
vim.keymap.set("n", "<C-j>", vim.cmd.TmuxNavigateDown, { desc = "Navigate Down" })
vim.keymap.set("n", "<C-k>", vim.cmd.TmuxNavigateUp, { desc = "Navigate Up" })
vim.keymap.set("n", "<C-l>", vim.cmd.TmuxNavigateRight, { desc = "Navigate Right" })

vim.keymap.set({ "n", "i", "v" }, "<A-h>", vim.cmd.TmuxResizeLeft, { desc = "Resize Left" })
vim.keymap.set({ "n", "i", "v" }, "<A-j>", vim.cmd.TmuxResizeDown, { desc = "Resize Down" })
vim.keymap.set({ "n", "i", "v" }, "<A-k>", vim.cmd.TmuxResizeUp, { desc = "Resize Up" })
vim.keymap.set({ "n", "i", "v" }, "<A-l>", vim.cmd.TmuxResizeRight, { desc = "Resize Right" })
