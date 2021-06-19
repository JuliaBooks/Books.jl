@debug "Loading AlgebraOfGraphics.jl support into Books via Requires"

using AlgebraOfGraphics
using CairoMakie

function convert_output(expr, path, fg::AlgebraOfGraphics.FigureGrid; caption=nothing, label=nothing)
    im_dir = joinpath(BUILD_DIR, "im")
    mkpath(im_dir)

    if isnothing(path)
        # Not determining some random name here, because it would require cleanups too.
        msg = """
            It is not possible to write an image without specifying a path.
            Use `Options(p; filename=filename)` where `p` is a AlgebraOfGraphics plot.
            """
        throw(ErrorException(msg))
    end
    file = store_filename(expr)

    println("Writing plot images for $file")
    svg_filename = "$file.svg"
    svg_path = joinpath(im_dir, svg_filename)
    # Explicit rm due to https://github.com/JuliaIO/FileIO.jl/issues/338.
    rm(svg_path; force=true)
    AlgebraOfGraphics.save(svg_path, fg)

    png_filename = "$file.png"
    png_path = joinpath(im_dir, png_filename)
    rm(png_path; force=true)
    px_per_unit = 3 # Ensure high resolution.
    AlgebraOfGraphics.save(png_path, fg; px_per_unit)

    im_link = joinpath("im", svg_filename)
    caption, label = caption_label(path, caption, label)
    pandoc_image(file, png_path; caption, label)
end
