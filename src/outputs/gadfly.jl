include("compose.jl")

function convert_output(path, out::Gadfly.Plot; caption=nothing, label=nothing)
    convert_gadfly_output(path, out; caption, label)
end
