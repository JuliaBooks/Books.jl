```
function Books.convert_output(out::DataFrame)
    string(Latexify.latexify(out; env=:mdtable, latex=false))
end
```
