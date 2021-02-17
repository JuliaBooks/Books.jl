using DataFrames
using Latexify

function convert_output(path, out::DataFrame)
    string(Latexify.latexify(out; env=:mdtable, latex=false))
end
