# Hacker Helper

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/SirAppsec/hacker-helper.nvim/lint-test.yml?branch=main&style=for-the-badge)
![Lua](https://img.shields.io/badge/Made%20with%20Lua-blueviolet.svg?style=for-the-badge&logo=lua)

A few Snippets to help hacking

1. Execute commands in toggle term by selection

## Using it


```
# Add to plugins/hacker-helper.lua
return {
  {
    "SirAppsec/hacker-helper.nvim",
    opts = {
      prefix = "<leader>r", -- Change base prefix to <leader>r
      keys = {
        run_exec = "e", -- <leader>re (Execute Command in Terminal)
      },
    },
  },
}
```


