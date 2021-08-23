@info "Loading Plots.jl support into Books via Requires"

import Plots

function convert_output(expr, path, p::Plots.Plot; caption=missing, label=missing)
    im_dir = joinpath(BUILD_DIR, "im")
    mkpath(im_dir)

    file = plotting_filename(expr, path, "Plots.jl")

    println("Writing plot images for $file")
    svg_filename = "$file.svg"
    svg_path = joinpath(im_dir, svg_filename)
    Plots.savefig(p, svg_path)

    png_filename = "$file.png"
    png_path = joinpath(im_dir, png_filename)
    Plots.savefig(p, png_path)

    im_link = joinpath("im", svg_filename)
    caption, label = caption_label(expr, caption, label)
    pandoc_image(file, png_path; caption, label)
end
