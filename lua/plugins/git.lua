local git_icons = require("config.icons").git
local gitsigns_opts = {
  on_attach = function(bufnr)
    local gitsigns = require("gitsigns")
    vim.keymap.set("n", "[h", function()
      gitsigns.nav_hunk("prev")
    end)
    vim.keymap.set("n", "]h", function()
      gitsigns.nav_hunk("next")
    end)

    vim.keymap.set("n", "<leader>hi", gitsigns.preview_hunk_inline)
    vim.keymap.set("n", "<leader>hp", gitsigns.preview_hunk)
    vim.keymap.set("n", "<leader>hr", gitsigns.reset_hunk)
    vim.keymap.set("n", "<leader>hs", gitsigns.stage_hunk)
    vim.keymap.set("n", "<leader>hb", function()
      gitsigns.blame_line({ full = false })
    end)
    vim.keymap.set("n", "<leader>hB", function()
      gitsigns.blame_line({ full = true })
    end)

    -- Toggles
    vim.keymap.set("n", "<leader>tb", gitsigns.toggle_current_line_blame)
    vim.keymap.set("n", "<leader>tw", gitsigns.toggle_word_diff)
  end,
  signs = {
    add = { text = git_icons.LineAdded },
    -- vim.api.nvim_set_hl(0, "GitSignsAdd", { link = "GitSignsAdd" })
    -- vim.api.nvim_set_hl(0, "GitSignsAdd", { link = "GitSignsAddLn" })
    -- vim.api.nvim_set_hl(0, "GitSignsAdd", { link = "GitSignsAddNr" })
    change = { text = git_icons.LineModified },
    -- vim.api.nvim_set_hl(0, 'GitSignsAdd', { link = 'GitSignsChange' })
    -- vim.api.nvim_set_hl(0, 'GitSignsAdd', { link = 'GitSignsChangeLn' })
    -- vim.api.nvim_set_hl(0, 'GitSignsAdd', { link = 'GitSignsChangeNr' })
    delete = { text = git_icons.LineRemoved },
    -- vim.api.nvim_set_hl(0, 'GitSignsAdd', { link = 'GitSignsDelete' })
    -- vim.api.nvim_set_hl(0, 'GitSignsAdd', { link = 'GitSignsDeleteLn' })
    -- vim.api.nvim_set_hl(0, 'GitSignsAdd', { link = 'GitSignsDeleteNr' })
    topdelete = { text = git_icons.LineRemoved },
    changedelete = { text = git_icons.LineModified },
  },
  signcolumn = true,
  numhl = true,
  linehl = false,
  word_diff = false,
  current_line_blame_opts = {
    delay = 300,
  },
  watch_gitdir = {
    interval = 1000,
    follow_files = true,
  },
  attach_to_untracked = true,
  current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
    ignore_whitespace = false,
  },
  current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
  sign_priority = 6,
  status_formatter = nil, -- Use default
  update_debounce = 200,
  max_file_length = 40000,
  preview_config = {
    -- Options passed to nvim_open_win
    border = "rounded",
    style = "minimal",
    relative = "cursor",
    row = 0,
    col = 1,
  },
}
return {
  {
    "lewis6991/gitsigns.nvim",
    enabled = true,
    opts = gitsigns_opts,
  },
  {
    "tpope/vim-fugitive",
    enabled = true,
  },
}
