--- a parser for surrounding character pairs
-- @module parser

local utils = require "surround.utils"

local OPENING = 1
local CLOSING = 2
local LINE = 1
local COLUMN = 2

local function get_surrounding_function(buffer, cursor_position, includes)
  local pair = {"(", ")"}

  local opening_index
  local closing_index
  local function_start_index
  local offset = 0

  local buffer_prev_indexes = {cursor_position[LINE], cursor_position[COLUMN] - 1}
  local buffer_next_indexes = {cursor_position[LINE], cursor_position[COLUMN] + 1}

  local char_before_cursor = buffer[cursor_position[LINE]]:sub(cursor_position[COLUMN] - 1, cursor_position[COLUMN] - 1)
  local char_at_cursor = buffer[cursor_position[LINE]]:sub(cursor_position[COLUMN], cursor_position[COLUMN])
  if (char_at_cursor == "\\") then
    buffer_next_indexes[CLOSING] = cursor_position[COLUMN]
    offset = -1
  end

  if (pair[OPENING] == char_at_cursor and char_before_cursor ~= "\\") then
    opening_index = {cursor_position[LINE], cursor_position[COLUMN]}
  elseif (pair[CLOSING] == char_at_cursor and char_before_cursor ~= "\\") then
    closing_index = {cursor_position[LINE], cursor_position[COLUMN]}
  end

  -- Find opening character indexes
  -- Initialize pair stack
  local pair_stack = 0
  -- Loop through the lines before the cursor in reverse order
  for line_no = buffer_prev_indexes[LINE], 1, -1 do
    local line = buffer[line_no]
    -- Check if already found opening character
    if opening_index then
      break
    end
    if line_no < buffer_prev_indexes[LINE] then
      -- Loop through the line in reverse order if cursor is not on the line
      for col_no = #line, 1, -1 do
        -- Get the character currently looping through and the previous one for escaping purposes
        local prev_char = line:sub(col_no - 1, col_no - 1)
        local current_char = line:sub(col_no, col_no)
        -- If found a closing character then add it to the pair stack
        if (current_char == pair[CLOSING] and prev_char ~= "\\") then
          pair_stack = pair_stack + 1
        end
        if (current_char == pair[OPENING] and prev_char ~= "\\") then
          -- if the pair stack is empty set the opening indexes
          if pair_stack == 0 then
            opening_index = {line_no, col_no}
          end
          pair_stack = pair_stack - 1
        end
      end
    else
      -- Loop through the line in reverse order from the cursor position if cursor is on the line
      for col_no = buffer_prev_indexes[COLUMN], 1, -1 do
        -- Get the character currently looping through and the previous one for escaping purposes
        local prev_char = line:sub(col_no - 1, col_no - 1)
        local current_char = line:sub(col_no, col_no)
        -- If found a closing character then add it to the pair stack
        if (current_char == pair[CLOSING] and prev_char ~= "\\") then
          pair_stack = pair_stack + 1
        end
        if (current_char == pair[OPENING] and prev_char ~= "\\") then
          -- if the pair stack is empty set the opening indexes
          if pair_stack == 0 then
            opening_index = {line_no, col_no}
            break
          end
          pair_stack = pair_stack - 1
        end
      end
    end
  end

  -- Find the start of the function name.
  for col_no = opening_index[COLUMN] - 1, 1, -1 do
    local current_char = buffer[opening_index[LINE]]:sub(col_no, col_no)
    if not string.isalnum(current_char, includes) then
      function_start_index = {opening_index[LINE], col_no + 1}
      break
    end
  end

  -- Find closing character indexes
  -- Initialize pair stack
  pair_stack = 0
  -- Loop through the buffer line starting with the line the cursor is on
  for line_no = buffer_next_indexes[LINE], #buffer do
    -- If not already found find the closing pair
    if closing_index then
      break
    end
    local line = buffer[line_no]
    if line_no > buffer_next_indexes[LINE] then
      -- Loop through the characters in the line from the start if cursor is not on the line
      for col_no = 1, #line do
        -- Get the character currently looping through and the previous one for escaping purposes
        local prev_char = line:sub(col_no - 1, col_no - 1)
        local current_char = line:sub(col_no, col_no)
        -- If found a opening character then add it to the pair stack
        if (current_char == pair[OPENING] and prev_char ~= "\\") then
          pair_stack = pair_stack + 1
        end
        if (current_char == pair[CLOSING] and prev_char ~= "\\") then
          -- if the pair stack is empty set the closing indexes
          if pair_stack == 0 then
            closing_index = {line_no, col_no + offset}
            break
          end
          pair_stack = pair_stack - 1
        end
      end
    else
      -- Loop through the characters in the line from the cursor position if cursor is on the line
      for col_no = buffer_next_indexes[COLUMN], #line do
        -- Get the character currently looping through and the previous one for escaping purposes
        local prev_char = line:sub(col_no - 1, col_no - 1)
        local current_char = line:sub(col_no, col_no)
        -- If found a opening character then add it to the pair stack
        if (current_char == pair[OPENING] and prev_char ~= "\\") then
          pair_stack = pair_stack + 1
        end
        if (current_char == pair[CLOSING] and prev_char ~= "\\") then
          -- if the pair stack is empty set the closing indexes
          if pair_stack == 0 then
            closing_index = {line_no, col_no + offset}
            break
          end
          pair_stack = pair_stack - 1
        end
      end
    end
  end
  if (function_start_index and opening_index and closing_index) then
    return {opening_index, closing_index, function_start_index}
  else
    return nil
  end
end

local function get_nested_pair(buffer, cursor_position, surrounding_char)
  local surround_pairs = vim.g.surround_pairs
  local all_pairs = table.merge(surround_pairs.nestable, surround_pairs.linear)
  local pair
  for _, val in ipairs(all_pairs) do
    if (table.contains(val, surrounding_char)) then
      pair = val
      break
    end
  end

  local opening_index
  local closing_index
  local offset = 0

  local buffer_prev_indexes = {cursor_position[LINE], cursor_position[COLUMN] - 1}
  local buffer_next_indexes = {cursor_position[LINE], cursor_position[COLUMN] + 1}

  local char_before_cursor = buffer[cursor_position[LINE]]:sub(cursor_position[COLUMN] - 1, cursor_position[COLUMN] - 1)
  local char_at_cursor = buffer[cursor_position[LINE]]:sub(cursor_position[COLUMN], cursor_position[COLUMN])
  if (char_at_cursor == "\\") then
    buffer_next_indexes[CLOSING] = cursor_position[COLUMN]
    offset = -1
  end

  if (pair[OPENING] == char_at_cursor and char_before_cursor ~= "\\") then
    opening_index = {cursor_position[LINE], cursor_position[COLUMN]}
  elseif (pair[CLOSING] == char_at_cursor and char_before_cursor ~= "\\") then
    closing_index = {cursor_position[LINE], cursor_position[COLUMN]}
  end

  -- Find opening character indexes
  -- Initialize pair stack
  local pair_stack = 0
  -- Loop through the lines before the cursor in reverse order
  for line_no = buffer_prev_indexes[LINE], 1, -1 do
    -- Check if already found
    if opening_index then
      break
    end
    local line = buffer[line_no]
    if line_no < buffer_prev_indexes[LINE] then
      -- Loop through the line in reverse order if cursor is not on the line
      for col_no = #line, 1, -1 do
        -- Get the character currently looping through and the previous one for escaping purposes
        local prev_char = line:sub(col_no - 1, col_no - 1)
        local current_char = line:sub(col_no, col_no)
        -- If found a closing character then add it to the pair stack
        if (current_char == pair[CLOSING] and prev_char ~= "\\") then
          pair_stack = pair_stack + 1
        end
        if (current_char == pair[OPENING] and prev_char ~= "\\") then
          -- if the pair stack is empty set the opening indexes
          if pair_stack == 0 then
            opening_index = {line_no, col_no}
            break
          end
          pair_stack = pair_stack - 1
        end
      end
    else
      -- Loop through the line in reverse order from the cursor position if cursor is on the line
      for col_no = buffer_prev_indexes[COLUMN], 1, -1 do
        -- Get the character currently looping through and the previous one for escaping purposes
        local prev_char = line:sub(col_no - 1, col_no - 1)
        local current_char = line:sub(col_no, col_no)
        -- If found a closing character then add it to the pair stack
        if (current_char == pair[CLOSING] and prev_char ~= "\\") then
          pair_stack = pair_stack + 1
        end
        if (current_char == pair[OPENING] and prev_char ~= "\\") then
          -- if the pair stack is empty set the opening indexes
          if pair_stack == 0 then
            opening_index = {line_no, col_no}
            break
          end
          pair_stack = pair_stack - 1
        end
      end
    end
  end

  -- Find closing character indexes
  -- Initialize pair stack
  pair_stack = 0
  -- Loop through the buffer line starting with the line the cursor is on
  for line_no = buffer_next_indexes[LINE], #buffer do
    -- If not already found find the closing pair
    if closing_index then
      break
    end
    local line = buffer[line_no]
    if line_no > buffer_next_indexes[LINE] then
      -- Loop through the characters in the line from the start if cursor is not on the line
      for col_no = 1, #line do
        -- Get the character currently looping through and the previous one for escaping purposes
        local prev_char = line:sub(col_no - 1, col_no - 1)
        local current_char = line:sub(col_no, col_no)
        -- If found a opening character then add it to the pair stack
        if (current_char == pair[OPENING] and prev_char ~= "\\") then
          pair_stack = pair_stack + 1
        end
        if (current_char == pair[CLOSING] and prev_char ~= "\\") then
          -- if the pair stack is empty set the closing indexes
          if pair_stack == 0 then
            closing_index = {line_no, col_no + offset}
            break
          end
          pair_stack = pair_stack - 1
        end
      end
    else
      -- Loop through the characters in the line from the cursor position if cursor is on the line
      for col_no = buffer_next_indexes[COLUMN], #line do
        -- Get the character currently looping through and the previous one for escaping purposes
        local prev_char = line:sub(col_no - 1, col_no - 1)
        local current_char = line:sub(col_no, col_no)
        -- If found a opening character then add it to the pair stack
        if (current_char == pair[OPENING] and prev_char ~= "\\") then
          pair_stack = pair_stack + 1
        end
        if (current_char == pair[CLOSING] and prev_char ~= "\\") then
          -- if the pair stack is empty set the closing indexes
          if pair_stack == 0 then
            closing_index = {line_no, col_no + offset}
            break
          end
          pair_stack = pair_stack - 1
        end
      end
    end
  end
  if (opening_index and closing_index) then
    return {opening_index, closing_index}
  else
    return nil
  end
end

local function get_non_nested_pair(buffer, cursor_position, surrounding_char)
  local is_finding_opening = true
  local surround_pairs = vim.g.surround_pairs
  local all_pairs = table.merge(surround_pairs.nestable, surround_pairs.linear)
  local pair
  for _, val in ipairs(all_pairs) do
    if (table.contains(val, surrounding_char)) then
      pair = val
      break
    end
  end
  local opening_index
  local closing_index
  for line_no, line in ipairs(buffer) do
    for col_no = 1, #line do
      local prev_char = line:sub(col_no - 1, col_no - 1)
      local current_char = line:sub(col_no, col_no)
      if (is_finding_opening) then -- if finding the first char do this
        if (col_no > cursor_position[COLUMN] and line_no >= cursor_position[LINE]) then -- Break out if there are no surrounding surround_pairs
          break
        end
        if (current_char == pair[OPENING] and prev_char ~= "\\") then
          is_finding_opening = false -- found first pair now find last pair
          opening_index = {line_no, col_no}
        end
      else -- if finding the last char then do this
        if (current_char == pair[CLOSING] and prev_char ~= "\\") then
          is_finding_opening = true -- found last pair now find first pair
          if (col_no >= cursor_position[COLUMN] and line_no >= cursor_position[LINE]) then
            closing_index = {line_no, col_no}
            return {opening_index, closing_index}
          end
        end
      end
    end
  end
end

--- Find the surrounding pair.
-- Returns the indexes of the nearest surrounding pair char in the given buffer relative to the give cursor position.
-- @param buffer the buffer to look for the surrounding pair char
-- @param cur_pos the cursor positon in the buffer (1 indexed)
-- @param char the char for which the surrounding pair must be found
-- @return a table consisting of a pair of indexes (1 indexed) in the form {opening_char_index, closing_char_index} or false if no pairs found
-- @function get_surround_pair
local function get_surround_pair(buffer, cursor_position, surrounding_char, includes)
  local surround_pairs = vim.g.surround_pairs
  -- If the character is not in the pairs table return an emoty string.
  local all_pairs = vim.tbl_flatten(table.merge(surround_pairs.nestable, surround_pairs.linear))
  local special_char = {"f"}
  for _, char in ipairs(special_char) do
    table.insert(all_pairs, #all_pairs + 1, char)
  end
  if not table.contains(all_pairs, surrounding_char) then
    return nil
  end

  -- Check if the character can be nested.
  local is_nestable = false
  for _, pair in pairs(surround_pairs.nestable) do
    if table.contains(pair, surrounding_char) then
      is_nestable = true
    end
  end

  local indexes
  if (surrounding_char == "f") then
    indexes = get_surrounding_function(buffer, cursor_position, includes)
  elseif (is_nestable) then
    indexes = get_nested_pair(buffer, cursor_position, surrounding_char)
  else
    indexes = get_non_nested_pair(buffer, cursor_position, surrounding_char)
  end
  if not (indexes == nil) then
    return indexes
  else
    return nil
  end
end

return {
  get_surround_pair = get_surround_pair
}
