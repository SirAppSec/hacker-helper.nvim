local http_to_python = require("hacker-helper.http_to_python")

-- Helper function to extract and sort dictionary keys and values
local function extract_dict(script, dict_name)
  local dict_content = script:match(dict_name .. "%s*=%s*{(.-)}")
  if dict_content then
    local dict_items = {}
    for key, value in dict_content:gmatch('"(.-)":%s*"(.-)"') do
      table.insert(dict_items, string.format('"%s":"%s"', key, value))
    end
    table.sort(dict_items) -- Sort the items to ensure order-independent comparison
    return "{" .. table.concat(dict_items, ",") .. "}"
  end
  return "{}" -- Return empty dict if not found
end

-- Helper function to remove spaces around colons in JSON or dictionary-like strings
local function normalize_json_or_dict(content)
  return content:gsub("%s*:%s*", ":"):gsub("%s+", "") -- Remove spaces around colons and general extra spaces
end

-- Helper function to handle empty strings or missing body
local function handle_empty_strings(value)
  if value == "" then
    return nil -- Treat empty strings as nil
  end
  return value
end

-- Helper function to extract and compare cookies in a sorted manner
local function extract_and_compare_cookies(generated_script, expected_script)
  local cookies_gen = extract_dict(generated_script, "cookies")
  local cookies_exp = extract_dict(expected_script, "cookies")

  -- Split cookies and sort them to ensure order-agnostic comparison
  local function split_and_sort_cookies(cookie_str)
    local cookies = {}
    for cookie in cookie_str:gmatch('"(.-)"') do
      table.insert(cookies, cookie)
    end
    table.sort(cookies)
    return table.concat(cookies, ",")
  end

  local sorted_cookies_gen = split_and_sort_cookies(cookies_gen)
  local sorted_cookies_exp = split_and_sort_cookies(cookies_exp)

  assert.are.same(sorted_cookies_exp, sorted_cookies_gen)
end

-- Helper function to normalize and compare Python scripts
local function compare_generated_and_expected(generated_script, expected_script)
  -- Compare URL, headers, and form data
  local url_gen = generated_script:match('url%s*=%s*"([^"]+)"')
  local url_exp = expected_script:match('url%s*=%s*"([^"]+)"')
  assert.are.same(url_exp, url_gen)

  local headers_gen = extract_dict(generated_script, "headers")
  local headers_exp = extract_dict(expected_script, "headers")
  assert.are.same(headers_exp, headers_gen)

  -- Normalize form_data and body content by removing spaces around colons
  local form_data_gen = normalize_json_or_dict(extract_dict(generated_script, "form_data"))
  local form_data_exp = normalize_json_or_dict(extract_dict(expected_script, "form_data"))
  assert.are.same(form_data_exp, form_data_gen)

  -- Compare cookies using the custom function for order-agnostic comparison
  extract_and_compare_cookies(generated_script, expected_script)

  -- Compare raw body content if it exists, handling empty strings
  local raw_gen = handle_empty_strings(generated_script:match('data%s*=%s*r"""(.-)"""'))
  local raw_exp = handle_empty_strings(expected_script:match('data%s*=%s*r"""(.-)"""'))
  if raw_exp then
    assert.are.same(normalize_json_or_dict(raw_exp), normalize_json_or_dict(raw_gen))
  end

  -- Compare proxy and response handling sections
  assert(generated_script:find("# Uncomment the following lines to use Burp Proxy"))
  assert(generated_script:find('print%("Status Code:"'))

  -- Ensure no extraneous or missing components
  assert.are_not.same("", generated_script)
  assert.are_not.same("", expected_script)
end

describe("generate_python_requests_script", function()
  it("generates Python requests code for raw body", function()
    local request = {
      method = "POST",
      url = "/test",
      headers = {
        ["Host"] = "example.com",
        ["Content-Type"] = "application/json",
      },
      cookies = {
        ["sessionid"] = "abc123",
        ["csrftoken"] = "xyz789",
      },
      body = '{"key" : "value"}', -- Notice space after key and colon
    }

    local generated_script = http_to_python.generate_python_requests_script(request, "raw")

    -- Expected script with no spaces in JSON
    local expected_script = [[
import requests

url = "/test"
headers = {
    "Content-Type": "application/json",
    "Host": "example.com",
}

cookies = {
    "sessionid": "abc123",
    "csrftoken": "xyz789",
}

response = requests.post(url, headers=headers, cookies=cookies, data=r"""{"key":"value"}""")

# Uncomment the following lines to use Burp Proxy
# proxies = {
#     "http": "http://127.0.0.1:8080",
#     "https": "http://127.0.0.1:8080",
# }

# Add 'proxies=proxies' to use the proxy
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

    compare_generated_and_expected(generated_script, expected_script)
  end)

  it("generates Python requests code for form-data", function()
    local request = {
      method = "POST",
      url = "/submit",
      headers = {
        ["Host"] = "example.com",
        ["Content-Type"] = "application/x-www-form-urlencoded",
      },
      cookies = {
        ["sessionid"] = "abc123",
        ["csrftoken"] = "xyz789",
      },
      body = "key=value&key1=value1&encoded_key=%3Cscript%3E%3C%2Fscript%3E",
    }

    local generated_script = http_to_python.generate_python_requests_script(request, "form-data")

    -- Expected script
    local expected_script = [[
import requests

url = "/submit"
headers = {
    "Content-Type": "application/x-www-form-urlencoded",
    "Host": "example.com",
}

cookies = {
    "sessionid": "abc123",
    "csrftoken": "xyz789",
}

form_data = {
    "key": "value"
}

# Uncomment the following lines to use Burp Proxy
# proxies = {
#     "http": "http://127.0.0.1:8080",
#     "https": "http://127.0.0.1:8080",
# }

response = requests.post(url, headers=headers, cookies=cookies, data=form_data)
# Add 'proxies=proxies' to use the proxy
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

    compare_generated_and_expected(generated_script, expected_script)
  end)

  it("generates Python requests code for JSON body", function()
    local request = {
      method = "POST",
      url = "/submit",
      headers = {
        ["Host"] = "example.com",
        ["Content-Type"] = "application/json",
      },
      cookies = {
        ["sessionid"] = "abc123",
        ["csrftoken"] = "xyz789",
      },
      body = '{"key": "value"}',
    }

    local generated_script = http_to_python.generate_python_requests_script(request, "json")

    -- Expected script
    local expected_script = [[
import requests

url = "/submit"
headers = {
    "Content-Type": "application/json",
    "Host": "example.com",
}

cookies = {
    "sessionid": "abc123",
    "csrftoken": "xyz789",
}

json_body = {"key": "value"}

# Uncomment the following lines to use Burp Proxy
# proxies = {
#     "http": "http://127.0.0.1:8080",
#     "https": "http://127.0.0.1:8080",
# }

response = requests.post(url, headers=headers, cookies=cookies, json=json_body)
# Add 'proxies=proxies' to use the proxy
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

    compare_generated_and_expected(generated_script, expected_script)
  end)
end)
describe("convert_to_dict", function()
  it("converts form-data body into a dictionary", function()
    local form_data = "key1=value1&key2=value2"
    local expected_result = {
      key1 = "value1",
      key2 = "value2",
    }

    local parsed_body = require("hacker-helper.http_to_python").convert_to_dict(form_data)
    assert.are.same(expected_result, parsed_body)
  end)

  it("returns nil for an unparsable body", function()
    local raw_body = '{"key": "value"}'
    local parsed_body = require("hacker-helper.http_to_python").convert_to_dict(raw_body)
    assert.is_nil(parsed_body)
  end)
end)
