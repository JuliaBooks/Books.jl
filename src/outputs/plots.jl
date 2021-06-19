@debug "Loading Plots.jl support into Books via Requires"

import Plots

function convert_output(expr, path, p::Plots.Plot; caption=nothing, label=nothing)
    im_dir = joinpath(BUILD_DIR, "im")
    mkpath(im_dir)

    if isnothing(path)
        # Not determining some random name here, because it would require cleanups too.
        msg = """
            It is not possible to write an image without specifying a path or filename.
            Use `Options(p; filename=filename)` where `p` is a Plots.jl plot.
            """
        throw(ErrorException(msg))
    end
    file = method_name(expr)

    println("Writing plot images for $file")
    svg_filename = "$file.svg"
    svg_path = joinpath(im_dir, svg_filename)
    Plots.savefig(p, svg_path)

    png_filename = "$file.png"
    png_path = joinpath(im_dir, png_filename)
    Plots.savefig(p, png_path)

    im_link = joinpath("im", svg_filename)
    caption, label = caption_label(path, caption, label)
    pandoc_image(file, png_path; caption, label)
end
