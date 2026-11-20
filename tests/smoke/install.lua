-- Run with `+luafile` after init.lua: installs treesitter parsers and, when
-- SMOKE_MASON=1, the Mason packages the fixtures need. Exits non-zero on failure.
local failed = {}

if os.getenv("SMOKE_MASON") == "1" then
  local packages = {
    -- language servers
    "css-lsp",
    "gopls",
    "html-lsp",
    "jedi-language-server",
    "json-lsp",
    "lua-language-server",
    "pyright",
    "ruff",
    "terraform-ls",
    -- formatters / linters used on save and on BufEnter
    "black",
    "gofumpt",
    "jsonlint",
    "prettier",
    "stylua",
  }
  local registry = require("mason-registry")
  local pending
  registry.refresh(function()
    pending = 0
    for _, name in ipairs(packages) do
      local pkg = registry.get_package(name)
      if not pkg:is_installed() then
        pending = pending + 1
        pkg:install({}, function(ok, err)
          pending = pending - 1
          print(("mason: %s %s"):format(name, ok and "installed" or ("FAILED: " .. tostring(err))))
          if not ok then
            table.insert(failed, "mason " .. name)
          end
        end)
      end
    end
  end)
  if not vim.wait(900000, function()
    return pending == 0
  end, 500) then
    table.insert(failed, "mason: timed out")
  end
end

local parsers = { "css", "go", "html", "json", "lua", "luadoc", "python", "terraform", "vim", "vimdoc" }
local ok, err = pcall(function()
  require("nvim-treesitter").install(parsers):wait(600000)
end)
if not ok then
  table.insert(failed, "treesitter: " .. tostring(err))
end
-- the config also installs its ensure_installed list in the background: let it finish
local config = require("nvim-treesitter.config")
local last, stable_since = -1, vim.uv.now()
vim.wait(600000, function()
  local n = #config.get_installed("parsers")
  if n ~= last then
    last, stable_since = n, vim.uv.now()
  end
  return vim.uv.now() - stable_since > 5000
end, 500)
for _, lang in ipairs(parsers) do
  if not pcall(vim.treesitter.language.add, lang) or not vim.treesitter.language.add(lang) then
    table.insert(failed, "treesitter parser missing: " .. lang)
  end
end

if #failed > 0 then
  print("install failed:\n  " .. table.concat(failed, "\n  "))
  vim.cmd("cquit 1")
end
vim.cmd("qa!")
