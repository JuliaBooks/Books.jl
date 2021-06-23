module BooksDocs

import IOCapture
import Latexify
import MCMCChains
import Statistics
import TOML

using Reexport
@reexport using AlgebraOfGraphics
@reexport using Books
@reexport using CairoMakie
@reexport using CodeTracking
@reexport using DataFrames
@reexport using Dates
@reexport using Plots

plot = Plots.plot

include("includes.jl")

function build()
    Books.gen(; fail_on_error=true)
    extra_head = "<!-- Example comment placed in the html header. -->"
    Books.build_all(; extra_head)
end

end # module
