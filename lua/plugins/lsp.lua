return {
  {
    'williamboman/mason.nvim',
    enabled = true,
    config = true,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    enabled = true,
    config = true,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
          library = {
            -- See the configuration section for more details
            -- Load luvit types when the `vim.uv` word is found
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
      -- { -- optional cmp completion source for require statements and module annotations
      --   "hrsh7th/nvim-cmp",
      --   config = function()
      --     require 'cmp'.setup {
      --       -- snippet = {
      --       --   expand = function(args)
      --       --     require 'luasnip'.lsp_expand(args.body)
      --       --   end
      --       -- },
      --       -- sources = {
      --       --   { name = 'luasnip' },
      --       --   -- more sources
      --       -- },
      --     }
      --   end,
      --   opts = function(_, opts)
      --     opts.sources = opts.sources or {}
      --     table.insert(opts.sources, {
      --       name = "lazydev",
      --       group_index = 0, -- set group index to 0 to skip loading LuaLS completions
      --     })
      --   end,
      -- },
    },
    config = function()
      local capabilities = require('blink.cmp').get_lsp_capabilities()
      require("lspconfig").awk_ls.setup({ capabilities = capabilities })
      require("lspconfig").bashls.setup({ capabilities = capabilities })
      require("lspconfig").clangd.setup({ capabilities = capabilities })
      require("lspconfig").denols.setup({ capabilities = capabilities })
      require("lspconfig").dockerls.setup({ capabilities = capabilities })
      require("lspconfig").gitlab_ci_ls.setup({ capabilities = capabilities })
      require("lspconfig").gopls.setup({ capabilities = capabilities })
      require("lspconfig").graphql.setup({ capabilities = capabilities })
      -- helm_ls - experimental
      require("lspconfig").jedi_language_server.setup({})
      -- jsonls
      -- postgres_lsp
      -- rust_analyzer
      -- sqlls
      -- terraform_lsp
      require("lspconfig").lua_ls.setup({ capabilities = capabilities })
      require("lspconfig").ts_ls.setup({ capabilities = capabilities })
      -- require("lspconfig").yamlls.setup({ capabilities = capabilities })
      vim.g.markdown_fenced_languages = {
        "ts=typescript"
      }
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then
            return
          end

          if client:supports_method("textDocument/formatting") then
            -- Format the current buffer on save
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = args.buf,
              callback = function()
                vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
              end,
            })
          end
        end,
      })
    end,
  },
}
