local M = {}

---Greet someone.
---@param name string
---@return string
function M.greet(name)
  vim.cmd([[echo "greeting"]])
  return "hello " .. name
end

return M
