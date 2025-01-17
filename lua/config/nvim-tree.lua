local M = {}

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

function M.start_telescope(telescope_mode)
  local node = require("nvim-tree.lib").get_node_at_cursor()
  local abspath = node.link_to or node.absolute_path
  local is_folder = node.open ~= nil
  local basedir = is_folder and abspath or vim.fn.fnamemodify(abspath, ":h")
  require("telescope.builtin")[telescope_mode] {
    cwd = basedir,
  }
end

---@param bufnr integer
function M.default_on_attach(bufnr)
  local api = require("nvim-tree.api")

  local function telescope_find_files(_)
    require("config.nvim-tree").start_telescope "find_files"
  end

  local function telescope_live_grep(_)
    require("config.nvim-tree").start_telescope "live_grep"
  end

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  api.config.mappings.default_on_attach(bufnr)

  -- vim.keymap.set("n", "l", api.tree.change_root_to_node, opts "Open")
  -- vim.keymap.set("n", "o", api.tree.change_root_to_node, opts "Open")
  -- vim.keymap.set("n", "<CR>", api.tree.change_root_to_node, opts "Open")
  -- vim.keymap.set("n", "v", api.tree.change_root_to_node, opts "Open: Vertical Split")
  -- vim.keymap.set("n", "h", api.tree.change_root_to_node, opts "Close Directory")
  -- vim.keymap.set("n", "C", api.tree.change_root_to_node, opts "CD")
  -- vim.keymap.set("n", "gtg", telescope_live_grep, opts "Telescope Live Grep")
  -- vim.keymap.set("n", "gtf", telescope_find_files, opts "Telescope Find File")
end

function M.setup(opts)
  M.on_attach = M.default_on_attach
  -- if opts == nil or opts.on_attach == nil or type(opts.on_attach) ~= "function" then
  --   M.on_attach = M.default_on_attach
  -- else
  --   M.on_attach = opts.on_attach
  -- end
end

return M
