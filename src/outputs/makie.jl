@debug "Loading Makie.jl support into Books via Requires"

using CairoMakie
import Makie

function convert_output(expr, path, p::Makie.FigureAxisPlot; caption=missing, label=missing)
    im_dir = joinpath(BUILD_DIR, "im")
    mkpath(im_dir)

    file = plotting_filename(expr, path, "Makie.jl")

    println("Writing plot images for $file")
    svg_filename = "$file.svg"
    svg_path = joinpath(im_dir, svg_filename)
    # Explicit rm due to https://github.com/JuliaIO/FileIO.jl/issues/338.
    rm(svg_path; force=true)
    Makie.FileIO.save(svg_path, p)

    png_filename = "$file.png"
    png_path = joinpath(im_dir, png_filename)
    rm(png_path; force=true)
    px_per_unit = 3 # Ensure high resolution.
    Makie.FileIO.save(png_path, p; px_per_unit)

    im_link = joinpath("im", svg_filename)
    caption, label = caption_label(expr, caption, label)
    pandoc_image(file, png_path; caption, label)
end
