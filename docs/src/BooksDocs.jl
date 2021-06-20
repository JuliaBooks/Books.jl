module BooksDocs

import IOCapture
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
using Plots

# Defaulting plot to Plots; Makie can use Makie.plot.
plot = Plots.plot

include("includes.jl")

function build()
    Books.gen(; M=BooksDocs, fail_on_error=true)
    extra_head = "<!-- Example comment placed in the html header. -->"
    Books.build_all(; extra_head)
end

end # module
