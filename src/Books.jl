module Books

using Requires

include("html.jl")
include("build.jl")
include("serve.jl")
include("ci.jl")
include("output.jl")
include("generate.jl")

function __init__()
    @require DataFrames="a93c6f00-e57d-5684-b7b6-d8193f3e46c0" include("outputs/dataframes.jl")
    @require Gadfly="c91e804a-d5a3-530f-b6f0-dfbca275c004" include("outputs/gadfly.jl")
end

end # module
