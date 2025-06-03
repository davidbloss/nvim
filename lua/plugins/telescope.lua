return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      require("telescope").setup({
        pickers = {
          find_files = {
            theme = "ivy",
          },
        },
        extensions = {
          fzf = {},
          project = {
            -- base_dirs = { { path = "~/repos/", max_depth = 2 } },
            hidden_files = true, -- default: false
            theme = "dropdown",
            order_by = "asc",
            search_by = "title",
            sync_with_nvim_tree = true, -- default false
            -- default for on_project_selected = find project files
            on_project_selected = function(prompt_bufnr)
              -- Do anything you want in here. For example:
              require("telescope._extensions.project.actions").change_working_directory(prompt_bufnr, false)
            end,
          },
        },
      })
      require("telescope").load_extension("fzf")

      -- find keymaps
      vim.keymap.set("n", "<space>ff", require("telescope.builtin").find_files)
      vim.keymap.set("n", "<space>fh", require("telescope.builtin").help_tags)
      vim.keymap.set("n", "<space>fd", require("telescope.builtin").lsp_document_symbols)
      vim.keymap.set("n", "<space>fw", require("telescope.builtin").lsp_dynamic_workspace_symbols)
      vim.keymap.set("n", "<space>fb", require("telescope.builtin").current_buffer_fuzzy_find)

      -- buffer keymaps
      vim.keymap.set("n", "<space>B", require("telescope.builtin").buffers)
      -- vim.keymap.set("n", "<space>bd", require("telescope.builtin").buffers)

      -- edit neovim
      vim.keymap.set("n", "<space>en", function()
        require("telescope.builtin").find_files({
          cwd = vim.fn.stdpath("config"),
        })
      end)
      -- edit lazy installed plugin
      vim.keymap.set("n", "<space>ep", function()
        require("telescope.builtin").find_files({
          cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy"),
        })
      end)

      require("config.telescope.multigrep").setup()
    end,
  },
}
