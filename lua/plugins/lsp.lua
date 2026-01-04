return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "williamboman/mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" },
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
    },
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      local lspconfig = vim.lsp.config
      lspconfig.astro = { capabilities = capabilities }
      lspconfig.awk_ls = { capabilities = capabilities }
      lspconfig.bashls = { capabilities = capabilities }
      lspconfig.clangd = { capabilities = capabilities }
      -- lspconfig.dockerls = { capabilities = capabilities }
      lspconfig.gitlab_ci_ls = { capabilities = capabilities }
      lspconfig.gopls = { capabilities = capabilities }
      lspconfig.graphql = { capabilities = capabilities }
      -- helm_ls - experimental
      lspconfig.jedi_language_server = { capabilities = capabilities }
      lspconfig.pyright = { capabilities = capabilities }
      lspconfig.ruff = { -- not workin
        init_options = {
          settings = {
            logLevel = "debug",
          },
        },
      }
      lspconfig.lua_ls = { capabilities = capabilities }
      lspconfig.terraformls = {
        capabilities = capabilities,
        filetypes = { "hcl", "terraform", "terraform-vars" },
      }
      lspconfig.ts_ls = {
        capabilities = capabilities,
        filetypes = { "typescript", "typescriptreact" },
      }

      vim.g.markdown_fenced_languages = {
        "ts=typescript",
      }
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
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
