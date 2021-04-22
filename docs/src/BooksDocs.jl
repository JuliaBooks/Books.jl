module BooksDocs

import Latexify
import MCMCChains
import Statistics
import TOML

using Books
using CodeTracking
using DataFrames
using Dates
using Gadfly

include("includes.jl")

function build()
    Books.gen(; M=BooksDocs, fail_on_error=true)
    Books.build_all()
end

end # module
