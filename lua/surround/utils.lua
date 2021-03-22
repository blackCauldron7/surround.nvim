local function get(var, def)
  if var == nil then
    return def
  end
  return var
end

-- table methods

function table.merge(t1, t2)
  local tmp = {}
  for _, v in ipairs(t1) do
    table.insert(tmp, v)
  end
  for _, v in ipairs(t2) do
    table.insert(tmp, v)
  end
  return tmp
end

function table.contains(tbl, string)
  for _, v in ipairs(tbl) do
    if v == string then
      return true
    end
  end
  return false
end

function table.slice(tbl, first, last, step)
  local sliced = {}
  for i = first or 1, last or #tbl, step or 1 do
    sliced[#sliced + 1] = tbl[i]
  end
  return sliced
end

-- string functions

local function quote(char)
  if char == '"' then
    return "'" .. char .. "'"
  else
    return '"' .. char .. '"'
  end
end

function string.isalnum(inputstr, includes)
  for i = 1, #inputstr do
    local char = inputstr:sub(i, i)
    if
      not (("A" <= char and char <= "Z") or ("a" <= char and char <= "z") or ("0" <= char and char <= "9") or
        table.contains(get(includes, {}), char))
     then
      return false
    end
  end
  return true
end

function string.split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  local element = ""
  for i = 1, #inputstr do
    local current_char = inputstr:sub(i, i)
    if (current_char ~= sep) then
      element = element .. current_char
    else
      table.insert(t, element)
      element = ""
    end
  end
  if #element > 0 then
    table.insert(t, element)
  end
  return t
end

function string.insert(inputstr, index, sub_str)
  return inputstr:sub(1, index - 1) .. sub_str .. inputstr:sub(index, #inputstr + 1)
end

function string.remove(inputstr, from, to)
  if (to == nil) then
    to = from + 1
  end
  return inputstr:sub(1, from - 1) .. inputstr:sub(to, #inputstr)
end

function string.set(inputstr, index, sub_str)
  return inputstr:sub(1, index - 1) .. sub_str .. inputstr:sub(index + 1, #inputstr)
end

local function get_visual_pos()
  local start = vim.api.nvim_buf_get_mark(0, "<")
  local start_line = start[1]
  local start_col = start[2] + 1
  local _end = vim.api.nvim_buf_get_mark(0, ">")
  local end_line = _end[1]
  local end_col = _end[2] + 2
  return start_line, start_col, end_line, end_col
end

local function tprint(tbl, indent)
  if not indent then
    indent = 0
  end
  for k, v in pairs(tbl) do
    local formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      tprint(v, indent + 1)
    elseif type(v) == "boolean" then
      print(formatting .. tostring(v))
    else
      print(formatting .. v)
    end
  end
end

local function user_input(message)
  vim.api.nvim_call_function("inputsave", {})
  local val = vim.api.nvim_call_function("input", {message})
  vim.api.nvim_call_function("inputrestore", {})
  vim.api.nvim_command('echo "\r                          \r"')
  return val
end

local load_keymaps = function(keymap_table)
  for _, keymap in ipairs(keymap_table) do
    vim.api.nvim_set_keymap(unpack(keymap))
  end
end

local function get_nth_element(tbls, n)
  local elements = {}
  for _, tbl in ipairs(tbls) do
    table.insert(elements, tbl[n])
  end
  return elements
end

local function get_line_numbers_by_offset(offset)
  local current_cursor_position = vim.api.nvim_win_get_cursor(0)
  local current_line_number = current_cursor_position[1]
  local total_lines = vim.fn.line("$")
  local top_offset, bottom_offset

  if (current_line_number > offset) then -- If there are more than offset lines above the current line.
    top_offset = current_line_number - offset - 1
  else
    top_offset = 0
  end

  if (total_lines - current_line_number > offset) then -- if there are more than offset lines below the current line.
    bottom_offset = total_lines - (current_line_number + offset)
  else
    bottom_offset = 0
  end
  return 1 + top_offset, total_lines - bottom_offset, top_offset, bottom_offset
end

local function table_keys(t)
  local keys = {}
  for k, _ in pairs(t) do
    table.insert(keys, k)
  end
  return keys
end

local function highlight(start_pos, end_pos, duration)
end

return {
  tprint = tprint,
  user_input = user_input,
  get_line_numbers_by_offset = get_line_numbers_by_offset,
  table_keys = table_keys,
  get_nth_element = get_nth_element,
  get_visual_pos = get_visual_pos,
  load_keymaps = load_keymaps,
  quote = quote,
  get = get
}
