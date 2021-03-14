using DataFrames
using Latexify

function convert_output(path, out::DataFrame)
    table = Latexify.latexify(out; env=:mdtable, latex=false)
    if isnothing(path)
        string(table)
    else
        name = method_name(path)
        caption = prettify_caption(name)
        """
        $table
        : $caption {#tbl:$name}
        """
    end
end
