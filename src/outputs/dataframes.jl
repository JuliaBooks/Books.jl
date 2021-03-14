using DataFrames
using Latexify

"""
    caption_label(path, caption, label)

Return `caption` and `label` for the inputs.
This method sets some reasonable defaults if any of the inputs is missing.

```jldoctest
julia> Books.caption_label("a/foo_bar.md", nothing, nothing)
(caption = "Foo bar", label = "foo_bar")

julia> Books.caption_label(nothing, "cap", nothing)
(caption = "cap", label = nothing)

julia> Books.caption_label(nothing, nothing, "my_label")
(caption = "My label", label = "my_label")

julia> Books.caption_label(nothing, nothing, nothing)
(caption = nothing, label = nothing)
"""
function caption_label(path, caption, label)
    if isnothing(path) && isnothing(caption) && isnothing(label)
        return (caption=nothing, label=nothing)
    end

    if !isnothing(path)
        name = method_name(path)
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
    convert_output(path, out::DataFrame; caption=nothing, label=nothing)

Convert `out` to Markdown table and set some `pandoc-crossref` metadata.

```jldoctest
julia> df = DataFrame(A = [1])

julia> print(Books.convert_output("a/my_table.md", df))
|   A |
| ---:|
|   1 |

: My table {#tbl:my_table}
"""
function convert_output(path, out::DataFrame; caption=nothing, label=nothing)::String
    table = Latexify.latexify(out; env=:mdtable, latex=false)
    caption, label = caption_label(path, caption, label)

    if isnothing(caption) && isnothing(label)
        return string(table)
    end

    if !isnothing(label)
        return """
        $table
        : $caption {#tbl:$label}
        """
    end

    if !isnothing(caption)
        return """
        $table
        : $caption
        """
    end
end
