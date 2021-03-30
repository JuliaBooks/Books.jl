include_regex = r"```{\.include}([\w\W]*?)```"

"""
    code_block(s)

Wrap `s` in a Markdown code block with triple backticks.
"""
code_block(s) = "```\n$s\n```\n"

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

"""
    method_name(path::AbstractString)

Return method name for a Markdown file.

# Example
```jldoctest
julia> path = "_gen/example.md";

julia> Books.method_name(path)
"example"
```
"""
function method_name(path::AbstractString)
    name, _ = splitext(basename(path))
    name
end

"""
    evaluate_and_write(f::Function, path)

Evaluates `f`, converts the output writes the output to `path`.
Some output conversions will also write to other files, which the file at `path` links to.
For example, this happens with plots.

# Example
```jldoctest
julia> using DataFrames

julia> example_table() = DataFrame(A = [1, 2], B = [3, 4])
example_table (generic function with 1 method)

julia> path = joinpath(tempdir(), "example.md");

julia> Books.evaluate_and_write(example_table, path)
Running example_table() for /tmp/example.md

julia> print(read(path, String))
|   A |   B |
| ---:| ---:|
|   1 |   3 |
|   2 |   4 |

: Example {#tbl:example}
```
"""
function evaluate_and_write(f::Function, path)
    println("Running $(f)() for $path")
    out = f()
    out = convert_output(path, out)
    write(path, out)
    nothing
end

function evaluate_and_write(method_name, M::Module, path)
    println("Running $(method_name)() for $path")
    f = getproperty(M, Symbol(method_name))
    evaluate_and_write(f, path)
end

"""
    evaluate_include(path, M, fail_on_error)

For a `path` included in a chapter file, run the corresponding function and write the output to `path`.
"""
function evaluate_include(path, M, fail_on_error)
    if dirname(path) != GENERATED_DIR
        println("Not running code for $path")
        return nothing
    end
    method = method_name(path)
    if isnothing(M)
        M = caller_module()
    end
    mkpath(dirname(path))
    if fail_on_error
        evaluate_and_write(method, M, path)
    else
        try
            evaluate_and_write(method, M, path)
        catch e
            @error """
            Failed to run code for $path:
            $(rethrow())
            """
        end
    end
end

"""
    gen(; M=nothing, fail_on_error=false, project="default")

Populate the files in `$(Books.GENERATED_DIR)/` by calling the required methods.
These methods are specified by the filename and will output to that filename.
This allows the user to easily link code blocks to code.
The methods are assumed to be in the module `M` of the caller.
Otherwise, specify another module `M`.

The module `M` is used to locate the method defined, as a string, in the `.include` via `getproperty`.
"""
function gen(; M=nothing, fail_on_error=false, project="default")
    paths = inputs(project)
    included_paths = vcat([include_filenames(read(path, String)) for path in paths]...)
    f(path) = evaluate_include(path, M, fail_on_error)
    foreach(f, included_paths)
end

"""
    gen(f::Function; fail_on_error=false)

Populate the file in $(Books.GENERATED_DIR) by calling `func`.
This method is useful during development to quickly see the effect of updating your code.
Use with Revise.jl and optionally `Revise.entr`.

# Example
```jldoctest
julia> module Foo
       version() = "This book is built with Julia \$VERSION"
       end;

julia> gen(Foo.version)
Running version() for _gen/version.md
```
"""
function gen(f::Function; fail_on_error=false)
    path = joinpath(GENERATED_DIR, "$f.md")
    evaluate_and_write(f, path)
end
