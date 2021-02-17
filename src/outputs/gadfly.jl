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

    mktempdir() do dir
        svg_path = joinpath(dir, "tmp.svg")
        write_svg(svg_path, out)
        file = method_name(path)
        png_filename = "$file.png"
        png_path = joinpath(im_dir, png_filename)
        svg2png(svg_path, png_path)
        im_path = joinpath("im", png_filename)
    end
end
