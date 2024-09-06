-- main module file
local module = require("hacker-helper.module")

---@class Config
---@field opt string Your config option
---@field keys table<string, string> Key mappings
local config = {
  prefix = "<leader>r", -- Default prefix for Hacker Helper
  keys = {
    run_exec = "e", -- Default mapping for executing in terminal
  },
  opt = "Hello!",
}

---@class MyModule
local M = {}
---@type Config
M.config = config

-- you can define your setup function here. Usually configurations can be merged, accepting outside params and
-- you can also put some validation here for those.
---@param user_config Config? User-provided configuration
M.setup = function(user_config)
  -- Merge user configuration with defaults
  M.config = vim.tbl_deep_extend("force", M.config, user_config or {})

  -- Ensure no extra spaces in the prefix and key
  local full_run_exec_mapping = vim.trim(M.config.prefix) .. vim.trim(M.config.keys.run_exec)
  -- Prefix groupname
  vim.keymap.set("n", M.config.prefix, function() end, { noremap = true, silent = true, desc = "Hacker Helper" })
  vim.keymap.set("v", M.config.prefix, function() end, { noremap = true, silent = true, desc = "Hacker Helper" })
  -- Set key mappings using vim.keymap.set, including the description
  vim.keymap.set("n", full_run_exec_mapping, function()
    module.exec_line_or_selection_in_term()
  end, { noremap = true, silent = true, desc = "Execute Command" })
  vim.keymap.set("v", full_run_exec_mapping, function()
    module.exec_line_or_selection_in_term()
  end, { noremap = true, silent = true, desc = "Execute Command" })
end

M.hello = function()
  return module.my_first_function(M.config.opt)
end

return M
