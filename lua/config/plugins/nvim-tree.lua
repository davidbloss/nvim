return {
  {
    'nvim-tree/nvim-tree.lua',
    config = function()
      require 'nvim-tree'.setup({
        -- on_attach = require("config.nvim-tree").default_on_attach,
        filters = {
          dotfiles = true,
        }
      })
      -- local api = require("nvim-tree.api")
      -- local function opts(desc)
      --   return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      -- end
      -- vim.keymap.set("n", "l", api.tree.change_root_to_node, opts "Open")
      -- vim.keymap.set("n", "o", api.tree.change_root_to_node, opts "Open")
      -- vim.keymap.set("n", "<CR>", api.tree.change_root_to_node, opts "Open")
      -- vim.keymap.set("n", "v", api.tree.change_root_to_node, opts "Open: Vertical Split")
      -- vim.keymap.set("n", "h", api.tree.change_root_to_node, opts "Close Directory")
      -- vim.keymap.set("n", "C", api.tree.change_root_to_node, opts "CD")
      -- vim.keymap.set("n", "gtg", telescope_live_grep, opts "Telescope Live Grep")
      -- vim.keymap.set("n", "gtf", telescope_find_files, opts "Telescope Find File")
    end,

  }
}
