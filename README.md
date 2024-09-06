# Hacker Helper

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/SirAppsec/hacker-helper.nvim/lint-test.yml?branch=main&style=for-the-badge)
![Lua](https://img.shields.io/badge/Made%20with%20Lua-blueviolet.svg?style=for-the-badge&logo=lua)

A few Snippets to help hacking

1. Execute commands in toggle term by selection


# Requirements
Luarocks is required(luasocket mime for encoding decoding):
```bash
sudo apt install luarocks -y
```
## Using it


```lua
# Add to plugins/hacker-helper.lua
return {
  {
    "SirAppsec/hacker-helper.nvim",
    dependencies = {
            { 'luarocks/luasocket', rocks = 'luasocket' }
        },
    opts = {
      prefix = "<leader>r", -- Change base prefix to <leader>r
      keys = {
        run_exec = "e", -- <leader>re (Execute Command in Terminal)
        encode_prefix = "de", -- <leader>rde (Encode Group)
        decode_prefix = "d",  -- <leader>rd (Decode Group)
        encode_url = "u",     -- <leader>rdeu (URL Encode)
        decode_url = "u",     -- <leader>rdu (URL Decode)
        encode_base64 = "b",  -- <leader>rdeb (Base64 Encode)
        decode_base64 = "b",  -- <leader>rdb (Base64 Decode)
      },
    },
  },
}
```


