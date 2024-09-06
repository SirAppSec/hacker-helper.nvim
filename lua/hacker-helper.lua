-- main module file
local module = require("hacker-helper.module")
-- Try to load mime (part of luasocket) and handle missing dependency

-- Function to check if LuaRocks is installed
local function is_luarocks_installed()
  local result = os.execute("luarocks --version > /dev/null 2>&1")
  return result == 0
end

-- Function to check and install luasocket if missing
local function ensure_luasocket_installed()
  local ok, mime = pcall(require, "mime")
  if not ok then
    -- Check if LuaRocks is installed
    if not is_luarocks_installed() then
      -- LuaRocks is not installed, notify the user
      vim.notify("Error: LuaRocks is not installed. Please install LuaRocks to use this feature.", vim.log.levels.ERROR)
      return false
    end

    -- Notify the user that we're installing LuaSocket
    vim.notify("LuaSocket not found. Installing LuaSocket (luasocket) via LuaRocks...", vim.log.levels.INFO)

    -- Run the LuaRocks install command
    local result = os.execute("luarocks install luasocket")
    if result == 0 then
      -- Installation succeeded
      vim.notify("LuaSocket successfully installed!", vim.log.levels.INFO)
      -- Reload mime module
      mime = require("mime")
    else
      -- Installation failed, notify the user
      vim.notify("Error: Failed to install LuaSocket. Please install it manually.", vim.log.levels.ERROR)
      return false
    end
  end
  return true
end

---@class Config
---@field opt string Your config option
---@field keys table<string, string> Key mappings
local config = {
  prefix = "<leader>r", -- Default prefix for Hacker Helper
  keys = {
    run_exec = "e", -- Default mapping for executing in terminal
    encode_prefix = "de", -- <leader>rde (Encode Group)
    decode_prefix = "d", -- <leader>rd (Decode Group)
    encode_url = "u", -- <leader>rdeu (URL Encode)
    decode_url = "u", -- <leader>rdu (URL Decode)
    encode_base64 = "b", -- <leader>rdeb (Base64 Encode)
    decode_base64 = "b", -- <leader>rdb (Base64 Decode)
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
  -- Check if luasocket is installed, and attempt to install it if missing
  if not ensure_luasocket_installed() then
    return
  end
  -- Merge user configuration with defaults
  M.config = vim.tbl_deep_extend("force", M.config, user_config or {})

  -- Ensure no extra spaces in the prefix and key
  local full_run_exec_mapping = vim.trim(M.config.prefix) .. vim.trim(M.config.keys.run_exec)
  -- Prefix groupname
  vim.keymap.set("n", M.config.prefix, function() end, { noremap = true, silent = true, desc = "Hacker Helper" })
  vim.keymap.set("v", M.config.prefix, function() end, { noremap = true, silent = true, desc = "Hacker Helper" })

  -- Register the group names for both encoding and decoding
  vim.keymap.set(
    "n",
    M.config.prefix .. M.config.keys.encode_prefix,
    function() end,
    { noremap = true, silent = true, desc = "Encode" }
  )
  vim.keymap.set(
    "n",
    M.config.prefix .. M.config.keys.decode_prefix,
    function() end,
    { noremap = true, silent = true, desc = "Decode" }
  )

  -- Encoding key mappings
  vim.keymap.set("v", M.config.prefix .. M.config.keys.encode_prefix .. M.config.keys.encode_url, function()
    module.encode_selected_text("url")
  end, { noremap = true, silent = true, desc = "URL Encode" })
  vim.keymap.set("v", M.config.prefix .. M.config.keys.encode_prefix .. M.config.keys.encode_base64, function()
    module.encode_selected_text("base64")
  end, { noremap = true, silent = true, desc = "Base64 Encode" })

  -- Decoding key mappings
  vim.keymap.set("v", M.config.prefix .. M.config.keys.decode_prefix .. M.config.keys.decode_url, function()
    module.decode_selected_text("url")
  end, { noremap = true, silent = true, desc = "URL Decode" })
  vim.keymap.set("v", M.config.prefix .. M.config.keys.decode_prefix .. M.config.keys.decode_base64, function()
    module.decode_selected_text("base64")
  end, { noremap = true, silent = true, desc = "Base64 Decode" })
  -- Set key mappings using vim.keymap.set, including the description
  vim.keymap.set("n", full_run_exec_mapping, function()
    module.exec_line_or_selection_in_term()
  end, { noremap = true, silent = true, desc = "Execute Command" })
  vim.keymap.set("v", full_run_exec_mapping, function()
    module.exec_line_or_selection_in_term()
  end, { noremap = true, silent = true, desc = "Execute Command" })
end
-- Function to handle encoding
M.encode_selected_text = function(type)
  -- Get the selected text in visual mode
  local start_line = vim.fn.getpos("'<")[2]
  local end_line = vim.fn.getpos("'>")[2]
  local selection = vim.fn.getline(start_line, end_line)

  -- Encode based on type
  if type == "url" then
    local encoded = vim.fn.escape(vim.fn.join(selection, "\n"), " ")
    -- URL encode special characters
    encoded = encoded:gsub("\n", ""):gsub(" ", "%%20"):gsub("([^%w%.%-_])", function(c)
      return string.format("%%%02X", string.byte(c))
    end)
    vim.fn.setline(start_line, vim.split(encoded, "\n"))
  elseif type == "base64" then
    -- Use the mime library for base64 encoding
    local encoded = mime.b64(vim.fn.join(selection, "\n"))
    vim.fn.setline(start_line, vim.split(encoded, "\n"))
  end
end

-- Function to handle decoding
M.decode_selected_text = function(type)
  -- Get the selected text in visual mode
  local start_line = vim.fn.getpos("'<")[2]
  local end_line = vim.fn.getpos("'>")[2]
  local selection = vim.fn.getline(start_line, end_line)

  -- Decode based on type
  if type == "url" then
    -- URL decode special characters
    local decoded = vim.fn.join(selection, "\n"):gsub("%%(%x%x)", function(hex)
      return string.char(tonumber(hex, 16))
    end)
    vim.fn.setline(start_line, vim.split(decoded, "\n"))
  elseif type == "base64" then
    -- Use the mime library for base64 decoding
    local decoded = mime.unb64(vim.fn.join(selection, "\n"))
    vim.fn.setline(start_line, vim.split(decoded, "\n"))
  end
end

M.hello = function()
  return module.my_first_function(M.config.opt)
end

return M
