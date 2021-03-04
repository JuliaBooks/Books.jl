include_regex = r"```{\.include}([\w\W]*?)```"

code_block(s) = """
```
$s
```
"""

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
    caller_module()

Walks up the stacktrace to find the first module which is not Books.
Thanks to https://discourse.julialang.org/t/get-module-of-a-caller/11445/3
"""
function caller_module()
    s = stacktrace()
    for i in 1:10
        try
            M = s[i].linfo.linetable[1].module
            return M
        catch
        end
    end
    throw(ErrorException("Couldn't determine the module of the caller"))
end

function method_name(path)
    name, _ = splitext(basename(path))
    name
end

function evaluate_and_write(M::Module, method, path)
    func = getproperty(M, Symbol(method))
    out = func()
    out = convert_output(path, out)
    write(path, out)
end

generated_dir = "_generated"

"""
    evaluate_include(path, fail_on_error)

For a `path` included in a chapter file, run the corresponding function and write the output to `path`.
This way, the user can easily test/develop their `func` by calling `func()` in the REPL.
"""
function evaluate_include(path, M, fail_on_error)
    dir = generated_dir
    if dirname(path) != dir
        println("Not running code for $path")
        return nothing
    end
    method = method_name(path)
    println("Running $method for $path")
    if isnothing(M)
        M = caller_module()
    end
    mkpath(dirname(path))
    if fail_on_error
        evaluate_and_write(M, method, path)
    else
        try
            evaluate_and_write(M, method, path)
        catch e
            @error "Failed to run code for $path:\n $e"
            write(path, code_block(string(e)))
        end
    end
end

"""
    generate_dynamic_content(; M=nothing, fail_on_error=false)

Populate the files in `_generated/` by calling the required methods.
These methods are specified by the filename and will output to that filename.
This allows the user to easily link code blocks to code.
The methods are assumed to be in the module `M` of the caller.
Otherwise, specify another module `M`.

The module `M` is used to locate the method defined, as a string, in the `.include` via `getproperty`.
"""
function generate_dynamic_content(; M=nothing, fail_on_error=false)
    ins = inputs()
    included_paths = vcat([include_filenames(read(x, String)) for x in ins]...)
    f(path) = evaluate_include(path, M, fail_on_error)
    foreach(f, included_paths)
end
