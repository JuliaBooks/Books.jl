using DataFrames
using Latexify

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

: My table {#tbl:my_table}
```
"""
function convert_output(expr, path, out::DataFrame; caption=missing, label=missing)::String
    table = Latexify.latexify(out; env=:mdtable, latex=false)
    caption, label = caption_label(expr, caption, label)

    if isnothing(caption) && isnothing(label)
        return string(table)
    end

    label = isnothing(label) ? "" : "{#tbl:$label}"
    caption = isnothing(caption) ? "" : caption

    return """
        $table
        : $caption $label
        """
end
