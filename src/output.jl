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
    paths::AbstractVector
    objects::AbstractVector

    function Outputs(objects::AbstractVector; paths::AbstractVector=nothing)
        if isnothing(paths)
            fill(nothing, length(objects))
        end
        new(paths, objects)
    end
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
    pandoc_image(file, path; caption=nothing, ref=nothing)

Return pandoc image link.

# Example
```jldoctest
julia> Books.pandoc_image("example_image", "/im/example_image.png")
"![Example image.](/im/example_image.png){#fig:example_image}"
```
"""
function pandoc_image(file, path; caption=nothing, ref=nothing)
    if isnothing(caption)
        caption = prettify_caption(file)
    end

    if isnothing(ref)
        ref = "fig:$file"
    end

    "![$caption.]($path){#$ref}"
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

