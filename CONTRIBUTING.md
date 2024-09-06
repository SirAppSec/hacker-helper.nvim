# Contributing to `hacker-helper.nvim`

contributing to `hacker-helper.nvim`

## github actions 
github actions checks for stylua, linsting, and runs `make test`

## Steps to Add a New Encoding/Decoding Functionality

### 1. Define the Encoding/Decoding Functions

Start by creating **two utility functions** for encoding and decoding in the main module file (`lua/hacker-helper.lua`). The functions should accept a string and return an encoded/decoded string.

- **Encode function**: This function should handle encoding logic.
- **Decode function**: This function should handle decoding logic.

#### Example:

```lua
-- Custom Encoding Utility Functions
M.custom_encode = function(text)
  -- Encoding logic here (example: ROT13, etc.)
  return text -- Replace with actual encoding logic
end

M.custom_decode = function(text)
  -- Decoding logic here
  return text -- Replace with actual decoding logic
end
```

### 2. Update the `transform_func` in `lua/hacker-helper.lua`

In the `transform_func` function, add logic to check for the new encoding type and call the respective encode/decode functions.

#### Example:

```lua
M.transform_func = function(text, selection_type, encode_or_decode, encoding_type)
  if encoding_type == "custom" then
    if encode_or_decode == "encode" then
      return M.custom_encode(text)
    elseif encode_or_decode == "decode" then
      return M.custom_decode(text)
    end
  end
  return text
end
```

### 3. Add Key Mappings

Add the necessary key mappings in `lua/hacker-helper.lua` for both visual mode and normal mode. Ensure that the new encoding/decoding follows the prefix patterns.

#### Example Key Mappings:

```lua
-- Custom Encode Key Mapping
vim.keymap.set("v", M.config.prefix .. M.config.keys.encode_prefix .. M.config.keys.encode_custom, function()
  selection_util.transform_selection(function(text, selection_type)
    return M.transform_func(text, selection_type, "encode", "custom")
  end)
end, { noremap = true, silent = true, desc = "Custom Encode" })

-- Custom Decode Key Mapping
vim.keymap.set("v", M.config.prefix .. M.config.keys.decode_prefix .. M.config.keys.decode_custom, function()
  selection_util.transform_selection(function(text, selection_type)
    return M.transform_func(text, selection_type, "decode", "custom")
  end)
end, { noremap = true, silent = true, desc = "Custom Decode" })
```

### 4. Update the Configuration (`config`)

Update the configuration table to include the new keys for encoding and decoding. Make sure the new keys follow the same prefix pattern for encoding (`encode_prefix`) and decoding (`decode_prefix`).

#### Example Configuration:

```lua
local config = {
  prefix = "<leader>r",  -- Default prefix for Hacker Helper
  keys = {
    -- Other keys...
    encode_custom = "c", -- <leader>rdec (Custom Encode)
    decode_custom = "c", -- <leader>rdc (Custom Decode)
  }
}
```

Update the `README.md` to reflect these new key mappings in the **Default Key Mappings** section.

### 5. Write Tests

Add tests in the `tests/hacker-helper/hacker_helper_spec.lua` file to verify that the encoding and decoding functions work as expected. 

#### Example Test Cases:

```lua
-- Test Custom encoding and decoding
it("encodes Custom correctly", function()
  local text = "Test string"
  local encoded = plugin.transform_func(text, "specific_selection", "encode", "custom")
  assert.are.equal("Encoded String", encoded) -- Replace with actual expected result
end)

it("decodes Custom correctly", function()
  local encoded_text = "Encoded String"
  local decoded = plugin.transform_func(encoded_text, "specific_selection", "decode", "custom")
  assert.are.equal("Test string", decoded)
end)
```

Run the tests using `make test` to verify the correctness of the new functionality.

### 6. Submit the Changes

1. **Lint**: Ensure your code passes lint checks (e.g., using `stylua`).
2. **Test**: Run all tests to ensure your changes don’t break any existing functionality.
3. **Commit**: Commit your changes with a clear message indicating what encoding/decoding functionality was added.
4. **Pull Request**: Create a pull request (PR) against the main repository, describing the added encoding/decoding functionality.

---

### Summary of Steps

1. **Define encoding/decoding functions**: Add functions for the new encoding/decoding method.
2. **Update `transform_func`**: Add logic for the new encoding type.
3. **Add key mappings**: Ensure both encode and decode mappings are added.
4. **Update the configuration**: Add new key configurations.
5. **Write tests**: Verify the new functionality with test cases.
6. **Submit a pull request**: Ensure the code passes linting and tests, and submit a well-documented PR.

---

Thank you for contributing to `hacker-helper.nvim`! We appreciate your efforts in making this plugin even better. If you have any questions, feel free to reach out through the project’s issue tracker.

--- 

This **CONTRIBUTE.md** outlines the steps for adding any additional encoding/decoding functionalities while maintaining the consistency and structure of the plugin.
