-- Known, harmless notes that should not fail the smoke test.
-- Keep this list short and explain every entry.
return {
  -- vim.deprecate() calls: { name = <lua pattern>, from = <lua pattern on origin> }
  -- An origin is "config:<file>:<line>", "plugin:<name>:<file>:<line>" or "nvim".
  -- Calls from this config ("config:...") are never allow-listed.
  deprecations = {
    -- soft deprecations (checkhealth only, removal in 0.15) in plugins already at their latest commit
    { name = "^vim%.F%.", from = "^plugin:" },
    { name = "^vim%.uri_", from = "^plugin:lazydev%.nvim" },
  },

  -- :messages / vim.notify lines (lua patterns) that look like problems but are not
  messages = {
    "No information available", -- hover on a position without docs
    "No definition found",
    "No more valid diagnostics",
    "clipboard: No provider", -- headless box without xclip/wl-copy
    "^%[nvim%-treesitter", -- parser install progress
    "Some capabilities may be reduced when editing a single file", -- terraform-ls: fixture is not in a root module
  },

  -- lines that are reported as SKIP notes instead of failures
  skips = {
    "Error running ([%w_%-]+): ENOENT", -- nvim-lint: linter binary not installed
  },
}
