include_regex = r"```{\.include}([\w\W]*?)```"

"""
    include_filenames(s::AbstractString)::Vector

Returns the filenames mentioned in `{.include}` code blocks.
"""
function include_filenames(s::AbstractString)::Vector
    matches = eachmatch(include_regex, s)
    nested_filenames = [split(m[1]) for m in matches]
    vcat(nested_filenames...) 
end

"""
    caller_module(i::Int)

Module of the `i`-th caller.
Thanks to https://discourse.julialang.org/t/get-module-of-a-caller/11445/3
"""
function caller_module(i::Int)
    s = stacktrace()
    s[i].linfo.linetable[1].module
end

function method_name(path)
    name, _ = splitext(basename(path))
    replace(name, '-' => '_')
end

function evaluate_include(path)
    dir = "_generated"
    if dirname(path) != dir
        return nothing
    end
    method = method_name(path)
    println("Running $method for $path")
    M = caller_module(3)
    func = getproperty(M, Symbol(method))
    func(path) 
end

"""
    generate_dynamic_content(M::Module)

Populate the files in `_generated/` by calling the required methods.
These methods are specified by the filename and will output to that filename.
This allows the user to easily link code blocks to code.
"""
function generate_dynamic_content(M::Module)
    ins = inputs()
    evaluate_include.(ins)
end
