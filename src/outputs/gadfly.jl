import Gadfly

inch = Gadfly.inch

function write_svg(path, p; w=6inch, h=4inch) 
    Gadfly.draw(Gadfly.SVG(path, w, h), p)
end

"""
    svg2png(svg_path, png_path)
Unlike ImageMagick, this program gets the text spacing right.
"""
function svg2png(svg_path, png_path)
    run(`cairosvg $svg_path -o $png_path`)
end

function convert_output(path, out::Gadfly.Plot)
    im_dir = joinpath(build_dir, "im")
    mkpath(im_dir)

    file = method_name(path)
    println("Writing plot images for $file")
    svg_filename = "$file.svg"
    svg_path = joinpath(im_dir, svg_filename)
    write_svg(svg_path, out)
    png_filename = "$file.png"
    png_path = joinpath(im_dir, png_filename)
    svg2png(svg_path, png_path)
    im_link = joinpath("im", svg_filename)
    # This path is fixed in the html post-processor.
    "![$file]($png_path)"
end
