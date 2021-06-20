
"""
    code_block(s)

Wrap `s` in a Markdown code block with triple backticks.
"""
code_block(s) = "```\n$s\n```\n"

function extract_codeblock_expr(s)
end

extract_expr_example() = """
    lorem
    ```jl
    foo(3)
    ```
    ipsum `jl bar()` dolar
    """

"""
    extract_expr(s::AbstractString)::Vector

Returns the filenames mentioned in the `jl` code blocks.
Here, `s` is the contents of a Markdown file.

```jldoctest
julia> s = Books.extract_expr_example();

julia> Books.extract_expr(s)
2-element Vector{String}:
 "foo(3)"
 "bar()"
```
"""
function extract_expr(s::AbstractString)::Vector
    codeblock_pattern = r"```jl\s*([\w\W]*?)```"
    matches = eachmatch(codeblock_pattern, s)
    function clean(m)
        m = m[1]
        m = strip(m)
        m = string(m)::String
    end
    from_codeblocks = clean.(matches)

    inline_pattern = r" `jl ([^`]*)`"
    matches = eachmatch(inline_pattern, s)
    from_inline = clean.(matches)
    E = [from_codeblocks; from_inline]

    function check_parse_errors(expr)
        try
            Meta.parse(expr)
        catch e
            error("Exception occured when trying to parse `$expr`")
        end
    end
    check_parse_errors.(E)
    E
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
    method_name(expr::String)

Return file name for `expr`.
This is used for things like how to call an image file and a caption.

# Examples
```jldoctest
julia> Books.method_name("@some_macro(foo)")
"foo"

julia> Books.method_name("foo()")
"foo"

julia> Books.method_name("foo(3)")
"foo_3"

julia> Books.method_name("Options(foo(); caption='b')")
"Options_foo__captionis-b-"
```
"""
function method_name(expr::String)
    remove_macros(expr) = replace(expr, r"@[\w\_]*" => "")
    expr = remove_macros(expr)
    # These rewrites are not reversible, because they do not have to be.
    expr = replace(expr, '(' => '_')
    expr = replace(expr, ')' => "")
    expr = replace(expr, ';' => "_")
    expr = replace(expr, " " => "")
    expr = replace(expr, '"' => "-")
    expr = replace(expr, '\'' => "-")
    expr = replace(expr, '=' => "is")
    expr = replace(expr, '.' => "")
    expr = strip(expr, '_')
end

"""
    escape_expr(expr::String)

Escape an expression to the corresponding path.
The logic in this method should match the logic in the Lua filter.
"""
function escape_expr(expr::String)
    replace_map = [
        '(' => "-ob-",
        ')' => "-cb-",
        '"' => "-dq-",
        ':' => "-fc-",
        ';' => "-sc-",
        '@' => "-ax-"
    ]
    escaped = reduce(replace, replace_map; init=expr)
    joinpath(GENERATED_DIR, "$escaped.md")
end

function evaluate_and_write(M::Module, expr::String)
    path = escape_expr(expr)
    println("Writing output of `$expr` to $path")

    ex = Meta.parse(expr)
    out = Core.eval(M, ex)
    out = convert_output(expr, path, out)
    out = string(out)::String
    write(path, out)

    nothing
end

function evaluate_and_write(f::Function)
    function_name = Base.nameof(f)
    expr = "$(function_name)()"
    path = escape_expr(expr)
    println("Writing output of `$expr` to $path")
    out = f()
    out = convert_output(expr, path, out)
    out = string(out)::String
    write(path, out)

    nothing
end

"""
    evaluate_include(expr::String, M::Module, fail_on_error::Bool)

For a `path` included in a Markdown file, run the corresponding function and write the output to `path`.
"""
function evaluate_include(expr::String, M::Module, fail_on_error::Bool)
    if isnothing(M)
        # This code isn't really working.
        M = caller_module()
    end
    if fail_on_error
        evaluate_and_write(M, expr)
    else
        try
            evaluate_and_write(M, expr)
        catch e
            @error """
            Failed to run code for $path.
            Details:
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
    mkpath(GENERATED_DIR)
    paths = inputs(project)
    first_file = first(paths)
    if !isfile(first_file)
        error("Couldn't find $first_file. Is there a valid project in your current working directory?")
    end
    included_expr = vcat([extract_expr(read(path, String)) for path in paths]...)
    f(expr) = evaluate_include(expr, M, fail_on_error)
    foreach(f, included_expr)
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
Writing output of `version()` to _gen/version-ob--cb-.md
Updating html
```
"""
function gen(f::Function; project="default", call_html=true)
    path = joinpath(GENERATED_DIR, "$f.md")
    mkpath(GENERATED_DIR)
    evaluate_and_write(f)
    if call_html
        println("Updating html")
        html(; project)
    end
end
