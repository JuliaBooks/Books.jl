--- include-output.lua – filter to include Julia output
--- Based on include-files.lua – filter to include Markdown files
---

-- pandoc's List type
local List = require 'pandoc.List'

--- Get include auto mode
local include_auto = false
function get_vars (meta)
  if meta['include-auto'] then
    include_auto = true
  end
end

--- Keep last heading level found
local last_heading_level = 0
function update_last_level(header)
  last_heading_level = header.level
end

--- Shift headings in block list by given number
local function shift_headings(blocks, shift_by)
  if not shift_by then
    return blocks
  end

  local shift_headings_filter = {
    Header = function (header)
      header.level = header.level + shift_by
      return header
    end
  }

  return pandoc.walk_block(pandoc.Div(blocks), shift_headings_filter).content
end

--- Return path of the markdown file for the string `s` given by the user.
---
--- We can just drop a lot of info because it will probably still be unique.
--- Otherwise, Julia can detect duplicate filenames and throw an error.
---
--- Ensure that this logic corresponds to the logic inside Books.jl.
---
local md_path
function md_path(s)
  n = 80
  escaped = string.sub(s, 1, n)
  escaped = escaped:gsub("([^a-zA-Z0-9]+)", "_")
  -- Platform independent path separator.
  path_sep = package.config:sub(1, 1)
  path = "_gen" .. path_sep .. escaped .. ".md"
  return path
end

local not_found_error
function not_found_error(line, path, ticks)
  code = ticks .. line .. ticks
  io.stderr:write("Cannot find file for " .. code .. " at " .. path .. "\n")
end

--- Filter function for code blocks
local transclude_codeblock
function transclude_codeblock(cb)
  -- ignore code blocks which are not of class "jl".
  if not cb.classes:includes 'jl' then
    return
  end

  -- Markdown is used if this is nil.
  local format = cb.attributes['format']

  -- Attributes shift headings
  local shift_heading_level_by = 0
  local shift_input = cb.attributes['shift-heading-level-by']
  if shift_input then
    shift_heading_level_by = tonumber(shift_input)
  else
    if include_auto then
      -- Auto shift headings
      shift_heading_level_by = last_heading_level
    end
  end

  --- keep track of level before recusion
  local buffer_last_heading_level = last_heading_level

  local blocks = List:new()


  path = md_path(cb.text)

  local fh = io.open(path)
  if not fh then
    not_found_error(cb.text, path, '```')
    suggestion = "Did you run `gen()` when having loaded your module?"
    msg = "ERROR: Cannot find file at " .. path .. " for `" .. cb.text .. "`."
    msg = msg .. ' ' .. suggestion
    msg = { pandoc.CodeBlock(msg) }
    blocks:extend(msg)
  else
    local text = fh:read("*a")
    local contents = pandoc.read(text, format).blocks
    last_heading_level = 0
    -- recursive transclusion
    contents = pandoc.walk_block(
      -- Here, the contents is added as an Any block.
      -- Then, the filter is applied again recursively because
      -- the included file could contain an include again!
      pandoc.Div(contents),
      { Header = update_last_level, CodeBlock = transclude }
      ).content
    --- reset to level before recursion
    last_heading_level = buffer_last_heading_level
    contents = shift_headings(contents, shift_heading_level_by)
    -- Note that contents has type List.
    blocks:extend(contents)
    fh:close()
  end
  ::skip_to_next::
  return blocks
end

local startswith
function startswith(s, start)
   return string.sub(s, 1, s.len(start)) == start
end

--- Filter function for inline code
local transclude_code
function transclude_code(c)
  -- ignore code blocks which do not start with "jl".
  if not startswith(c.text, 'jl ') then
    return
  end

  line = c.text
  line = line:sub(4)
  path = md_path(line)

  local fh = io.open(path)
  if not fh then
    not_found_error(line, path, '`')
    suggestion = "Did you run `gen()` when having loaded your module?"
    msg = "ERROR: Cannot find file at " .. path .. " for `" .. line .. "`."
    msg = msg .. ' ' .. suggestion
    c.text = msg
  else
    text = fh:read("*a")
    -- To retain ticks, use `c.text = text` and `return c`.
    -- Better would be to parse Markdown and test whether the user only
    -- embedded inline Markdown elements such as bold and italic.
    return { pandoc.Str(text) }
  end

  return c
end

return {
  { Meta = get_vars },
  {
    Header = update_last_level,
    CodeBlock = transclude_codeblock,
    Code = transclude_code
  }
}
