module BooksDocs

import Latexify
import MCMCChains
import Statistics
import TOML

using AlgebraOfGraphics
using Books
using CairoMakie
using CodeTracking
using DataFrames
using Dates

include("includes.jl")

function build()
    Books.gen(; M=BooksDocs, fail_on_error=true)
    Books.build_all()
end

end # module
