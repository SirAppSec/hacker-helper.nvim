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
    vim.notify("Hacker Helper Error: sudo apt install luarocks", vim.log.levels.ERROR)
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

---@class MyModule
local M = {}
---@type Config
M.config = config

-- you can define your setup function here. Usually configurations can be merged, accepting outside params and
-- you can also put some validation here for those.
---@param user_config Config? User-provided configuration
M.setup = function(user_config)
  -- Check if luasocket is installed
  local mime = check_luasocket_installed()
  if not mime then
    return
  end -- Ensure LuaSocket is installed
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

  -- Key mappings for encoding and decoding
  vim.keymap.set("v", M.config.prefix .. M.config.keys.encode_prefix .. M.config.keys.encode_url, function()
    M.transform_selection("url", "encode")
  end, { noremap = true, silent = true, desc = "URL Encode" })
  vim.keymap.set("v", M.config.prefix .. M.config.keys.encode_prefix .. M.config.keys.encode_base64, function()
    M.transform_selection("base64", "encode")
  end, { noremap = true, silent = true, desc = "Base64 Encode" })

  vim.keymap.set("v", M.config.prefix .. M.config.keys.decode_prefix .. M.config.keys.decode_url, function()
    M.transform_selection("url", "decode")
  end, { noremap = true, silent = true, desc = "URL Decode" })
  vim.keymap.set("v", M.config.prefix .. M.config.keys.decode_prefix .. M.config.keys.decode_base64, function()
    M.transform_selection("base64", "decode")
  end, { noremap = true, silent = true, desc = "Base64 Decode" })
end
-- Function to handle encoding/decoding based on selection
M.transform_selection = function(type, mode)
  local mime = check_luasocket_installed()
  if not mime then
    return
  end -- Ensure LuaSocket is installed

  -- Capture the selection
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")

  local start_line = start_pos[2]
  local start_col = start_pos[3] - 1 -- 0-based index

  local end_line = end_pos[2]
  local end_col = end_pos[3] -- inclusive

  -- Get selected lines
  local lines = vim.fn.getline(start_line, end_line)

  -- Handle full-line selection (V mode) and partial selection
  if vim.fn.mode() == "V" then
    -- Full line selection, transform entire lines
    for i, line in ipairs(lines) do
      lines[i] = M.transform_text(line, type, mode, mime)
    end
    -- Replace the entire range with transformed lines
    vim.fn.setline(start_line, lines)
  else
    -- Partial selection within a single line
    if start_line == end_line then
      -- Handle partial selection on a single line
      local line = lines[1]
      local selection = string.sub(line, start_col + 1, end_col)
      local transformed = M.transform_text(selection, type, mode, mime)
      local new_line = string.sub(line, 1, start_col) .. transformed .. string.sub(line, end_col + 1)
      vim.fn.setline(start_line, new_line)
    else
      -- Handle multi-line selection, applying the transformation to partial lines
      lines[1] = string.sub(lines[1], 1, start_col)
        .. M.transform_text(string.sub(lines[1], start_col + 1), type, mode, mime)
      lines[#lines] = M.transform_text(string.sub(lines[#lines], 1, end_col), type, mode, mime)
        .. string.sub(lines[#lines], end_col + 1)
      for i = 2, #lines - 1 do
        lines[i] = M.transform_text(lines[i], type, mode, mime)
      end
      -- Replace the entire range with transformed lines
      vim.fn.setline(start_line, lines)
    end
  end
end

M.transform_text = function(text, mode, type, mime)
  mime = mime or require("mime") -- Ensure LuaSocket's mime module is loaded

  if type == "url" then
    if mode == "encode" then
      return text:gsub("([^%w%.%-_])", function(c)
        return string.format("%%%02X", string.byte(c))
      end)
    elseif mode == "decode" then
      return text:gsub("%%(%x%x)", function(hex)
        return string.char(tonumber(hex, 16))
      end)
    end
  elseif type == "base64" then
    if mode == "encode" then
      local encoded = mime.b64(text) -- Use only the first return value
      return encoded
    elseif mode == "decode" then
      local decoded = mime.unb64(text) -- Use only the first return value
      return decoded
    end
  end

  return text -- return the original text if no valid type or mode is provided
end

M.hello = function()
  return module.my_first_function(M.config.opt)
end

return M
