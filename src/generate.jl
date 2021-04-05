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

Return method name and suffix for a Markdown file.
Here, the suffix is used to allow users to specify that, for example, `@sc` has to be called on the method.

# Example
```jldoctest
julia> path = "_gen/foo_bar.md";

julia> Books.method_name(path)
("foo_bar", "")

julia> path = "_gen/foo_bar-sc.md";

julia> Books.method_name(path)
("foo_bar", "sc")
```
"""
function method_name(path::AbstractString)
    name, extension = splitext(basename(path))
    suffix = ""
    if contains(name, '-')
        parts = split(name, '-')
        if length(parts) != 2
            error("Path name is expected to contain at most one - (minus)")
        end
        name = parts[1]
        suffix = parts[2]
    end
    (name, suffix)
end

"""
    evaluate_and_write(f::Function, path, suffix::AbstractString)

Evaluates `f`, converts the output writes the output to `path`.
Some output conversions will also write to other files, which the file at `path` links to.
For example, this happens with plots.

# Example
```jldoctest
julia> using DataFrames

julia> example_table() = DataFrame(A = [1, 2], B = [3, 4])
example_table (generic function with 1 method)

julia> path = joinpath(tempdir(), "example.md");

julia> Books.evaluate_and_write(example_table, path, "")
Running example_table() for /tmp/example.md

julia> print(read(path, String))
|   A |   B |
| ---:| ---:|
|   1 |   3 |
|   2 |   4 |

: Example {#tbl:example}
```
"""
function evaluate_and_write(f::Function, path, suffix::AbstractString)
    println("Running $(f)() for $path")
    out =
        suffix == "sc" ? @sc(f) :
        suffix == "sco" ? @sco(f) :
        f()
    out = convert_output(path, out)
    write(path, out)
    nothing
end

function evaluate_and_write(M::Module, path)
    method, suffix = method_name(path)
    println("Running $(method)() for $path")
    f = getproperty(M, Symbol(method))
    evaluate_and_write(f, path, suffix)
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
    if isnothing(M)
        M = caller_module()
    end
    mkpath(dirname(path))
    if fail_on_error
        evaluate_and_write(M, path)
    else
        try
            evaluate_and_write(M, path)
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
After calling the methods, this method will also call `html()` to update the site when `call_html=true`.

The module `M` is used to locate the method defined, as a string, in the `.include` via `getproperty`.
"""
function gen(; M=nothing, fail_on_error=false, project="default", call_html=true)
    paths = inputs(project)
    if !isfile(first(paths))
        error("Couldn't find input file. Is there a valid project in your current working directory?")
    end
    included_paths = vcat([include_filenames(read(path, String)) for path in paths]...)
    f(path) = evaluate_include(path, M, fail_on_error)
    foreach(f, included_paths)
    if call_html
        println("Updating html")
        html(; project)
    end
end

"""
    gen(f::Function; fail_on_error=false, project="default", call_html=true)

Populate the file in $(Books.GENERATED_DIR) by calling `func`.
This method is useful during development to quickly see the effect of updating your code.
Use with Revise.jl and optionally `Revise.entr`.
After calling `f`, this method will also call `html()` to update the site when `call_html=true`.

# Example
```jldoctest
julia> module Foo
       version() = "This book is built with Julia \$VERSION"
       end;

julia> gen(Foo.version)
Running version() for _gen/version.md
```
"""
function gen(f::Function; fail_on_error=false, project="default", call_html=true)
    path = joinpath(GENERATED_DIR, "$f.md")
    suffix = ""
    evaluate_and_write(f, path, suffix)
    if call_html
        println("Updating html")
        html(; project)
    end
end
