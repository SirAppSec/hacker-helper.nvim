local plugin = require("hacker-helper")
-- todo: ensure that we test the setup
-- describe("setup", function()
--   it("works with default", function()
--     assert(plugin.hello() == "Hello!", "my first function with param = Hello!")
--   end)
--
--   it("works with custom var", function()
--     plugin.setup({ opt = "custom" })
--     assert(plugin.hello() == "custom", "my first function with param = custom")
--   end)
-- end)

describe("encoding/decoding", function()
  -- Test Base64 encoding and decoding
  it("encodes Base64 correctly", function()
    local text = "Hello, World!"
    local encoded = plugin.transform_func(text, "specific_selection", "encode", "base64")
    assert.are.equal("SGVsbG8sIFdvcmxkIQ==", encoded)
  end)

  it("decodes Base64 correctly", function()
    local encoded_text = "SGVsbG8sIFdvcmxkIQ=="
    local decoded = plugin.transform_func(encoded_text, "specific_selection", "decode", "base64")
    assert.are.equal("Hello, World!", decoded)
  end)

  -- Test URL encoding and decoding
  it("encodes URL correctly", function()
    local text = "Hello, World!"
    local encoded = plugin.transform_func(text, "specific_selection", "encode", "url")
    assert.are.equal("Hello%2C%20World%21", encoded)
  end)

  it("decodes URL correctly", function()
    local encoded_text = "Hello%2C%20World%21"
    local decoded = plugin.transform_func(encoded_text, "specific_selection", "decode", "url")
    assert.are.equal("Hello, World!", decoded)
  end)

  -- Test full-line and multi-line selections for Base64
  it("encodes a full line with Base64 correctly", function()
    local text = "This is a full line."
    local encoded = plugin.transform_func(text, "full_line", "encode", "base64")
    assert.are.equal("VGhpcyBpcyBhIGZ1bGwgbGluZS4=", encoded)
  end)

  it("decodes multi-line Base64 correctly", function()
    local text = "VGhpcyBpcyBhIGZ1bGwgbGluZS4="
    local decoded = plugin.transform_func(text, "multi_line", "decode", "base64")
    assert.are.equal("This is a full line.", decoded)
  end)

  -- Test handling of unknown encoding type
  it("returns the same text if encoding type is unknown", function()
    local text = "Hello, World!"
    local result = plugin.transform_func(text, "specific_selection", "encode", "unknown")
    assert.are.equal(text, result)
  end)

  -- Test handling of unknown action (not encode/decode)
  it("returns the same text if the action is not encode or decode", function()
    local text = "Hello, World!"
    local result = plugin.transform_func(text, "specific_selection", "unknown_action", "base64")
    assert.are.equal(text, result)
  end)

  -- Test HTML encoding and decoding
  it("encodes HTML correctly", function()
    local text = "<Hello & 'World'>"
    local encoded = plugin.transform_func(text, "specific_selection", "encode", "html")
    assert.are.equal("&lt;Hello &amp; &#039;World&#039;&gt;", encoded)
  end)

  it("decodes HTML correctly", function()
    local encoded_text = "&lt;Hello &amp; &#039;World&#039;&gt;"
    local decoded = plugin.transform_func(encoded_text, "specific_selection", "decode", "html")
    assert.are.equal("<Hello & 'World'>", decoded)
  end)

  -- Test ASCII Hex encoding and decoding
  it("encodes ASCII Hex correctly", function()
    local text = "Hello"
    local encoded = plugin.transform_func(text, "specific_selection", "encode", "ascii_hex")
    assert.are.equal("\\x48\\x65\\x6C\\x6C\\x6F", encoded)
  end)

  it("decodes ASCII Hex correctly", function()
    local encoded_text = "\\x48\\x65\\x6C\\x6C\\x6F"
    local decoded = plugin.transform_func(encoded_text, "specific_selection", "decode", "ascii_hex")
    assert.are.equal("Hello", decoded)
  end)
end)
