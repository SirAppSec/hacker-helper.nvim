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
    return false
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
  -- Check if luasocket is installed
  if not check_luasocket_installed() then
    return
  end
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
    "n",
    M.config.prefix .. M.config.keys.encode_prefix,
    function() end,
    { noremap = true, silent = true, desc = "Encode" }
  )
  vim.keymap.set(
    "n",
    M.config.prefix .. M.config.keys.decode_prefix,
    function() end,
    { noremap = true, silent = true, desc = "Decoder" }
  )

  -- Encoding key mappings
  vim.keymap.set("v", M.config.prefix .. M.config.keys.encode_prefix .. M.config.keys.encode_url, function()
    M.transform_selected_text("url", "encode")
  end, { noremap = true, silent = true, desc = "URL Encode" })
  vim.keymap.set("v", M.config.prefix .. M.config.keys.encode_prefix .. M.config.keys.encode_base64, function()
    M.transform_selected_text("base64", "encode")
  end, { noremap = true, silent = true, desc = "Base64 Encode" })

  -- Decoding key mappings
  vim.keymap.set("v", M.config.prefix .. M.config.keys.decode_prefix .. M.config.keys.decode_url, function()
    M.transform_selected_text("url", "decode")
  end, { noremap = true, silent = true, desc = "URL Decode" })
  vim.keymap.set("v", M.config.prefix .. M.config.keys.decode_prefix .. M.config.keys.decode_base64, function()
    M.transform_selected_text("base64", "decode")
  end, { noremap = true, silent = true, desc = "Base64 Decode" })
end
-- Function to handle encoding/decoding based on selection
M.transform_selected_text = function(type, mode)
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_line, start_col = start_pos[2], start_pos[3] - 1 -- Convert to 0-based index
  local end_line, end_col = end_pos[2], end_pos[3] - 1 -- Convert to 0-based index

  -- Get selected lines
  local lines = vim.fn.getline(start_line, end_line)

  -- If no lines were selected, return early
  if not lines or #lines == 0 then
    vim.notify("No lines selected for transformation.", vim.log.levels.ERROR)
    return
  end

  -- Handle full line selection
  if start_col == 0 and end_col == -1 then
    -- Full-line transformation
    if type == "url" then
      lines = M.transform_lines(lines, mode, "url")
    elseif type == "base64" then
      lines = M.transform_lines(lines, mode, "base64")
    end
    -- Replace all selected lines with the transformed lines
    vim.fn.setline(start_line, lines)
  else
    -- Handle partial selection within a single line
    if lines and lines[1] then
      local line = lines[1]

      -- Ensure end_col doesn't exceed line length
      local line_len = #line
      end_col = math.min(end_col, line_len)

      -- Get the selected portion
      local selection = string.sub(line, start_col + 1, end_col)

      -- If selection is nil or empty, return early
      if not selection or selection == "" then
        vim.notify("Invalid selection for transformation.", vim.log.levels.ERROR)
        return
      end

      local transformed = ""

      if type == "url" then
        transformed = M.transform_text(selection, mode, "url")
      elseif type == "base64" then
        transformed = M.transform_text(selection, mode, "base64")
      end

      -- Use `vim.api.nvim_buf_set_text` to replace the selected part
      local bufnr = vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_set_text(bufnr, start_line - 1, start_col, start_line - 1, end_col, { transformed })

      -- Optionally move cursor if you want it to behave similarly to the `c` command
      vim.api.nvim_win_set_cursor(0, { start_line, start_col + #transformed })
    else
      vim.notify("No valid line found for transformation.", vim.log.levels.ERROR)
    end
  end
end

-- Function to transform lines for full-line selection
M.transform_lines = function(lines, mode, type)
  local transformed_lines = {}
  for _, line in ipairs(lines) do
    if type == "url" then
      table.insert(transformed_lines, M.transform_text(line, mode, "url"))
    elseif type == "base64" then
      table.insert(transformed_lines, M.transform_text(line, mode, "base64"))
    end
  end
  return transformed_lines
end

-- Function to transform individual text based on type and mode
M.transform_text = function(text, mode, type)
  local mime = require("mime")
  if type == "url" then
    if mode == "encode" then
      return text:gsub("([^%w%.%-_])", function(c)
        return string.format("%%%02X", string.byte(c))
      end)
    else -- decode
      return text:gsub("%%(%x%x)", function(hex)
        return string.char(tonumber(hex, 16))
      end)
    end
  elseif type == "base64" then
    if mode == "encode" then
      return mime.b64(text)
    else -- decode
      return mime.unb64(text)
    end
  end
end

M.hello = function()
  return module.my_first_function(M.config.opt)
end

return M
