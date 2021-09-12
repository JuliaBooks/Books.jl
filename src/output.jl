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

function convert_output(expr, path, outputs::AbstractVector{AbstractString})
    out = join(outputs, "\n")
    out = output_block(out)
end

function convert_output(expr, path, outputs::AbstractVector)
    t = eltype(outputs)
    # Not doing this distinction in the method signature,
    # because it would be hard to read.
    if t <: AbstractString || t <: Number
        out = string(outputs)::String
        out = output_block(out)
    else
        path = nothing
        outputs = convert_output.(nothing, nothing, outputs)
        outputs = String.(outputs)
        # Adding a backslach on a newline to avoid a bug in Pandoc/Crossref
        # where section labels are not always added.
        sep = """\n
            ```{=comment}
            This comment is placed between and behind outputs to clearly separate blocks in
            order to avoid a bug with cross-references in Pandoc/Crossref.
            ```\n
            """
        out = join(outputs, sep) * sep
    end
end

"""
    Options(object;
        filename::Union{AbstractString,Nothing,Missing}=missing,
        caption::Union{AbstractString,Nothing,Missing}=missing,
        label::Union{AbstractString,Nothing,Missing}=missing)

Struct containing an `object` and some meta-information to be passed to the resulting document.
The `caption` and `label` options are used by `pandoc-crossref`.
"""
struct Options
    object::Any
    filename::Union{AbstractString,Nothing,Missing}
    caption::Union{AbstractString,Nothing,Missing}
    label::Union{AbstractString,Nothing,Missing}
    link_attributes::Union{AbstractString,Nothing,Missing}

    function Options(object;
        filename=missing,
        caption=missing,
        label=missing,
        link_attributes=missing
    )
        return new(object, filename, caption, label, link_attributes)
    end
end

"""
    Options(object, filename::AbstractString)

Extra constructor for `Options` which is convenient for broadcasting.

```jldoctest
julia> objects = [1, 2];

julia> filenames = ["a", "b"];

julia> Options.(objects, filenames)
2-element Vector{Options}:
 Options(1, "a", missing, missing)
 Options(2, "b", missing, missing)
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
        shown_output = output_block(shown_output)
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

function plotting_filename(expr, path, package::String)
    if path isa AbstractString
        file = basename(path)
        file, _ = splitext(file)
        file = string(file)::String
    elseif expr isa AbstractString
        file = method_name(expr)
    else
        # Not determining some random name here, because it would require cleanups too.
        msg = """
            Couldn't determine a path for the image.
            Use `Options(p; filename=filename)` where `p` is a $package plot.
            """
        throw(ErrorException(msg))
    end
    string(file)::String
end

"""
    convert_output(expr, path, options::Options)

Convert `options.object` while taking `options.caption` and `options.label` into account.
This method needs to pass the options correctly to the resulting type, because the syntax depends on the type;
see the `pandoc-crossref` documentation for more information on the syntax.

# Example
```jldoctest
julia> df = DataFrame(A = [1]);

julia> caption = "My DataFrame.";

julia> options = Options(df; caption);

julia> print(Books.convert_output(missing, missing, options))
|   A |
| ---:|
|   1 |

: My DataFrame.
```
"""
function convert_output(expr, path, opts::Options)::String
    object = opts.object
    filename = opts.filename
    if !isnothing(filename) || !ismissing(filename)
        expr = filename
    else
        # The path is where the md should be written to; not things like images.
        name, _ = splitext(path)
        expr = string(basename(name))::String
    end
    caption = opts.caption
    label = opts.label
    link_attributes = opts.link_attributes
    convert_output(expr, path, object; caption, label, link_attributes)
end

"""
    convert_output(expr, path, out::AbstractString)

Return `out` as string.
This avoids the adding of `"` which `show` does by default.
"""
convert_output(expr, path, out::AbstractString) = string(out)

convert_output(expr, path, out::Number) = string(out)

"""
    catch_show(out)

Catch the output from `show` for object `out`.
"""
function catch_show(out)
    io = IOBuffer()
    mime = MIME("text/plain")
    show(io, mime, out)
    out = String(take!(io))
    # This is required for MCMCChains, but it would be nicer if the user could specify this.
    out = output_block(out)
end

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
    catch_show(out)
end

"""
    without_caption_label(out::Any)

Convert output, but suppress captions and labels.
"""
function without_caption_label(out::Any)
    convert_output(nothing, nothing, out)
end

"""
    prettify_caption(caption)

Return prettier caption.

```jldoctest
julia> Books.prettify_caption("example_table")
"Example table."
```
"""
function prettify_caption(caption)
    caption = replace(caption, '_' => ' ')
    caption = uppercasefirst(caption)
    caption = caption * '.'
end

"""
    pandoc_image(file, path; caption=nothing, label=nothing, link_attributes=nothing)

Return pandoc image link where label is prepended with `#fig:`.
This path works for PDF and is fixed for html in the html post-processor.

# Example
```jldoctest
julia> Books.pandoc_image("example_image", "_build/im/example_image.png")
"![](_build/im/example_image.png)"
```
"""
function pandoc_image(file, path; caption=nothing, label=nothing, link_attributes=nothing)
    if ismissing(link_attributes) || isnothing(link_attributes)
        link_attributes = ""
    end
    if !isnothing(label)
        link_attributes *= " #fig:$label"
    end
    link_attributes = strip(link_attributes)
    if isnothing(caption)
        caption = ""
    end

    return "![$caption]($path){$link_attributes}"
end

"""
    caption_label(expr, caption, label)

Return `caption` and `label` for the inputs.
This method sets some reasonable defaults if any of the inputs is nothing or missing.
In this context, `nothing` forces a parameter to be empty, whereas `missing` allows the
parameter to be inferred.
The elements of the output named tuple are never of type `Missing`.

# Examples

```jldoctest
julia> Books.caption_label("foo_bar()", missing, missing)
(caption = "Foo bar.", label = "foo_bar")

julia> Books.caption_label("foo_bar()", "My caption.", missing)
(caption = "My caption.", label = "foo_bar")

julia> Books.caption_label("foo_bar()", "My caption.", nothing)
(caption = "My caption.", label = nothing)

julia> Books.caption_label(missing, "My caption.", missing)
(caption = "My caption.", label = nothing)

julia> Books.caption_label(missing, missing, "my_label")
(caption = "My label.", label = "my_label")

julia> Books.caption_label(missing, missing, missing)
(caption = nothing, label = nothing)
```
"""
function caption_label(expr, caption, label)
    if ismissing(expr) && ismissing(caption) && ismissing(label)
        return (caption=nothing, label=nothing)
    end

    original_caption = caption
    original_label = label

    if !ismissing(expr) && !isnothing(expr)
        name = method_name(expr)
        if ismissing(label)
            label = name
        end
        if ismissing(caption)
            caption = prettify_caption(name)
        end
    end

    if !ismissing(label) && !isnothing(label)
        if ismissing(caption)
            caption = prettify_caption(label)
        end
    end

    if isnothing(original_caption) || ismissing(caption)
        caption = nothing
    end

    if isnothing(original_label) || ismissing(label)
        label = nothing
    end

    return (caption=caption, label=label)
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
    output_block(content)
end
