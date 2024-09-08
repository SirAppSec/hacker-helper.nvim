# Hacker Helper

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/SirAppsec/hacker-helper.nvim/lint-test.yml?branch=main&style=for-the-badge)
![Lua](https://img.shields.io/badge/Made%20with%20Lua-blueviolet.svg?style=for-the-badge&logo=lua)

A few Snippets to help hacking

1. Execute commands in toggle term by selection


# Requirements
Luarocks is required(luasocket mime,gzip,bit operations for encoding decoding):
```bash
sudo apt install luarocks -y
sudo luarocks install luasocket
sudo luarocks install lua-zlib
sudo luarocks install luabitop
sudo pip install bcrypt

```
## Using it


```lua
# Add to plugins/hacker-helper.lua
return {
  {
    "SirAppsec/hacker-helper.nvim",
    opts = {
      prefix = "<leader>r", -- Change base prefix to <leader>r
      keys = {
        run_exec = "e", -- <leader>re (Execute Command in Terminal)

        encode_prefix = "de", -- <leader>rde (Encode Group)
        decode_prefix = "d", -- <leader>rd (Decode Group)
        encode_url = "u", -- <leader>rdeu (URL Encode)
        hash_prefix = "c", -- <leader>rc (Hash Group)

        decode_url = "u", -- <leader>rdu (URL Decode)
        encode_base64 = "b", -- <leader>rdeb (Base64 Encode)
        decode_base64 = "b", -- <leader>rdb (Base64 Decode)
        encode_html = "h", -- <leader>rdeh (HTML Encode)
        decode_html = "h", -- <leader>rdh (HTML Decode)
        encode_ascii_hex = "x", -- <leader>rdex (ASCII Hex Encode)
        decode_ascii_hex = "x", -- <leader>rdx (ASCII Hex Decode)
        encode_gzip = "g", -- <leader>rdeg (Gzip Encode)
        decode_gzip = "g", -- <leader>rdg (Gzip Decode)
        encode_binary = "i", -- <leader>rdei (Binary Encode)
        decode_binary = "i", -- <leader>rdi (Binary Decode)
        encode_octal = "o", -- <leader>rdeo (Octal Encode)
        decode_octal = "o", -- <leader>rdo (Octal Decode)
        hash_md5 = "m", -- <leader>rcm (MD5 Hash)
        hash_sha1 = "s", -- <leader>rcs (SHA-1 Hash)
        hash_sha256 = "S", -- <leader>rcS (SHA-256 Hash)
        hash_crc32 = "c", -- <leader>rcC (CRC32 Hash)
        hash_scrypt = "y", -- <leader>rcy (Scrypt Hash)
        hash_bcrypt = "b", -- <leader>rcb (Bcrypt Hash)
      },
    },
  },
}
```

## RoadMap
1. fix issues with selection
2. add some tests for selection(difficult borderline-unnecessary)
3. Add scrape for advanced xss
4. use python HTTP.server on current folder/path `python3 -m http.server -d /path/to/web/dir`
5. host a simple attack server to serve XMLHttpRequests
6. paste polygloats/payloads/reverseshells `https://github.com/0xsobky/HackVault/wiki/Unleashing-an-Ultimate-XSS-Polyglot`
