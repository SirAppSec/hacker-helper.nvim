local http_to_python = require("hacker-helper.http_to_python")

describe("parse_http_request", function()
  it("parses a simple GET request", function()
    local http_request = {
      "GET /test HTTP/1.1",
      "Host: example.com",
      "User-Agent: Mozilla/5.0",
      "Cookie: sessionid=abc123; csrftoken=xyz789",
      "",
    }

    local expected_result = {
      method = "GET",
      url = "/test",
      headers = {
        ["Host"] = "example.com",
        ["User-Agent"] = "Mozilla/5.0",
      },
      cookies = {
        ["sessionid"] = "abc123",
        ["csrftoken"] = "xyz789",
      },
      body = nil,
    }

    local parsed_request = require("hacker-helper.http_to_python").parse_http_request(http_request)
    assert.are.same(expected_result, parsed_request)
  end)

  it("parses a POST request with a body", function()
    local http_request = {
      "POST /submit HTTP/1.1",
      "Host: example.com",
      "Content-Type: application/json",
      "",
      '{"key": "value"}',
    }

    local expected_result = {
      method = "POST",
      url = "/submit",
      headers = {
        ["Host"] = "example.com",
        ["Content-Type"] = "application/json",
      },
      cookies = {},
      body = '{"key": "value"}',
    }

    local parsed_request = require("hacker-helper.http_to_python").parse_http_request(http_request)
    assert.are.same(expected_result, parsed_request)
  end)
end)

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
      body = '{"key": "value"}',
    }

    local generated_script = require("hacker-helper.http_to_python").generate_python_requests_script(request, "raw")
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

# Uncomment the following lines to use Burp Proxy
# proxies = {
#     "http": "http://127.0.0.1:8080",
#     "https": "http://127.0.0.1:8080",
# }

response = requests.post(url, headers=headers, cookies=cookies, data=r"""{"key":"value"}""")
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

    assert.are.same(expected_script:gsub("%s+", ""), generated_script:gsub("%s+", ""))
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
      body = "key=value",
    }

    local generated_script =
      require("hacker-helper.http_to_python").generate_python_requests_script(request, "form-data")
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

    assert.are.same(expected_script:gsub("%s+", ""), generated_script:gsub("%s+", ""))
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

    local generated_script = require("hacker-helper.http_to_python").generate_python_requests_script(request, "json")
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

    assert.are.same(expected_script:gsub("%s+", ""), generated_script:gsub("%s+", ""))
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

  it("returns nil for an unparseable body", function()
    local raw_body = '{"key": "value"}'
    local parsed_body = require("hacker-helper.http_to_python").convert_to_dict(raw_body)
    assert.is_nil(parsed_body)
  end)
end)
