local M = {}

-- Utility function to convert request body to dictionary format (if applicable)
-- Utility function to convert URL-encoded form-data into a Python dictionary format
M.convert_to_dict = function(body)
  local dict_body = {}

  -- For each key-value pair in the form-data
  for line in body:gmatch("[^&]+") do
    local key, value = line:match("([^=]+)=([^=]+)")
    if key and value then
      -- Decode URL-encoded keys and values
      key = vim.fn.system("python3 -c 'import urllib.parse; print(urllib.parse.unquote(\"" .. key .. '"), end="")\'')
      value =
        vim.fn.system("python3 -c 'import urllib.parse; print(urllib.parse.unquote(\"" .. value .. '"), end="")\'')

      -- Remove trailing newlines from python output
      key = key:gsub("%s+$", "")
      value = value:gsub("%s+$", "")

      -- Insert the key-value pair into the dictionary, using Python dictionary format
      table.insert(dict_body, string.format('"%s": "%s"', key, value))
    else
      -- If it can't be parsed, return as raw string
      return nil
    end
  end

  -- Join the key-value pairs as a proper Python dictionary string
  return "{ " .. table.concat(dict_body, ", ") .. " }"
end

-- Utility function to URL-encode form-data
M.convert_to_form_data = function(body)
  local encoded_data = {}

  -- Assuming body is already in a dictionary-like structure
  for key, value in pairs(body) do
    table.insert(encoded_data, string.format("%s=%s", key, value))
  end

  return table.concat(encoded_data, "&")
end

-- Custom function to capture the visual selection for HTTP to Python conversion and replace the selected lines
M.capture_http_selection = function(transform_func)
  -- Reselect the current visual block to ensure the latest selection is active
  vim.cmd("normal! gv")

  -- Get the visual selection range using visual marks
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")

  -- Get the selected lines as a list of lines
  local start_line = math.min(start_pos[2], end_pos[2])
  local end_line = math.max(start_pos[2], end_pos[2])
  local selection = vim.fn.getline(start_line, end_line)

  -- Remove trailing ^M characters from each line (if they exist)
  for i, line in ipairs(selection) do
    selection[i] = line:gsub("\r$", "") -- Handle ^M
  end

  -- Apply the transform function to the selection (HTTP to Python)
  local transformed = transform_func(selection)

  -- Split the transformed string into individual lines
  local transformed_lines = vim.split(transformed, "\n")

  -- Replace the selected lines with the transformed Python script
  vim.fn.setline(start_line, transformed_lines)

  -- If more lines were selected than the transformed output, delete extra lines
  if end_line > start_line + #transformed_lines - 1 then
    vim.fn.deletebufline("%", start_line + #transformed_lines, end_line)
  end
end

-- Function to parse the HTTP request from the selected lines
M.parse_http_request = function(selection)
  local request = {
    method = nil,
    url = nil,
    headers = {},
    cookies = {},
    body = nil,
  }

  -- Loop through each line to detect method, headers, and body
  local in_headers = true
  for _, line in ipairs(selection) do
    -- Detect HTTP Method and URL (e.g., GET /path HTTP/1.1)
    if line:match("^%a+ /") then
      local method, url = line:match("^(%a+) (.-) HTTP")
      request.method = method
      request.url = url
    elseif in_headers and line:find(": ") then
      -- Parse Headers
      local key, value = line:match("^(.-): (.*)$")
      if key:lower() == "cookie" then
        -- Parse cookies separately
        for cookie in value:gmatch("([^;]+)") do
          local name, val = cookie:match("([^=]+)=([^;]+)")
          if name and val then
            request.cookies[name:gsub("^%s+", "")] = val -- Trim leading spaces
          end
        end
      else
        request.headers[key] = value
      end
    elseif line == "" then
      -- End of headers
      in_headers = false
    elseif not in_headers then
      -- Body (if any)
      request.body = request.body and (request.body .. "\n" .. line) or line
    end
  end

  return request
end

-- Function to convert the parsed HTTP request to Python requests code
M.generate_python_requests_script = function(request, body_type)
  -- Construct base Python script
  local python_code = "import requests\n\n"
  python_code = python_code .. string.format('url = "%s"\n', request.url)

  -- Handle headers
  python_code = python_code .. "headers = {\n"
  for key, value in pairs(request.headers) do
    python_code = python_code .. string.format('    "%s": "%s",\n', key, value)
  end
  python_code = python_code .. "}\n\n"

  -- Handle cookies
  python_code = python_code .. "cookies = {\n"
  for key, value in pairs(request.cookies) do
    python_code = python_code .. string.format('    "%s": "%s",\n', key, value)
  end
  python_code = python_code .. "}\n\n"

  -- Add commented-out proxy configuration
  python_code = python_code .. "# Uncomment the following lines to use Burp Proxy\n"
  python_code = python_code .. "# proxies = {\n"
  python_code = python_code .. '#     "http": "http://127.0.0.1:8080",\n'
  python_code = python_code .. '#     "https": "http://127.0.0.1:8080",\n'
  python_code = python_code .. "# }\n\n"

  -- Handle body based on type
  if body_type == "raw" then
    python_code = python_code
      .. string.format(
        'response = requests.%s(url, headers=headers, cookies=cookies, data=r"""%s""")\n',
        request.method:lower(),
        request.body
      )
  elseif body_type == "json" then
    python_code = python_code .. string.format("json_body = %s\n", request.body) -- Make sure this is valid JSON
    python_code = python_code
      .. string.format(
        "response = requests.%s(url, headers=headers, cookies=cookies, json=json_body)\n",
        request.method:lower()
      )
  elseif body_type == "form-data" then
    local decoded_body = M.convert_to_dict(request.body)
    python_code = python_code .. string.format("form_data = %s\n", vim.inspect(decoded_body))
    python_code = python_code
      .. string.format(
        "response = requests.%s(url, headers=headers, cookies=cookies, data=form_data)\n",
        request.method:lower()
      )
  end

  -- Add optional proxy configuration to the request
  python_code = python_code .. "# Add 'proxies=proxies' to use the proxy\n"

  -- Response handling: Status code, JSON parsing, and response content
  python_code = python_code
    .. [[
# Response handling
print("Status Code:", response.status_code)

# Attempt to parse JSON response
try:
    json_response = response.json()
    print("JSON Response:", json_response)
except ValueError:
    print("Response is not JSON, displaying text response:")
    print(response.text)
]]

  return python_code
end

return M
