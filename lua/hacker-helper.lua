-- utils
local selection_util = require("hacker-helper.selection_util")

-- main module file
local module = require("hacker-helper.module")
-- Generalized function to check if a Lua module is installed
local function check_dependency(module_name, package_name)
  local ok, sub_module = pcall(require, module_name)
  if not ok then
    vim.notify(
      string.format(
        "Hacker Helper Error: %s (%s) is not installed. Please install it using LuaRocks: luarocks install %s",
        module_name,
        package_name,
        package_name
      ),
      vim.log.levels.ERROR
    )
    vim.notify(
      string.format("Hacker Helper Error: sudo apt install luarocks && sudo luarocks install %s", package_name),
      vim.log.levels.ERROR
    )
    return nil
  end
  return sub_module
end
local function check_dependencies()
  local mime = check_dependency("mime", "luasocket")
  if not mime then
    return nil
  end

  local zlib = check_dependency("zlib", "lua-zlib")
  if not zlib then
    return nil
  end

  local bit = check_dependency("bit", "luabitop")
  if not zlib then
    return nil
  end

  -- Return both dependencies if available
  return {
    mime = mime,
    zlib = zlib,
    bit = bit,
  }
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
    hash_prefix = "c", -- <leader>rc (Hash Group)

    decode_url = "u", -- <leader>rdu (URL Decode)
    encode_base64 = "b", -- <leader>rdeb (Base64 Encode)
    decode_base64 = "b", -- <leader>rdb (Base64 Decode)
    encode_html = "h", -- <leader>rdeh (HTML Encode)
    decode_html = "h", -- <leader>rdh (HTML Decode)
    encode_ascii_hex = "x", -- <leader>rdex (ASCII Hex Encode)
    decode_ascii_hex = "x", -- <leader>rdx (ASCII Hex Decode)
    encode_gzip = "g", -- <leader>rdeg (Gzip Encode)
    decode_gzip = "g", -- <leader>rdg (Gzip Decode)
    encode_binary = "i", -- <leader>rdei (Binary Encode)
    decode_binary = "i", -- <leader>rdi (Binary Decode)
    encode_octal = "o", -- <leader>rdeo (Octal Encode)
    decode_octal = "o", -- <leader>rdo (Octal Decode)
    hash_md5 = "m", -- <leader>rcm (MD5 Hash)
    hash_sha1 = "s", -- <leader>rcs (SHA-1 Hash)
    hash_sha256 = "S", -- <leader>rcS (SHA-256 Hash)
    hash_crc32 = "c", -- <leader>rcC (CRC32 Hash)
    hash_scrypt = "y", -- <leader>rcy (Scrypt Hash)
    hash_bcrypt = "b", -- <leader>rcb (Bcrypt Hash)
  },
  opt = "Hello!",
}

-- Call this function before plugin setup to ensure all dependencies are installed
local deps = check_dependencies()
if not deps then
  return
end
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

  vim.keymap.set(
    "v",
    M.config.prefix .. M.config.keys.hash_prefix,
    function() end,
    { noremap = true, silent = true, desc = "Hash" }
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
-- HTML Encode
vim.keymap.set("v", M.config.prefix .. M.config.keys.encode_prefix .. M.config.keys.encode_html, function()
  selection_util.transform_selection(function(text, selection_type)
    return M.transform_func(text, selection_type, "encode", "html")
  end)
end, { noremap = true, silent = true, desc = "HTML Encode" })

-- HTML Decode
vim.keymap.set("v", M.config.prefix .. M.config.keys.decode_prefix .. M.config.keys.decode_html, function()
  selection_util.transform_selection(function(text, selection_type)
    return M.transform_func(text, selection_type, "decode", "html")
  end)
end, { noremap = true, silent = true, desc = "HTML Decode" })

-- ASCII Hex Encode
vim.keymap.set("v", M.config.prefix .. M.config.keys.encode_prefix .. M.config.keys.encode_ascii_hex, function()
  selection_util.transform_selection(function(text, selection_type)
    return M.transform_func(text, selection_type, "encode", "ascii_hex")
  end)
end, { noremap = true, silent = true, desc = "ASCII Hex Encode" })

-- ASCII Hex Decode
vim.keymap.set("v", M.config.prefix .. M.config.keys.decode_prefix .. M.config.keys.decode_ascii_hex, function()
  selection_util.transform_selection(function(text, selection_type)
    return M.transform_func(text, selection_type, "decode", "ascii_hex")
  end)
end, { noremap = true, silent = true, desc = "ASCII Hex Decode" })

-- Gzip Encode
vim.keymap.set("v", M.config.prefix .. M.config.keys.encode_prefix .. M.config.keys.encode_gzip, function()
  selection_util.transform_selection(function(text, selection_type)
    return M.transform_func(text, selection_type, "encode", "gzip")
  end)
end, { noremap = true, silent = true, desc = "Gzip Encode" })

-- Gzip Decode
vim.keymap.set("v", M.config.prefix .. M.config.keys.decode_prefix .. M.config.keys.decode_gzip, function()
  selection_util.transform_selection(function(text, selection_type)
    return M.transform_func(text, selection_type, "decode", "gzip")
  end)
end, { noremap = true, silent = true, desc = "Gzip Decode" })

-- Binary Encode
vim.keymap.set("v", M.config.prefix .. M.config.keys.encode_prefix .. M.config.keys.encode_binary, function()
  selection_util.transform_selection(function(text, selection_type)
    return M.transform_func(text, selection_type, "encode", "binary")
  end)
end, { noremap = true, silent = true, desc = "Binary Encode" })

-- Binary Decode
vim.keymap.set("v", M.config.prefix .. M.config.keys.decode_prefix .. M.config.keys.decode_binary, function()
  selection_util.transform_selection(function(text, selection_type)
    return M.transform_func(text, selection_type, "decode", "binary")
  end)
end, { noremap = true, silent = true, desc = "Binary Decode" })

-- Octal Encode
vim.keymap.set("v", M.config.prefix .. M.config.keys.encode_prefix .. M.config.keys.encode_octal, function()
  selection_util.transform_selection(function(text, selection_type)
    return M.transform_func(text, selection_type, "encode", "octal")
  end)
end, { noremap = true, silent = true, desc = "Octal Encode" })

-- Octal Decode
vim.keymap.set("v", M.config.prefix .. M.config.keys.decode_prefix .. M.config.keys.decode_octal, function()
  selection_util.transform_selection(function(text, selection_type)
    return M.transform_func(text, selection_type, "decode", "octal")
  end)
end, { noremap = true, silent = true, desc = "Octal Decode" })

-- MD5 Hash
vim.keymap.set("v", M.config.prefix .. M.config.keys.hash_prefix .. M.config.keys.hash_md5, function()
  selection_util.hash_selection(function(text)
    return M.hash_text(text, "md5")
  end) -- Passing "hash" as the mode and "md5" as the encoding type
end, { noremap = true, silent = true, desc = "MD5 Hash" })

-- SHA-1 Hash
vim.keymap.set("v", M.config.prefix .. M.config.keys.hash_prefix .. M.config.keys.hash_sha1, function()
  selection_util.hash_selection(function(text)
    return M.hash_text(text, "sha1")
  end) -- Mode: "hash", Encoding: "sha1"
end, { noremap = true, silent = true, desc = "SHA-1 Hash" })

-- SHA-256 Hash
vim.keymap.set("v", M.config.prefix .. M.config.keys.hash_prefix .. M.config.keys.hash_sha256, function()
  selection_util.hash_selection(function(text)
    return M.hash_text(text, "sha256")
  end) -- Mode: "hash", Encoding: "sha256"
end, { noremap = true, silent = true, desc = "SHA-256 Hash" })

-- CRC32 Hash
vim.keymap.set("v", M.config.prefix .. M.config.keys.hash_prefix .. M.config.keys.hash_crc32, function()
  selection_util.hash_selection(function(text)
    return M.hash_text(text, "crc32")
  end) -- Mode: "hash", Encoding: "crc32"
end, { noremap = true, silent = true, desc = "CRC32 Hash" })

-- Bcrypt Hash
vim.keymap.set("v", M.config.prefix .. M.config.keys.hash_prefix .. M.config.keys.hash_bcrypt, function()
  selection_util.hash_selection(function(text)
    return M.hash_text(text, "bcrypt")
  end) -- Mode: "hash", Encoding: "bcrypt"
end, { noremap = true, silent = true, desc = "Bcrypt Hash" })

-- Scrypt Hash
vim.keymap.set("v", M.config.prefix .. M.config.keys.hash_prefix .. M.config.keys.hash_scrypt, function()
  selection_util.hash_selection(function(text)
    return M.hash_text(text, "scrypt")
  end) -- Mode: "hash", Encoding: "scrypt"
end, { noremap = true, silent = true, desc = "Scrypt Hash" })

-- Function to handle encoding/decoding based on selection
-- Base64 encoding and decoding utility functions
M.base64_encode = function(text)
  local mime = require("mime")

  return mime.b64(text)
end

M.base64_decode = function(text)
  local mime = require("mime")
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

-- HTML Encoding/Decoding Utility Functions
M.html_encode = function(text)
  return text:gsub("[<>&\"']", {
    ["<"] = "&lt;",
    [">"] = "&gt;",
    ["&"] = "&amp;",
    ['"'] = "&quot;",
    ["'"] = "&#039;",
  })
end

M.html_decode = function(text)
  return text:gsub("&lt;", "<"):gsub("&gt;", ">"):gsub("&amp;", "&"):gsub("&quot;", '"'):gsub("&#039;", "'")
end

-- ASCII Hex Encoding/Decoding Utility Functions
M.ascii_hex_encode = function(text)
  return (text:gsub(".", function(c)
    return string.format("\\x%02X", string.byte(c))
  end))
end

M.ascii_hex_decode = function(text)
  return (text:gsub("\\x(%x%x)", function(hex)
    return string.char(tonumber(hex, 16))
  end))
end

-- Gzip Encode function
M.gzip_encode = function(text)
  local zlib = require("zlib")
  local deflate_stream = zlib.deflate()
  local compressed, eof, bytes_in, bytes_out = deflate_stream(text, "finish")
  return compressed
end

-- Gzip Decode function
M.gzip_decode = function(compressed)
  local zlib = require("zlib")
  local inflate_stream = zlib.inflate()
  local decompressed, eof, bytes_in, bytes_out = inflate_stream(compressed)
  return decompressed
end

-- Binary Encoding (compatible with LuaJIT using bit library)
M.binary_encode = function(text)
  local bit = require("bit")

  return (
    text:gsub(".", function(c)
      local byte = string.byte(c)
      local binary = ""
      for i = 7, 0, -1 do
        binary = binary .. bit.band(bit.rshift(byte, i), 1) -- Using bit.rshift and bit.band
      end
      return binary
    end)
  )
end

-- Binary Decoding (compatible with LuaJIT using bit library)
M.binary_decode = function(text)
  local bit = require("bit")

  return (text:gsub("%d%d%d%d%d%d%d%d", function(bin)
    return string.char(tonumber(bin, 2))
  end))
end

M.octal_encode = function(text)
  return text:gsub(".", function(char)
    return string.format("\\%03o", string.byte(char))
  end)
end

M.octal_decode = function(text)
  return text:gsub("\\(%d%d%d)", function(octal)
    return string.char(tonumber(octal, 8))
  end)
end

M.transform_func = function(text, selection_type, encode_or_decode, encoding_type)
  -- Helper function for invalid operation
  local function invalid_operation()
    vim.notify("Hacker Helper: Invalid operation for " .. encoding_type, vim.log.levels.ERROR)
    return text
  end

  -- Encoding functions
  if encode_or_decode == "encode" then
    if encoding_type == "base64" then
      return M.base64_encode(text)
    elseif encoding_type == "url" then
      return M.url_encode(text)
    elseif encoding_type == "html" then
      return M.html_encode(text)
    elseif encoding_type == "ascii_hex" then
      return M.ascii_hex_encode(text)
    elseif encoding_type == "gzip" then
      return M.gzip_encode(text)
    elseif encoding_type == "binary" then
      return M.binary_encode(text)
    elseif encoding_type == "octal" then
      return M.octal_encode(text)
    else
      return invalid_operation()
    end

    -- Decoding functions
  elseif encode_or_decode == "decode" then
    if encoding_type == "base64" then
      return M.base64_decode(text)
    elseif encoding_type == "url" then
      return M.url_decode(text)
    elseif encoding_type == "html" then
      return M.html_decode(text)
    elseif encoding_type == "ascii_hex" then
      return M.ascii_hex_decode(text)
    elseif encoding_type == "gzip" then
      return M.gzip_decode(text)
    elseif encoding_type == "binary" then
      return M.binary_decode(text)
    elseif encoding_type == "octal" then
      return M.octal_decode(text)
    else
      return invalid_operation()
    end

    -- Hashing functions
  elseif encode_or_decode == "hash" then
    -- Use the M.hash_text function for hashing algorithms
    return M.hash_text(text, encoding_type)

    -- If an unsupported encode_or_decode operation is requested
  else
    return invalid_operation()
  end
end

M.hash_text = function(text, algorithm)
  local python_cmd = ""

  -- Define Python commands for each hashing algorithm
  if algorithm == "md5" then
    python_cmd = string.format("python3 -c 'import hashlib; print(hashlib.md5(\"%s\".encode()).hexdigest())'", text)
  elseif algorithm == "sha1" then
    python_cmd = string.format("python3 -c 'import hashlib; print(hashlib.sha1(\"%s\".encode()).hexdigest())'", text)
  elseif algorithm == "sha256" then
    python_cmd = string.format("python3 -c 'import hashlib; print(hashlib.sha256(\"%s\".encode()).hexdigest())'", text)
  elseif algorithm == "bcrypt" then
    python_cmd = string.format(
      "python3 -c 'import bcrypt; print(bcrypt.hashpw(\"%s\".encode(), bcrypt.gensalt()).decode())'",
      text
    )
  elseif algorithm == "crc32" then
    python_cmd =
      string.format('python3 -c \'import binascii; print(format(binascii.crc32(b"%s") & 0xffffffff, "08x"))\'', text)
  elseif algorithm == "scrypt" then
    python_cmd = string.format(
      'python3 -c \'import hashlib; print(hashlib.scrypt("%s".encode(), salt=b"", n=16384, r=8, p=1, dklen=64).hex())\'',
      text
    )
  else
    vim.notify("Hacker Helper: unsupported algorithm " .. algorithm, vim.log.levels.ERROR)
  end

  -- Execute the Python command and capture the output
  local handle = io.popen(python_cmd)
  if handle then
    local result = handle:read("*a")
    handle:close()
    -- Remove trailing newlines from the result
    return result:gsub("%s+", "")
  else
    vim.notify("Hacker Helper: Python dependencies for hashing are missing", vim.log.levels.ERROR)
  end
end

M.hello = function()
  return module.my_first_function(M.config.opt)
end

return M
