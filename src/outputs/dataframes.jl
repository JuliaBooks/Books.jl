using DataFrames
using Latexify

"""
    convert_output(path, out::DataFrame; caption=nothing, label=nothing)

Convert `out` to Markdown table and set some `pandoc-crossref` metadata.

# Example
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
