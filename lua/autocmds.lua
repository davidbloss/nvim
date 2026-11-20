vim.api.nvim_create_autocmd("TermOpen", {
  group = vim.api.nvim_create_augroup("custom-term-open", { clear = true }),
  callback = function()
    vim.opt.number = false
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    -- vim.hl.on_yank() is deprecated in Nvim 0.13 in favor of vim.hl.hl_op()
    if vim.hl.hl_op then
      vim.hl.hl_op()
    else
      vim.hl.on_yank()
    end
  end,
})
