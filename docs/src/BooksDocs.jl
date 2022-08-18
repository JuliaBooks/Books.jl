module BooksDocs

import Books
import IOCapture
import Latexify
import Statistics
import TOML

using Reexport
@reexport using Books
@reexport using CairoMakie:
    Axis,
    CairoMakie,
    lines,
    scatter,
    scatterlines!
@reexport using CodeTracking
@reexport using DataFrames
@reexport using Dates
@reexport using FileIO: FileIO
@reexport using Plots: Plot, plot, savefig

using CairoMakie.Makie: Figure, FigureAxisPlot

const MAKIE_PLOT_TYPES = Union{Figure, FigureAxisPlot}
function _makie_save(path::String, p)
    try
        FileIO.save(path, p; px_per_unit=3)
    catch e
        # Explicit rm due to https://github.com/JuliaIO/FileIO.jl/issues/338.
        rm(path; force=true)

        file, ext = splitext(path)
        # SVG will fail with GLMakie and that is okay.
        # It doesn't matter since Books.jl will only use SVG if the file is available, otherwise PNG.
        if ext != ".svg"
            @error "Failed to save Makie image" exception=(e, catch_backtrace())
        end
    end
end

Books.is_image(plot::MAKIE_PLOT_TYPES) = true
Books.svg(svg_path::String, p::MAKIE_PLOT_TYPES) = _makie_save(svg_path, p)
Books.png(png_path::String, p::MAKIE_PLOT_TYPES) = _makie_save(png_path, p)

Books.is_image(plot::Plot) = true
Books.svg(svg_path::String, p::Plot) = savefig(p, svg_path)
Books.png(png_path::String, p::Plot) = savefig(p, png_path)

include("includes.jl")

function build()
    fail_on_error = true
    Books.gen(; fail_on_error)
    Books.build_all(; fail_on_error)
end

end # module
