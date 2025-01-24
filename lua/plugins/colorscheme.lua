return {
  {
    'folke/tokyonight.nvim',
    enabled = false,
    config = function()
      vim.cmd.colorscheme("tokyonight")
    end,
  },
  {
    'luisiacc/gruvbox-baby',
    enabled = true,
    config = function()
      vim.cmd.colorscheme("gruvbox-baby")
    end,
  }
}
