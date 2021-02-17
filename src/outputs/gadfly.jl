import Gadfly

inch = Gadfly.inch

function write_svg(file, p; w=6inch, h=4inch) 
    dir = joinpath(build_dir, "im")
    mkpath(dir)
    filename = "$file.svg"
    path = joinpath(dir, filename)
    Gadfly.draw(Gadfly.SVG(path, w, h), p)
    joinpath("im", filename)
end

function convert_output(path, out::Gadfly.Plot)
    file = method_name(path)    
    im_path = write_svg(file, out)
    "![$file](/$im_path)"
end
    
