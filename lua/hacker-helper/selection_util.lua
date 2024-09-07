-- lua/hacker-helper/selection_util.lua

local M = {}

M.transform_selection = function(transform_func, mode, encoding_type)
  -- Default to "decode" if mode is not provided (backward compatibility)
  mode = mode or "decode"

  -- Reselect the current visual block to ensure the latest selection is active
  vim.cmd("normal! gv")

  -- Get the visual selection range using visual marks
  local start_pos = vim.fn.getpos("'<") -- Start of the visual selection
  local end_pos = vim.fn.getpos("'>") -- End of the visual selection

  -- Ensure start_pos and end_pos are valid
  start_pos = start_pos or { 0, 0, 0 }
  end_pos = end_pos or { 0, 0, 0 }

  -- Adjust to capture the correct lines in visual line mode (V)
  local start_line = math.min(start_pos[2], end_pos[2])
  local end_line = math.max(start_pos[2], end_pos[2])

  local start_col = math.max(0, start_pos[3] - 1) -- 0-based index for inline selection
  local end_col = math.max(0, end_pos[3]) -- inclusive for inline selection

  -- Get the selected lines, replacing nil values with empty strings
  local lines = vim.fn.getline(start_line, end_line) or {}
  for i = 1, #lines do
    lines[i] = lines[i] or "" -- Ensure no nil values
  end

  -- Handle visual line selection (V) and inline selection (v)
  if vim.fn.visualmode() == "V" then
    -- Full line selection
    vim.notify("Full lines selected: " .. vim.inspect(lines), vim.log.levels.INFO)
    -- Apply transformation for full lines
    for i, line in ipairs(lines) do
      lines[i] = transform_func(line, "full_line", mode, encoding_type)
    end

    -- If mode is "hash", insert the result above
    if mode == "hash" then
      vim.fn.append(start_line - 1, lines)
    else
      vim.fn.setline(start_line, lines) -- Default: Replace lines for encoding/decoding
    end
  else
    -- Inline selection (v mode)
    if start_line == end_line then
      -- Handle inline selection on a single line
      local line = lines[1] or ""
      start_col = math.max(0, start_col)
      end_col = math.min(#line, end_col)

      -- Capture the selected part of the line
      local selection = string.sub(line, start_col + 1, end_col)
      vim.notify("Selected part of the line: " .. selection, vim.log.levels.INFO)

      -- Transform the selected part
      local transformed = transform_func(selection or "", "specific_selection", mode, encoding_type)

      -- Replace the selected part with the transformed text
      local new_line = string.sub(line, 1, start_col) .. transformed .. string.sub(line, end_col + 1)

      -- If mode is "hash", insert the result above
      if mode == "hash" then
        vim.fn.append(start_line - 1, transformed)
      else
        vim.fn.setline(start_line, new_line)
      end
    else
      -- Handle multi-line partial selection
      local first_line = string.sub(lines[1] or "", start_col + 1)
      local last_line = string.sub(lines[#lines] or "", 1, end_col)
      vim.notify("Multi-line selection: First line: " .. first_line, vim.log.levels.INFO)
      vim.notify("Last line: " .. last_line, vim.log.levels.INFO)

      -- Transform first and last lines
      lines[1] = string.sub(lines[1] or "", 1, start_col)
        .. transform_func(first_line, "multi_line", mode, encoding_type)
      lines[#lines] = transform_func(last_line, "multi_line", mode, encoding_type)
        .. string.sub(lines[#lines] or "", end_col + 1)

      -- Transform middle lines
      for i = 2, #lines - 1 do
        lines[i] = transform_func(lines[i], "multi_line", mode, encoding_type)
      end

      -- If mode is "hash", insert the result above
      if mode == "hash" then
        vim.fn.append(start_line - 1, lines)
      else
        vim.fn.setline(start_line, lines) -- Default: Replace lines for encoding/decoding
      end
    end
  end

  -- Reset the cursor position to prevent jumping to another line
  vim.cmd("normal! gv") -- Ensure the visual selection is active
end

return M
