local plugin = require("hacker-helper")

describe("setup", function()
  it("works with default", function()
    assert(plugin.hello() == "Hello!", "my first function with param = Hello!")
  end)

  it("works with custom var", function()
    plugin.setup({ opt = "custom" })
    assert(plugin.hello() == "custom", "my first function with param = custom")
  end)
end)

describe("Base64 and URL encoding/decoding", function()
  -- Test Base64 encoding and decoding
  it("encodes Base64 correctly", function()
    local text = "Hello, World!"
    local encoded = plugin.transform_text(text, "encode", "base64")
    assert(encoded == "SGVsbG8sIFdvcmxkIQ==", "Base64 encoding failed")
  end)

  it("decodes Base64 correctly", function()
    local encoded_text = "SGVsbG8sIFdvcmxkIQ=="
    local decoded = plugin.transform_text(encoded_text, "decode", "base64")
    assert(decoded == "Hello, World!", "Base64 decoding failed")
  end)

  -- Test URL encoding and decoding
  it("encodes URL correctly", function()
    local text = "Hello, World!"
    local encoded = plugin.transform_text(text, "encode", "url")
    assert(encoded == "Hello%2C%20World%21", "URL encoding failed")
  end)

  it("decodes URL correctly", function()
    local encoded_text = "Hello%2C%20World%21"
    local decoded = plugin.transform_text(encoded_text, "decode", "url")
    assert(decoded == "Hello, World!", "URL decoding failed")
  end)
end)
