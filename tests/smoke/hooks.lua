-- Loaded with `--cmd` before init.lua: records deprecations and WARN+ notifications.
local repo = assert(os.getenv("SMOKE_REPO"), "SMOKE_REPO not set")
local config = vim.fn.stdpath("config") --[[@as string]]
local runtime = vim.env.VIMRUNTIME

-- shared with probe.lua through package.loaded (no globals)
local Smoke = { deprecations = {}, notifications = {} }
package.loaded["smoke.state"] = Smoke

local function relpath(path, root)
  if root and path:sub(1, #root + 1) == root .. "/" then
    return path:sub(#root + 2)
  end
end

--- First stack frame outside of Nvim's runtime and this file.
local function origin()
  local level = 3
  while true do
    local info = debug.getinfo(level, "Sl")
    if not info then
      return "nvim"
    end
    local src = info.source or ""
    if src:sub(1, 1) == "@" then
      local path = src:sub(2)
      -- runtime modules compiled into the binary have relative names like "vim/F"
      local in_runtime = path:sub(1, 1) ~= "/" or (runtime and path:sub(1, #runtime) == runtime)
      if not in_runtime and not path:find("tests/smoke/", 1, true) then
        local plugin, rest = path:match("/lazy/([^/]+)/(.*)$")
        if plugin then
          return ("plugin:%s:%s:%d"):format(plugin, rest, info.currentline)
        end
        local rel = relpath(path, config) or relpath(path, repo)
        if rel then
          return ("config:%s:%d"):format(rel, info.currentline)
        end
        return ("%s:%d"):format(path, info.currentline)
      end
    end
    level = level + 1
  end
end

local deprecate = vim.deprecate
---@diagnostic disable-next-line: duplicate-set-field
vim.deprecate = function(name, alternative, version, plugin, backtrace)
  table.insert(Smoke.deprecations, {
    name = name,
    alternative = alternative,
    version = version,
    plugin = plugin or "Nvim",
    origin = origin(),
  })
  return deprecate(name, alternative, version, plugin, backtrace)
end

local notify = vim.notify
---@diagnostic disable-next-line: duplicate-set-field
vim.notify = function(msg, level, opts)
  if (level or vim.log.levels.INFO) >= vim.log.levels.WARN then
    table.insert(Smoke.notifications, { msg = tostring(msg), level = level, origin = origin() })
  end
  return notify(msg, level, opts)
end
