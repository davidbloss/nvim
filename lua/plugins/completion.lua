return {
  {
    "saghen/blink.cmp",
    dependencies = "rafamadriz/friendly-snippets",

    version = "*",

    opts = {
      keymap = { preset = "default" },

      completion = {
        accept = {
          auto_brackets = { enabled = true },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 500,
        },
        menu = {
          draw = { treesitter = { "lsp" } },
        },
      },

      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
      },

      signature = {
        enabled = false,
        window = {
          -- show_documentation = false,
          treesitter_highlighting = true,
        },
      },
    },
    -- opts_extend = { "sources.default" }
  },
}
