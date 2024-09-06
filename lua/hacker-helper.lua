-- utils
local selection_util = require("hacker-helper.selection_util")

-- main module file
local module = require("hacker-helper.module")

-- Notify the user if LuaSocket is not installed
local function check_luasocket_installed()
  local ok, mime = pcall(require, "mime")
  if not ok then
    vim.notify(
      "Hacker Helper Error: LuaSocket (luasocket) is not installed. Please install it using LuaRocks: luarocks install luasocket",
      vim.log.levels.ERROR
    )
    vim.notify(
      "Hacker Helper Error: sudo apt install luarocks && sudo luarocks install luasocket",
      vim.log.levels.ERROR
    )
    return nil
  end
  return mime
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

local mime = check_luasocket_installed()
if not mime then
  return
end -- Ensure LuaSocket is installed
---@class MyModule
local M = {}
---@type Config
M.config = config

-- you can define your setup function here. Usually configurations can be merged, accepting outside params and
-- you can also put some validation here for those.
---@param user_config Config? User-provided configuration
M.setup = function(user_config)
  -- Check if luasocket is installed
  -- Merge user configuration with defaults
  M.config = vim.tbl_deep_extend("force", M.config, user_config or {})

  -- Ensure no extra spaces in the prefix and key
  local full_run_exec_mapping = vim.trim(M.config.prefix) .. vim.trim(M.config.keys.run_exec)
  -- Prefix groupname
  vim.keymap.set("n", M.config.prefix, function() end, { noremap = true, silent = true, desc = "Hacker Helper" })
  vim.keymap.set("v", M.config.prefix, function() end, { noremap = true, silent = true, desc = "Hacker Helper" })

  -- Run command
  vim.keymap.set("v", full_run_exec_mapping, function()
    module.exec_line_or_selection_in_term()
  end, { noremap = true, silent = true, desc = "Execute Command" })
  -- Register the group names for both encoding and decoding
  vim.keymap.set(
    "v",
    M.config.prefix .. M.config.keys.encode_prefix,
    function() end,
    { noremap = true, silent = true, desc = "Encode" }
  )
  vim.keymap.set(
    "v",
    M.config.prefix .. M.config.keys.decode_prefix,
    function() end,
    { noremap = true, silent = true, desc = "Decoder" }
  )

  -- Key mappings for Base64 and URL encoding/decoding using config prefixes

  -- Base64 Encode
  vim.keymap.set("v", M.config.prefix .. M.config.keys.encode_prefix .. M.config.keys.encode_base64, function()
    selection_util.transform_selection(function(text, selection_type)
      return M.transform_func(text, selection_type, "encode", "base64")
    end)
  end, { noremap = true, silent = true, desc = "Base64 Encode" })

  -- Base64 Decode
  vim.keymap.set("v", M.config.prefix .. M.config.keys.decode_prefix .. M.config.keys.decode_base64, function()
    selection_util.transform_selection(function(text, selection_type)
      return M.transform_func(text, selection_type, "decode", "base64")
    end)
  end, { noremap = true, silent = true, desc = "Base64 Decode" })

  -- URL Encode
  vim.keymap.set("v", M.config.prefix .. M.config.keys.encode_prefix .. M.config.keys.encode_url, function()
    selection_util.transform_selection(function(text, selection_type)
      return M.transform_func(text, selection_type, "encode", "url")
    end)
  end, { noremap = true, silent = true, desc = "URL Encode" })

  -- URL Decode
  vim.keymap.set("v", M.config.prefix .. M.config.keys.decode_prefix .. M.config.keys.decode_url, function()
    selection_util.transform_selection(function(text, selection_type)
      return M.transform_func(text, selection_type, "decode", "url")
    end)
  end, { noremap = true, silent = true, desc = "URL Decode" })
end
-- Function to handle encoding/decoding based on selection
-- Base64 encoding and decoding utility functions
M.base64_encode = function(text)
  return mime.b64(text)
end

M.base64_decode = function(text)
  return mime.unb64(text)
end

-- URL encoding and decoding utility functions
M.url_encode = function(text)
  return text:gsub("([^%w%.%-_])", function(c)
    return string.format("%%%02X", string.byte(c))
  end)
end

M.url_decode = function(text)
  return text:gsub("%%(%x%x)", function(hex)
    return string.char(tonumber(hex, 16))
  end)
end

-- Transform function for encoding or decoding text based on type and selection type
M.transform_func = function(text, selection_type, encode_or_decode, encoding_type)
  if encoding_type == "base64" then
    if encode_or_decode == "encode" then
      return M.base64_encode(text)
    elseif encode_or_decode == "decode" then
      return M.base64_decode(text)
    end
  elseif encoding_type == "url" then
    if encode_or_decode == "encode" then
      return M.url_encode(text)
    elseif encode_or_decode == "decode" then
      return M.url_decode(text)
    end
  end
  return text
end

M.hello = function()
  return module.my_first_function(M.config.opt)
end

return M
