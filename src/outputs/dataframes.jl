using DataFrames
using Latexify

function df2markdown(df::DataFrame)::String
    escaped = "ESCAPEDUNDERSCORE"
    sanitize(name) = replace(name, '_' => escaped)
    df = rename(sanitize, df)
    table = Latexify.latexify(df; env=:mdtable, latex=false)
    table = string(table)::String
    table = replace(table, escaped => '_')
end

"""
    convert_output(expr, path, out::DataFrame; caption=nothing, label=nothing)

Convert `out` to Markdown table and set some `pandoc-crossref` metadata.

# Example
```jldoctest
julia> df = DataFrame(A = [1]);

julia> print(Books.convert_output("my_table()", nothing, df))
|   A |
| ---:|
|   1 |

: My table. {#tbl:my_table}
```
"""
function convert_output(
        expr,
        path,
        out::DataFrame;
        caption=missing,
        label=missing,
        link_attributes=missing
    )
    table = df2markdown(out)
    caption, label = caption_label(expr, caption, label)

    if isnothing(caption) && isnothing(label)
        text = string(table)
        return text
    end

    label = isnothing(label) ? "" : "{#tbl:$label}"
    caption = isnothing(caption) ? "" : caption

    return """
        $table
        : $caption $label
        """
end

function convert_output(path, expr, out::DataFrameRow; kwargs...)
    convert_output(path, expr, DataFrame(out); kwargs...)
end
