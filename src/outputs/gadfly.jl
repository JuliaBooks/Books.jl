@debug "Loading Gadfly support into Books via Requires"

function convert_output(path, out::Gadfly.Plot; kwargs...)
    convert_gadfly_output(path, out; kwargs...)
end
