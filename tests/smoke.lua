-- Headless smoke test for this config.
--
--   nvim --clean -l tests/smoke.lua [--install] [--no-sync] [fixture ...]
--
--   --install  also install Mason packages (language servers, formatters, linters)
--   --no-sync  skip `:Lazy! restore` and the treesitter parser install
--
-- Runs the config in an isolated XDG sandbox ($SMOKE_HOME, default .tests/),
-- opens every fixture in its own Nvim and fails on deprecation warnings,
-- errors, a missing treesitter highlighter or a language server that is
-- installed and enabled but does not attach.

local repo = vim.fs.normalize(vim.fn.fnamemodify(arg[0], ":p:h:h"))
local home = vim.fs.normalize(os.getenv("SMOKE_HOME") or (repo .. "/.tests"))
local nvim = vim.v.progpath

-- fixture -> language servers expected to attach
local fixtures = {
  { file = "sample.json", servers = { "jsonls" } },
  { file = "main.go", servers = { "gopls" } },
  { file = "index.html", servers = { "html" } },
  { file = "style.css", servers = { "cssls" } },
  { file = "sample.lua", servers = { "lua_ls" } },
  { file = "main.tf", servers = { "terraformls" } },
  { file = "sample.py", servers = { "pyright", "ruff", "jedi_language_server" } },
}

local opts = { install = false, sync = true, only = {} }
for _, a in ipairs(arg) do
  if a == "--install" then
    opts.install = true
  elseif a == "--no-sync" then
    opts.sync = false
  else
    opts.only[a] = true
  end
end

local allow = dofile(repo .. "/tests/smoke/allowlist.lua")

---@param s string
---@param patterns string[]
local function matches(s, patterns)
  for _, p in ipairs(patterns) do
    local m = s:match(p)
    if m then
      return m
    end
  end
end

-- sandbox --------------------------------------------------------------------
local env = {
  XDG_CONFIG_HOME = home .. "/config",
  XDG_DATA_HOME = home .. "/data",
  XDG_STATE_HOME = home .. "/state",
  XDG_CACHE_HOME = home .. "/cache",
  SMOKE_REPO = repo,
}
for _, dir in pairs({ env.XDG_CONFIG_HOME, env.XDG_DATA_HOME, env.XDG_STATE_HOME, env.XDG_CACHE_HOME }) do
  vim.fn.mkdir(dir, "p")
end
local link = env.XDG_CONFIG_HOME .. "/nvim"
if vim.uv.fs_readlink(link) ~= repo then
  vim.fn.delete(link)
  assert(vim.uv.fs_symlink(repo, link))
end

local function run(args, extra_env, timeout)
  local cmd = vim.list_extend({ nvim, "--headless" }, args)
  local r =
    vim.system(cmd, { env = vim.tbl_extend("force", env, extra_env or {}), text = true, cwd = repo }):wait(timeout)
  return r.code, (r.stdout or "") .. (r.stderr or "")
end

local function say(...)
  io.write(table.concat({ ... }, " ") .. "\n")
end

-- lazy.nvim rewrites lazy-lock.json while installing; never leave the repo dirty
local lockfile = repo .. "/lazy-lock.json"
local lock_before = table.concat(vim.fn.readfile(lockfile), "\n")
local function restore_lockfile()
  if table.concat(vim.fn.readfile(lockfile), "\n") ~= lock_before then
    vim.fn.writefile(vim.split(lock_before, "\n"), lockfile)
  end
end

local version = vim.version()
say(
  ("smoke: %s (Nvim %d.%d.%d%s)"):format(
    nvim,
    version.major,
    version.minor,
    version.patch,
    version.prerelease and ("-" .. tostring(version.prerelease)) or ""
  )
)
say("smoke: sandbox " .. home)

if opts.sync then
  say("smoke: restoring plugins from lazy-lock.json")
  local code, output = run({ "+Lazy! restore", "+qa" }, nil, 900000)
  restore_lockfile()
  if code ~= 0 then
    say(output)
    say("smoke: FAIL plugin restore exited " .. code)
    os.exit(1)
  end
  say("smoke: installing treesitter parsers" .. (opts.install and " and Mason packages" or ""))
  code, output = run(
    { "+luafile " .. repo .. "/tests/smoke/install.lua" },
    { SMOKE_MASON = opts.install and "1" or "0" },
    1800000
  )
  restore_lockfile()
  if code ~= 0 then
    say(output)
    say("smoke: FAIL install exited " .. code)
    os.exit(1)
  end
end

-- fixtures -------------------------------------------------------------------
local problem_line = { "[Ee]rror", "E%d+:", "[Dd]eprecated", "[Ww]arning", "attempt to", "stack traceback" }

local function check(fixture, result, output)
  local problems, notes = {}, {}
  local function problem(s)
    if #problems < 25 and not vim.list_contains(problems, s) then
      table.insert(problems, s)
    end
  end
  local function note(s)
    if not vim.list_contains(notes, s) then
      table.insert(notes, s)
    end
  end

  if not result then
    problem("probe did not finish; output:\n      " .. output:gsub("\n", "\n      "))
    return problems, notes
  end
  if not result.treesitter then
    problem("treesitter highlighter not active")
  end
  for _, name in ipairs(fixture.servers) do
    local status = result.lsp[name] or "fail: not checked"
    if status:match("^fail") then
      problem(("lsp %s: %s"):format(name, status))
    elseif status:match("^skip") then
      note(("lsp %s: %s"):format(name, status))
    end
  end
  for _, e in ipairs(result.errors) do
    local skipped = matches(e, allow.skips)
    if skipped then
      note(("skip: `%s` not installed"):format(skipped))
    else
      problem("error: " .. e)
    end
  end
  local allowed_groups = {} ---@type table<string, { count: integer, from: table<string, true> }>
  for _, d in ipairs(result.deprecations) do
    local allowed = not d.origin:match("^config:")
    if allowed then
      allowed = false
      for _, a in ipairs(allow.deprecations) do
        if d.name:match(a.name) and d.origin:match(a.from) then
          allowed = true
        end
      end
    end
    local msg = ("deprecated: %s%s (removal in %s %s) at %s"):format(
      d.name,
      d.alternative and (", use " .. d.alternative) or "",
      d.plugin,
      d.version or "?",
      d.origin
    )
    if allowed then
      local g = allowed_groups[d.name] or { count = 0, from = {} }
      g.count = g.count + 1
      g.from[d.origin:match("^plugin:([^:]+)") or d.origin] = true
      allowed_groups[d.name] = g
    else
      problem(msg)
    end
  end
  for name, g in vim.spairs(allowed_groups) do
    note(("allow-listed deprecated: %s x%d (%s)"):format(name, g.count, table.concat(vim.tbl_keys(g.from), ", ")))
  end
  local lines = {}
  for _, n in ipairs(result.notifications) do
    table.insert(lines, n.msg)
  end
  vim.list_extend(lines, vim.split(result.messages or "", "\n"))
  vim.list_extend(lines, vim.split(output, "\n"))
  for _, line in ipairs(lines) do
    line = vim.trim(line)
    if line ~= "" and not matches(line, allow.messages) then
      local skipped = matches(line, allow.skips)
      if skipped then
        note(("skip: `%s` not installed"):format(skipped))
      elseif matches(line, problem_line) then
        problem("message: " .. line)
      end
    end
  end
  return problems, notes
end

local work = home .. "/work"
local failed = 0
for _, fixture in ipairs(fixtures) do
  if next(opts.only) == nil or opts.only[fixture.file] then
    vim.fn.delete(work, "rf")
    vim.fn.mkdir(work, "p")
    for name in vim.fs.dir(repo .. "/tests/fixtures") do
      vim.uv.fs_copyfile(repo .. "/tests/fixtures/" .. name, work .. "/" .. name)
    end
    local out = home .. "/result.json"
    os.remove(out)
    local code, output = run({
      "--cmd",
      "luafile " .. repo .. "/tests/smoke/hooks.lua",
      "+luafile " .. repo .. "/tests/smoke/probe.lua",
    }, {
      SMOKE_FILE = work .. "/" .. fixture.file,
      SMOKE_OUT = out,
      SMOKE_SERVERS = table.concat(fixture.servers, ","),
    }, 180000)
    restore_lockfile()
    local result
    local f = io.open(out)
    if f then
      result = vim.json.decode(f:read("*a"))
      f:close()
    end
    local problems, notes = check(fixture, result, output)
    if code ~= 0 and result then
      table.insert(problems, "nvim exited with code " .. code)
    end
    local lsp = {}
    for _, name in ipairs(fixture.servers) do
      local s = result and result.lsp[name] or "?"
      table.insert(lsp, name .. "=" .. (s:match("^%a+") or s))
    end
    say(
      ("%s %-12s ft=%-10s ts=%-3s lsp: %s"):format(
        #problems == 0 and "PASS" or "FAIL",
        fixture.file,
        result and result.filetype or "?",
        result and (result.treesitter and "on" or "OFF") or "?",
        table.concat(lsp, " ")
      )
    )
    for _, p in ipairs(problems) do
      say("    ✗ " .. p)
    end
    for _, n in ipairs(notes) do
      say("    · " .. n)
    end
    if #problems > 0 then
      failed = failed + 1
    end
  end
end

restore_lockfile()
if failed > 0 then
  say(("smoke: FAIL (%d fixture(s) with problems)"):format(failed))
  os.exit(1)
end
say("smoke: OK")
os.exit(0)
