vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

return {
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      local nvim_tree = require("nvim-tree")

      local function start_telescope(telescope_mode)
        local node = require("nvim-tree.api").tree.get_node_under_cursor()
        local abspath = node.link_to or node.absolute_path
        local is_folder = node.open ~= nil
        local basedir = is_folder and abspath or vim.fn.fnamemodify(abspath, ":h")
        require("telescope.builtin")[telescope_mode]({
          cwd = basedir,
        })
      end

      ---@param bufnr integer
      local function on_attach(bufnr)
        local api = require("nvim-tree.api")

        local function telescope_find_files(_)
          start_telescope("find_files")
        end

        local function telescope_live_grep(_)
          start_telescope("live_grep")
        end

        local function opts(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        api.config.mappings.default_on_attach(bufnr)

        vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
        vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
        vim.keymap.set("n", "v", api.node.open.vertical, opts("Open: Vertical Split"))
        vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
        vim.keymap.set("n", "C", api.tree.change_root_to_node, opts("CD"))
        vim.keymap.set("n", "gtg", telescope_live_grep, opts("Telescope Live Grep"))
        vim.keymap.set("n", "gtf", telescope_find_files, opts("Telescope Find File"))
      end

      nvim_tree.setup({
        on_attach = on_attach,
        filters = {
          dotfiles = true,
        },
      })
    end,
  },
}
