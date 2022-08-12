module BooksDocs

import Books
import IOCapture
import Latexify
import Statistics
import TOML

using Reexport
@reexport using Books
@reexport using CairoMakie
@reexport using CodeTracking
@reexport using DataFrames
@reexport using Dates
@reexport using Plots

plot = Plots.plot
scatter = CairoMakie.scatter

const MAKIE_PLOT_TYPES = Union{CairoMakie.Makie.Figure, CairoMakie.Makie.FigureAxisPlot}
Books.is_image(plot::MAKIE_PLOT_TYPES) = true

function makie_save(path::String, p)
    px_per_unit = 3
    CairoMakie.FileIO.save(path, p; px_per_unit)
end

Books.svg(svg_path::String, p::MAKIE_PLOT_TYPES) = makie_save(svg_path, p)
Books.png(png_path::String, p::MAKIE_PLOT_TYPES) = makie_save(png_path, p)

Books.is_image(plot::Plots.Plot) = true
Books.svg(svg_path::String, p::Plots.Plot) = savefig(p, svg_path)
Books.png(png_path::String, p::Plots.Plot) = savefig(p, png_path)

include("includes.jl")

function build()
    fail_on_error = true
    Books.gen(; fail_on_error)
    Books.build_all(; fail_on_error)
end

end # module
