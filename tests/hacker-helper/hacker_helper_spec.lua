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

  it("encodes Gzip correctly", function()
    local text = "Hello, World!"
    local encoded = plugin.transform_func(text, "specific_selection", "encode", "gzip")
    -- Ensure it's encoded, actual result will vary based on zlib implementation
    assert.is_not.equal(text, encoded)
  end)

  it("decodes Gzip correctly", function()
    local text = "Hello, World!"
    local encoded = plugin.transform_func(text, "specific_selection", "encode", "gzip")
    local decoded = plugin.transform_func(encoded, "specific_selection", "decode", "gzip")
    assert.are.equal(text, decoded)
  end)

  -- Test Binary encoding and decoding
  it("encodes Binary correctly", function()
    local text = "Hello"
    local encoded = plugin.transform_func(text, "specific_selection", "encode", "binary")
    assert.are.equal("0100100001100101011011000110110001101111", encoded)
  end)

  it("decodes Binary correctly", function()
    local encoded_text = "0100100001100101011011000110110001101111"
    local decoded = plugin.transform_func(encoded_text, "specific_selection", "decode", "binary")
    assert.are.equal("Hello", decoded)
  end)

  -- Test Octal encoding and decoding
  it("encodes Octal correctly", function()
    local text = "Hello"
    local encoded = plugin.transform_func(text, "specific_selection", "encode", "octal")
    assert.are.equal("\\110\\145\\154\\154\\157", encoded)
  end)

  it("decodes Octal correctly", function()
    local encoded_text = "\\110\\145\\154\\154\\157"
    local decoded = plugin.transform_func(encoded_text, "specific_selection", "decode", "octal")
    assert.are.equal("Hello", decoded)
  end)

  describe("Hashing Functions", function()
    -- Test MD5 hashing
    it("hashes text using MD5", function()
      local text = "hello"
      local hashed = plugin.hash_text(text, "md5")
      assert.are.equal("5d41402abc4b2a76b9719d911017c592", hashed)
    end)

    -- Test SHA-1 hashing
    it("hashes text using SHA-1", function()
      local text = "hello"
      local hashed = plugin.hash_text(text, "sha1")
      assert.are.equal("aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d", hashed)
    end)

    -- Test SHA-256 hashing
    it("hashes text using SHA-256", function()
      local text = "hello"
      local hashed = plugin.hash_text(text, "sha256")
      assert.are.equal("2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824", hashed)
    end)

    -- Test CRC32 hashing
    it("hashes text using CRC32", function()
      local text = "hello"
      local hashed = plugin.hash_text(text, "crc32")
      assert.are.equal("3610a686", hashed)
    end)

    -- Test Scrypt hashing
    it("hashes text using Scrypt", function()
      local text = "hello"
      local hashed = plugin.hash_text(text, "scrypt")
      assert.are.equal(
        "de9f496a91b7c783c46a1841f71b4500210adec570f4407fcb2975d8e97e7e747a35816a9988959a6c9d921bbc8b7ea9caa0059e154b732850da77db18497072",
        hashed
      )
    end)
    it("hashes test using Bcrypt", function()
      local text = "hello"
      local hashed = plugin.hash_text(text, "bcrypt")

      -- Extract the salt and hashed part from the Bcrypt hash
      local salt = string.sub(hashed, 8, 29) -- Salt is from positions 8 to 29 (22 characters)
      local hashed_part = string.sub(hashed, 30, 60) -- Hashed part is from positions 30 to 60 (31 characters)

      -- Verify Salt
      assert.are.equal(22, #salt, "Salt length is incorrect")
      for i = 1, #salt do
        local char = string.sub(salt, i, i)
        local is_valid = string.match(char, "[./A-Za-z0-9]")
        assert.is_true(is_valid ~= nil, "Salt contains invalid characters at position " .. i .. ": " .. char)
      end

      -- Verify Hashed Part
      assert.are.equal(31, #hashed_part, "Hashed part length is incorrect")
      for i = 1, #hashed_part do
        local char = string.sub(hashed_part, i, i)
        local is_valid = string.match(char, "[./A-Za-z0-9]")
        assert.is_true(is_valid ~= nil, "Hashed part contains invalid characters at position " .. i .. ": " .. char)
      end
    end)
  end)
end)
