local M = {}

-- Utility function to detect and parse an HTTP request from the selection
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
    if line:match("^%a+ /") then
      -- HTTP Method and URL (e.g., GET /path HTTP/1.1)
      local method, url = line:match("^(%a+) (.-) HTTP")
      request.method = method
      request.url = url
    elseif in_headers and line:find(": ") then
      -- Headers
      local key, value = line:match("^(.-): (.*)$")
      if key:lower() == "cookie" then
        -- Parse cookies separately
        for cookie in value:gmatch("([^;]+)") do
          local name, val = cookie:match("([^=]+)=([^;]+)")
          if name and val then
            request.cookies[name:gsub("^%s+", "")] = val -- Trim leading spaces from cookie names
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

-- Utility function to convert request body to dictionary format (if applicable)
M.convert_to_dict = function(body)
  local dict_body = {}

  for line in body:gmatch("[^&]+") do
    local key, value = line:match("([^=]+)=([^=]+)")
    if key and value then
      dict_body[key] = value
    else
      -- If it can't be parsed, return as raw string
      return nil
    end
  end

  return dict_body
end

-- Function to convert HTTP request to Python 'requests' code
M.generate_python_requests_script = function(request, body_type)
  -- Construct base Python script
  local python_code = "import requests\n\n"
  python_code = python_code .. string.format('url = "%s"\n\n', request.url)

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
    python_code = python_code .. string.format("json_body = %s\n", request.body) -- Ensure valid JSON format
    python_code = python_code
      .. string.format(
        "response = requests.%s(url, headers=headers, cookies=cookies, json=json_body)\n",
        request.method:lower()
      )
  elseif body_type == "form-data" then
    -- URL-encode the form-data
    local encoded_form_data = M.convert_to_form_data(request.body)
    python_code = python_code
      .. string.format(
        'response = requests.%s(url, headers=headers, cookies=cookies, data="%s")\n',
        request.method:lower(),
        encoded_form_data
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

-- Utility function to URL-encode form-data
M.convert_to_form_data = function(body)
  local encoded_data = {}

  -- Assuming body is already in a dictionary-like structure
  for key, value in pairs(body) do
    table.insert(encoded_data, string.format("%s=%s", key, value))
  end

  return table.concat(encoded_data, "&")
end

return M
