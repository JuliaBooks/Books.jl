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

--- Filter function for code blocks
local transclude
function transclude (cb)
  -- ignore code blocks which are not of class "include".
  if not cb.classes:includes 'gen' then
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
  for line in cb.text:gmatch('[^\n]+') do
    if line:sub(1,2) ~= '//' then
      path_sep = package.config:sub(1,1)

      -- Escape all weird characters to ensure they can be in the file.
      -- This yields very weird names, but luckily the code is only internal.
      escaped = line
      escaped = escaped:gsub("%(", "OB")
      escaped = escaped:gsub("%)", "CB")
      escaped = escaped:gsub("\"", "DQ")

      path = "_gen" .. path_sep .. escaped .. ".md"
      local fh = io.open(path)
      if not fh then
        io.stderr:write("Cannot find file `" .. path .. "` for `" .. line .. "` | Skipping includes\n")
      else
        local contents = pandoc.read(fh:read '*a', format).blocks
        last_heading_level = 0
        -- recursive transclusion
        contents = pandoc.walk_block(
          pandoc.Div(contents),
          { Header = update_last_level, CodeBlock = transclude }
          ).content
        --- reset to level before recursion
        last_heading_level = buffer_last_heading_level
        blocks:extend(shift_headings(contents, shift_heading_level_by))
        fh:close()
      end
    end
  end
  return blocks
end

return {
  { Meta = get_vars },
  { Header = update_last_level, CodeBlock = transclude }
}
