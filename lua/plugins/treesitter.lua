local ensure_installed = {
  "c",
  "go",
  "json",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
  "query",
  "python",
  "sql",
  "terraform",
  "toml",
  "vim",
  "vimdoc",
  "yaml",
  "zig",
}

return {
  {
    -- `main` is a rewrite of nvim-treesitter for Nvim 0.12+: it only installs
    -- parsers/queries, highlighting is started with vim.treesitter.start()
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")
      ts.install(ensure_installed)

      local max_filesize = 100 * 1024 -- 100 KB

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
        callback = function(args)
          local buf = args.buf
          local lang = vim.treesitter.language.get_lang(args.match)
          if not lang then
            return
          end

          local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return
          end

          local function start()
            if vim.api.nvim_buf_is_valid(buf) then
              -- also turns off regex syntax highlighting (additional_vim_regex_highlighting = false)
              pcall(vim.treesitter.start, buf, lang)
            end
          end

          if vim.treesitter.language.add(lang) then
            start()
          elseif vim.list_contains(ts.get_available(), lang) then
            -- auto_install: install the missing parser, then start highlighting
            ts.install(lang):await(vim.schedule_wrap(start))
          end
        end,
      })
    end,
  },
}
