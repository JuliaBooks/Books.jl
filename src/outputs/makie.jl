@debug "Loading Makie.jl support into Books via Requires"

using CairoMakie
import Makie

function convert_output(
        expr,
        path,
        p::Union{Makie.Figure, Makie.FigureAxisPlot};
        caption=missing,
        label=missing
    )

    im_dir = joinpath(BUILD_DIR, "im")
    mkpath(im_dir)

    file = plotting_filename(expr, path, "Makie.jl")

    println("Writing plot images for $file")
    png_filename = "$file.png"
    png_path = joinpath(im_dir, png_filename)
    # Explicit rm due to https://github.com/JuliaIO/FileIO.jl/issues/338.
    rm(png_path; force=true)
    px_per_unit = 3 # Ensure high resolution.
    Makie.FileIO.save(png_path, p; px_per_unit)

    svg_filename = "$file.svg"
    svg_path = joinpath(im_dir, svg_filename)
    rm(svg_path; force=true)
    im_link = joinpath("im", svg_filename)
    try
        # SVG doesn't work with GLMakie.
        Makie.FileIO.save(svg_path, p)
    catch
        # Even when the SVG saving fails, Makie creates an image of 0 bytes.
        rm(svg_path; force=true)
        im_link = joinpath("im", png_filename)
    end

    caption, label = caption_label(expr, caption, label)
    pandoc_image(file, png_path; caption, label)
end
