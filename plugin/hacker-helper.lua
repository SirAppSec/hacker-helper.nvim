-- Import the HTTP to Python module
local selection_util = require("hacker-helper.selection_util")
local http_to_python = require("hacker-helper.http_to_python")
local M = require("hacker-helper")

-- script_http_to_python_form = "f",
-- script_http_to_python_json = "j",
-- script_http_to_python_body = "s",

-- Key Mappings for HTTP to Python requests
-- Scripts/snippets are under <leader>rs
vim.keymap.set(
  "v",
  M.config.prefix .. M.config.keys.script_prefix .. M.config.keys.script_http_to_python_body,
  function()
    selection_util.transform_selection(function(selection)
      local request = http_to_python.parse_http_request(selection)
      return http_to_python.generate_python_requests_script(request, "raw")
    end)
  end,
  { noremap = true, silent = true, desc = "HTTP Burp to Python Requests (body)" }
)

vim.keymap.set(
  "v",
  M.config.prefix .. M.config.keys.script_prefix .. M.config.keys.script_http_to_python_json,
  function()
    selection_util.transform_selection(function(selection)
      local request = http_to_python.parse_http_request(selection)
      return http_to_python.generate_python_requests_script(request, "json")
    end)
  end,
  { noremap = true, silent = true, desc = "HTTP Burp to Python Requests (json)" }
)

vim.keymap.set(
  "v",
  M.config.prefix .. M.config.keys.script_prefix .. M.config.keys.script_http_to_python_form,
  function()
    selection_util.transform_selection(function(selection)
      local request = http_to_python.parse_http_request(selection)
      return http_to_python.generate_python_requests_script(request, "form-data")
    end)
  end,
  { noremap = true, silent = true, desc = "HTTP Burp to Python Requests (form-data)" }
)
