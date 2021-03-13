include("compose.jl")

function convert_output(path, out::Gadfly.Plot)
    convert_gadfly_output(path, out)
end
