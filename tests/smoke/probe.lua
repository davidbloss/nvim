-- Run with `+luafile` after init.lua: opens one fixture, exercises the config and
-- writes a JSON result to $SMOKE_OUT.
local file = assert(os.getenv("SMOKE_FILE"))
local out = assert(os.getenv("SMOKE_OUT"))
local servers = vim.split(os.getenv("SMOKE_SERVERS") or "", ",", { trimempty = true })
local lsp_timeout = tonumber(os.getenv("SMOKE_LSP_TIMEOUT")) or 30000
local ts_timeout = tonumber(os.getenv("SMOKE_TS_TIMEOUT")) or 15000

local result = { file = vim.fs.basename(file), lsp = {}, errors = {} }

local function try(what, fn)
  local ok, err = pcall(fn)
  if not ok then
    table.insert(result.errors, what .. ": " .. tostring(err))
  end
end

local function sleep(ms)
  vim.wait(ms, function()
    return false
  end, 50)
end

try("edit", function()
  vim.cmd.edit(vim.fn.fnameescape(file))
end)
local buf = vim.api.nvim_get_current_buf()
result.filetype = vim.bo[buf].filetype

-- treesitter highlighter
vim.wait(ts_timeout, function()
  return vim.treesitter.highlighter.active[buf] ~= nil
end, 100)
result.treesitter = vim.treesitter.highlighter.active[buf] ~= nil

-- LSP: a server is expected only when it is enabled and its binary is installed
local expected = {}
for _, name in ipairs(servers) do
  local config = vim.lsp.config[name]
  local cmd = config and config.cmd
  if not config then
    result.lsp[name] = "skip: no vim.lsp.config for " .. name
  elseif type(cmd) == "table" and vim.fn.executable(cmd[1]) == 0 then
    result.lsp[name] = ("skip: `%s` not installed"):format(cmd[1])
  elseif not vim.lsp.is_enabled(name) then
    result.lsp[name] = "skip: not enabled (install it with :Mason to enable it)"
  else
    expected[name] = true
  end
end

local function attached()
  local names = {}
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
    names[client.name] = true
  end
  return names
end

vim.wait(lsp_timeout, function()
  local names = attached()
  for name in pairs(expected) do
    if not names[name] then
      return false
    end
  end
  return true
end, 200)

local names = attached()
for name in pairs(expected) do
  result.lsp[name] = names[name] and "ok" or ("fail: did not attach within %d ms"):format(lsp_timeout)
end
result.clients = vim.tbl_keys(names)
table.sort(result.clients)
sleep(1000) -- let diagnostics / progress messages arrive

-- exercise the config the way it is used
try("]d keymap", function()
  local ns = vim.api.nvim_create_namespace("smoke")
  vim.diagnostic.set(ns, buf, { { lnum = 0, col = 0, message = "smoke", severity = vim.diagnostic.severity.WARN } })
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  vim.api.nvim_feedkeys("]d", "x", false)
  vim.api.nvim_feedkeys("[d", "x", false)
  vim.diagnostic.reset(ns, buf)
end)
try("yank", function()
  vim.cmd("normal! yy")
end)
try("hover", function()
  vim.lsp.buf.hover()
end)
try("write", function()
  vim.cmd("silent write")
end)
sleep(1500)
try("telescope lsp_document_symbols", function()
  require("telescope.builtin").lsp_document_symbols()
  sleep(1000)
  vim.cmd("stopinsert")
  vim.cmd("silent! close!")
end)
sleep(500)

result.messages = vim.api.nvim_exec2("messages", { output = true }).output
local state = require("smoke.state")
result.deprecations = state.deprecations
result.notifications = state.notifications

local f = assert(io.open(out, "w"))
f:write(vim.json.encode(result))
f:close()
vim.cmd("qa!")
