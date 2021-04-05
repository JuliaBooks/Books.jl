struct Code
    block::AbstractString
    mod::Module
    hide_module::Bool
end

"""
    code(block::AbstractString; mod=Main, hide_module=false)

Define a code `block` which needs to be evaluated in module `mod`.
By default, the module in which the code is evaluated is shown above the code block.
This can be disabled via `hide_module`.
"""
code(block::AbstractString; mod=Main, hide_module=false) =
    Code(rstrip(block), mod, hide_module)

"""
    Outputs(objects::AbstractVector; paths::AbstractVector=nothing)

Define `objects` which need to be converted to Markdown.
This is done via `convert_output(path, out::T)`, where `T` is the appropriate type.
"""
struct Outputs
    objects::AbstractVector
    paths::AbstractVector

    function Outputs(objects::AbstractVector; paths=nothing)
        if isnothing(paths)
            paths = fill(nothing, length(objects))
        end
        new(objects, paths)
    end
end

"""
    ImageOptions(object; width=nothing, height=nothing)

Struct containing `width` and `height` for an image.
"""
struct ImageOptions
    object::Any
    width::Any
    height::Any

    ImageOptions(object; width=nothing, height=nothing) = new(object, width, height)
end

function convert_output(path, out::ImageOptions; kwargs...)
    width = out.width
    height = out.height
    convert_output(path, out.object; width, height, kwargs...)
end

"""
    Options(object;
        caption::Union{AbstractString,Nothing}=nothing,
        label::Union{AbstractString,Nothing}=nothing)

Struct containing an `object` and some meta-information to be passed to the resulting document.
These options are used by `pandoc-crossref`.
"""
struct Options
    object::Any
    caption::Union{AbstractString,Nothing}
    label::Union{AbstractString,Nothing}

    Options(object; caption=nothing, label=nothing) = new(object, caption, label)
end

function convert_output(path, out::Code)::String
    block = out.block
    mod = out.mod
    ans = try
        Core.eval(mod, Meta.parse("begin $block end"))
    catch e
        string(e)
    end
    shown_output = convert_output(path, ans)
    if isa(ans, AbstractString) || isa(ans, Number)
        shown_output = code_block(shown_output)
    end

    mod_info = mod == Main || out.hide_module ? "" :
        """
        ```{=html}
        <span class="books-list-module">
            module: $mod
        </span>
        ```
        \\begin{flushright}
            \\tiny
            module: $mod
            \\normalsize
        \\end{flushright}
        """
    """
    $mod_info
    ```
    $block
    ```
    $shown_output
    """
end

"""
    convert_output(path, outputs::Outputs)::String

Convert multiple objects, such as DataFrames or plots.
"""
function convert_output(path, outputs::Outputs)::String
    itr = zip(outputs.paths, outputs.objects)
    converted = [convert_output(path, obj) for (path, obj) in itr]
    join(converted, "\n\n")
end

"""
    convert_output(path, options::Options)

Convert `options.object` while taking `options.caption` and `options.label` into account.
This method needs to pass the options correctly to the resulting type, because the syntax depends on the type;
see the `pandoc-crossref` documentation for more information on the syntax.

# Example
```jldoctest
julia> df = DataFrame(A = [1]);

julia> caption = "My DataFrame";

julia> options = Options(df; caption);

julia> print(Books.convert_output(nothing, options))
|   A |
| ---:|
|   1 |

: My DataFrame
```
"""
function convert_output(path, opts::Options)::String
    convert_output(path, opts.object;
        caption=opts.caption, label=opts.label)
end

"""
    convert_output(path, out)

Fallback method for `out::Any`.
Other methods are defined via Requires.
`path` is the path listed in the Pandoc Markdown file.
"""
convert_output(path, out) = string(out)

"""
    prettify_caption(caption)

Return prettier caption.

```jldoctest
julia> Books.prettify_caption("example_table")
"Example table"
```
"""
function prettify_caption(caption)
    caption = replace(caption, '_' => ' ')
    caption = uppercasefirst(caption)
end

"""
    pandoc_image(file, path; caption=nothing, label=nothing)

Return pandoc image link where label is prepended with `#fig:`.
This path works for PDF and is fixed for html in the html post-processor.

# Example
```jldoctest
julia> Books.pandoc_image("example_image", "build/im/example_image.png")
"![](build/im/example_image.png)"
```
"""
function pandoc_image(file, path; caption=nothing, label=nothing)
    if isnothing(caption) && isnothing(label)
        "![]($path)"
    elseif isnothing(label)
        "![$caption.]($path)"
    elseif isnothing(caption)
        "![]($path){#fig:$label}"
    else
        "![$caption.]($path){#fig:$label}"
    end
end

"""
    caption_label(path, caption, label)

Return `caption` and `label` for the inputs.
This method sets some reasonable defaults if any of the inputs is missing.

# Examples
```jldoctest
julia> Books.caption_label("a/foo_bar.md", nothing, nothing)
(caption = "Foo bar", label = "foo_bar")

julia> Books.caption_label("a/foo_bar.md", "My caption", nothing)
(caption = "My caption", label = "foo_bar")

julia> Books.caption_label(nothing, "cap", nothing)
(caption = "cap", label = nothing)

julia> Books.caption_label(nothing, nothing, "my_label")
(caption = "My label", label = "my_label")

julia> Books.caption_label(nothing, nothing, nothing)
(caption = nothing, label = nothing)
```
"""
function caption_label(path, caption, label)
    if isnothing(path) && isnothing(caption) && isnothing(label)
        return (caption=nothing, label=nothing)
    end

    if !isnothing(path)
        name, suffix = method_name(path)
        if isnothing(label)
            label = name
        end
        if isnothing(caption)
            caption = prettify_caption(name)
        end
        return (caption=caption, label=label)
    end

    if !isnothing(label)
        if isnothing(caption)
            caption = prettify_caption(label)
        end
        return (caption=caption, label=label)
    end

    if !isnothing(caption)
        return (caption=caption, label=label)
    end
end

"""
    docstring(s::Markdown.MD)

Return docstring, as obtained from `@doc f` for function `f`, to be parsed by Pandoc.
Needs work to be made prettier.
"""
function docstring(s::Markdown.MD)
    lines = split(string(s), '\n')
    ignore(line) = any([
        contains(line, "```")
    ])
    filter!(!ignore, lines)
    # lines = ["> $line" for line in lines]
    text = join(lines, '\n')
    """
    <pre>
    $text
    </pre>
    """
end

"""
    doctest(s::Markdown.MD)

Return jldoctest, as obtained from `@doc f` for function `f`.
"""
function doctest(s::Markdown.MD)
    s = string(s)
    start = findfirst("```jldoctest", s).start
    stop = findlast("```", s).stop
    content = s[start:stop]
    lines = split(content, '\n')
    lines = lines[2:end-1]
    content = join(lines, '\n')
    code_block(content)
end
