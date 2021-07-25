--[[
highlight -- pass code block language information to a HTML class.
]]

function CodeBlock(block)
  --local s = pandoc.RawBlock("html", block)
  if block.classes[1] == nil then
    return block
  else
    local class = block.classes[1]
    local text = "<pre class=\"" .. class .. "\">\n<code>" .. block.text .. "</code></pre>"

    return pandoc.RawBlock("html", text)
  end
end

return {
  {CodeBlock = CodeBlock}
}
