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
    ImageOptions(object; width=nothing, height=nothing)

Struct containing `width` and `height` for an image.
"""
struct ImageOptions
    object::Any
    width::Any
    height::Any

    ImageOptions(object; width=nothing, height=nothing) = new(object, width, height)
end

function convert_output(expr, path, out::ImageOptions; kwargs...)
    width = out.width
    height = out.height
    convert_output(expr, path, out.object; width, height, kwargs...)
end

function convert_output(expr, path, outputs::AbstractVector)
    path = nothing
    outputs = convert_output.(nothing, nothing, outputs)
    outputs = String.(outputs)
    out = join(outputs, "\n\n")
end

"""
    Options(object;
        filename::Union{AbstractString,Nothing}=nothing,
        caption::Union{AbstractString,Nothing}=nothing,
        label::Union{AbstractString,Nothing}=nothing)

Struct containing an `object` and some meta-information to be passed to the resulting document.
The `caption` and `label` options are used by `pandoc-crossref`.
"""
struct Options
    object::Any
    filename::Union{AbstractString,Nothing}
    caption::Union{AbstractString,Nothing}
    label::Union{AbstractString,Nothing}

    Options(object; filename=nothing, caption=nothing, label=nothing) =
        new(object, filename, caption, label)
end

"""
    Options(object, filename::AbstractString)

Extra constructor for `Options` which is convenient for broadcasting.

```jldoctest
julia> objects = [1, 2];

julia> filenames = ["a", "b"];

julia> Options.(objects, filenames)
2-element Vector{Options}:
 Options(1, "a", nothing, nothing)
 Options(2, "b", nothing, nothing)
```
"""
Options(object, filename::AbstractString) = Options(object; filename)

function convert_output(expr, path, out::Code)::String
    block = out.block
    mod = out.mod
    ans = try
        Core.eval(mod, Meta.parse("begin $block end"))
    catch e
        string(e)
    end
    shown_output = convert_output(expr, path, ans)
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
    convert_output(expr, path, options::Options)

Convert `options.object` while taking `options.caption` and `options.label` into account.
This method needs to pass the options correctly to the resulting type, because the syntax depends on the type;
see the `pandoc-crossref` documentation for more information on the syntax.

# Example
```jldoctest
julia> df = DataFrame(A = [1]);

julia> caption = "My DataFrame";

julia> options = Options(df; caption);

julia> print(Books.convert_output(nothing, nothing, options))
|   A |
| ---:|
|   1 |

: My DataFrame
```
"""
function convert_output(expr, path, opts::Options)::String
    object = opts.object
    filename = opts.filename
    if !isnothing(filename)
        expr = filename
    end
    path = nothing
    caption = opts.caption
    label = opts.label
    convert_output(expr, path, object; caption, label)
end

"""
    convert_output(expr, path, out::AbstractString)

Return `out` as string.
This avoids the adding of `"` which `show` does by default.
"""
convert_output(expr, path, out::AbstractString) = string(out)

convert_output(expr, path, out::Number) = string(out)

"""
    convert_output(expr, path, out)

Fallback method for `out::Any`.
This passes the objects through show to use the overrides that package creators might have provided.

# Example

```jldoctest
julia> using MCMCChains

julia> chn = Chains([1]; info=(start_time=[1.0], stop_time=[1.0]));

julia> string(chn)
"MCMC chain (1×1×1 Array{Int64, 3})"

julia> out = Books.convert_output("", "", chn);

julia> contains(out, "Summary Statistics")
true
```
"""
function convert_output(expr, path, out)::String
    io = IOBuffer()
    mime = MIME("text/plain")
    show(io, mime, out)
    out = String(take!(io))
    # This is required for MCMCChains, but it would be nicer if the user could specify this.
    out = code_block(out)
end

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
julia> Books.pandoc_image("example_image", "_build/im/example_image.png")
"![](_build/im/example_image.png)"
```
"""
function pandoc_image(file, path; caption=nothing, label=nothing)
    if isnothing(caption) && isnothing(label)
        "![]($path)"
    elseif isnothing(label)
        "![$caption]($path)"
    elseif isnothing(caption)
        "![]($path){#fig:$label}"
    else
        "![$caption]($path){#fig:$label}"
    end
end

"""
    caption_label(expr, caption, label)

Return `caption` and `label` for the inputs.
This method sets some reasonable defaults if any of the inputs is missing.

# Examples
```jldoctest
julia> Books.caption_label("foo_bar()", nothing, nothing)
(caption = "Foo bar", label = "foo_bar")

julia> Books.caption_label("foo_bar()", "My caption", nothing)
(caption = "My caption", label = "foo_bar")

julia> Books.caption_label(nothing, "cap", nothing)
(caption = "cap", label = nothing)

julia> Books.caption_label(nothing, nothing, "my_label")
(caption = "My label", label = "my_label")

julia> Books.caption_label(nothing, nothing, nothing)
(caption = nothing, label = nothing)
```
"""
function caption_label(expr, caption, label)
    if isnothing(expr) && isnothing(caption) && isnothing(label)
        return (caption=nothing, label=nothing)
    end

    if !isnothing(expr)
        name = method_name(expr)
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
