-- main module file
local module = require("hacker-helper.module")
-- Add LuaRocks paths dynamically
local function add_luarocks_path()
  local handle = io.popen("luarocks path --lr-path")
  local luarocks_path = handle:read("*a")
  handle:close()

  local handle_cpath = io.popen("luarocks path --lr-cpath")
  local luarocks_cpath = handle_cpath:read("*a")
  handle_cpath:close()

  -- Add LuaRocks paths
  if not string.find(package.path, luarocks_path, 1, true) then
    package.path = package.path .. ";" .. luarocks_path
  end

  if not string.find(package.cpath, luarocks_cpath, 1, true) then
    package.cpath = package.cpath .. ";" .. luarocks_cpath
  end
end

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
      vim.notify(
        "Hacker Helper Error: LuaRocks is not installed. Please install LuaRocks to use this feature.",
        vim.log.levels.ERROR
      )
      vim.notify("Hacker Helper Error: sudo apt install luarocks", vim.log.levels.ERROR)
      return false
    end

    -- Notify the user that we're installing LuaSocket
    vim.notify("LuaSocket not found. Installing LuaSocket (luasocket) via LuaRocks...", vim.log.levels.INFO)

    -- Run the LuaRocks install command
    local result = os.execute("luarocks install luasocket")
    if result == 0 then
      -- Installation succeeded
      vim.notify("LuaSocket successfully installed!", vim.log.levels.INFO)

      -- Add LuaRocks paths dynamically
      add_luarocks_path()

      -- Reload mime module
      local mime_ok, mime_new = pcall(require, "mime")
      if not mime_ok then
        vim.notify("Error: LuaSocket installed but mime module still not found.", vim.log.levels.ERROR)
        return false
      else
        mime = mime_new
      end
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
    M.encode_selected_text("url")
  end, { noremap = true, silent = true, desc = "URL Encode" })
  vim.keymap.set("v", M.config.prefix .. M.config.keys.encode_prefix .. M.config.keys.encode_base64, function()
    M.encode_selected_text("base64")
  end, { noremap = true, silent = true, desc = "Base64 Encode" })

  -- Decoding key mappings
  vim.keymap.set("v", M.config.prefix .. M.config.keys.decode_prefix .. M.config.keys.decode_url, function()
    M.decode_selected_text("url")
  end, { noremap = true, silent = true, desc = "URL Decode" })
  vim.keymap.set("v", M.config.prefix .. M.config.keys.decode_prefix .. M.config.keys.decode_base64, function()
    M.decode_selected_text("base64")
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
  local start_line = vim.fn.getpos("'<")[2]
  local end_line = vim.fn.getpos("'>")[2]
  local selection = vim.fn.getline(start_line, end_line)

  if type == "url" then
    local encoded = vim.fn.escape(vim.fn.join(selection, "\n"), " ")
    encoded = encoded:gsub("\n", ""):gsub(" ", "%%20"):gsub("([^%w%.%-_])", function(c)
      return string.format("%%%02X", string.byte(c))
    end)
    -- If encoded has multiple lines, set them
    local lines = vim.split(encoded, "\n")
    if #lines == 1 then
      vim.fn.setline(start_line, lines[1])
    else
      vim.fn.setline(start_line, lines)
    end
  elseif type == "base64" then
    local encoded = mime.b64(vim.fn.join(selection, "\n"))
    local lines = vim.split(encoded, "\n")
    if #lines == 1 then
      vim.fn.setline(start_line, lines[1])
    else
      vim.fn.setline(start_line, lines)
    end
  end
end

-- Function to handle decoding
M.decode_selected_text = function(type)
  local start_line = vim.fn.getpos("'<")[2]
  local end_line = vim.fn.getpos("'>")[2]
  local selection = vim.fn.getline(start_line, end_line)

  if type == "url" then
    local decoded = vim.fn.join(selection, "\n"):gsub("%%(%x%x)", function(hex)
      return string.char(tonumber(hex, 16))
    end)
    local lines = vim.split(decoded, "\n")
    if #lines == 1 then
      vim.fn.setline(start_line, lines[1])
    else
      vim.fn.setline(start_line, lines)
    end
  elseif type == "base64" then
    local decoded = mime.unb64(vim.fn.join(selection, "\n"))
    local lines = vim.split(decoded, "\n")
    if #lines == 1 then
      vim.fn.setline(start_line, lines[1])
    else
      vim.fn.setline(start_line, lines)
    end
  end
end

M.hello = function()
  return module.my_first_function(M.config.opt)
end

return M
