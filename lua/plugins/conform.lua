return {
  {
    "stevearc/conform.nvim",
    enabled = true,
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local conform = require("conform")
      local front_end_opts = {
        "prettierd",
        "prettier",
        "eslint_d",
        stop_after_first = true,
      }
      conform.setup({
        formatters_by_ft = {
          ["*"] = { "trim_whitespace" },
          -- ["astro"] = { "prettierd", lsp_format = "fallback" },
          buf = { "buf" },
          css = { "prettier" },
          graphql = front_end_opts,
          go = { "gofumpt" },
          -- html = front_end_opts,
          javascript = front_end_opts,
          javascriptreact = front_end_opts,
          just = { "just" },
          json = front_end_opts,
          lua = { "stylua" },
          -- markdown = front_end_opts,
          python = { "black" }, -- isort is iffy
          rust = { "rustfmt", lsp_format = "fallback" },
          svelte = front_end_opts,
          typescript = front_end_opts,
          typescriptreact = front_end_opts,
          -- yaml = { "yamlfix", "prettier", stop_after_first = true },
          -- zig = { "zigfmt" },
        },
      })
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*",
        callback = function(args)
          conform.format({ bufnr = args.buf })
        end,
      })
    end,
  },
}
