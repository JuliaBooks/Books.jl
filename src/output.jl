export
    code,
    @c_str

struct Code
    block::AbstractString
end

code(block::AbstractString) = Code(rstrip(block))

macro c_str(block)
    return :(code($block))
end

struct ImageOptions
    caption::String
    label::String
end

function ImageOptions(; caption=nothing, label=nothing)
    ImageOptions(caption, label)
end

function convert_output(path, out::Code)
    block = out.block
    ans = eval(Meta.parse("begin $block end"))
    shown_output = convert_output(path, ans)
    if isa(ans, AbstractString) || isa(ans, Number)
        shown_output = code_block(shown_output)
    end
    """
    ```
    $block
    ```
    $shown_output
    """
end

"""
    convert_output(path, out)

Fallback method for `out::Any`.
Other methods are defined via Requires.
`path` is the path listed in the Pandoc Markdown file.
"""
convert_output(path, out) = string(out)
