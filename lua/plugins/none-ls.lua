return {
  {
    "nvimtools/none-ls.nvim",
    -- dependencies = {
    --   "nvimtools/none-ls-extras.nvim",
    -- },
    enabled = false,
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          -- code_actions
          -- null_ls.builtins.code_actions.shellcheck
          -- diagnostics
          null_ls.builtins.formatting.just,
          -- null_ls.builtins.formatting.nginx_beautifier,
          -- null_ls.builtins.formatting.pg_format,
        },
      })
    end,
    -- config = true,
  },
}
