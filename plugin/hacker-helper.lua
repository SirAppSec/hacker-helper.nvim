vim.api.nvim_create_user_command("HackerHelper", require("hacker-helper").hello, {})
-- Key mappings for executing in terminal

-- Key mappings for executing in terminal
vim.api.nvim_set_keymap('n', '<leader>re', ':lua require("hacker-helper.module").exec_line_or_selection_in_term()<CR>',
  { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<leader>re', ':lua require("hacker-helper.module").exec_line_or_selection_in_term()<CR>',
  { noremap = true, silent = true })
