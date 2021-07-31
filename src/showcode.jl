"""
    remove_hide_comment(expr::AbstractString)

Remove lines which end with `# hide`.
"""
function remove_hide_comment(expr::AbstractString)
    expr = string(expr)::String
    lines = split(expr, '\n')
    lines = rstrip.(lines)
    lines = filter(!endswith("# hide"), lines)
    expr = join(lines, '\n')
end

"""
    @sc(f)

Show code for function `f`; to also show output, use [`@sco`](@ref).
"""
macro sc(f)
    esc(quote
        s = Books.CodeTracking.@code_string $(f)
        s = Books.remove_hide_comment(s)
        Books.code_block(s)
    end)
end

"""
    add_method_call(code)

Show
```
f(x) = x
f(1)
```
when calling `sco f(1)` and not only `f(x) = x`.
"""
function add_method_call(fdef, fcall)
    fcall = remove_modules(fcall)
    out = """
        $fdef
        $fcall
        """
    out = code_block(strip(out))
end

function apply_process_post(expr, out, process::Union{Nothing,Function}, post::Function;
        path::Union{Nothing,String}=nothing)
    out = isnothing(process) ? convert_output(expr, path, out) : process(out)
    out = post(out)
end

"""
    eval_convert(expr::AbstractString, M,
        process::Union{Nothing,Function}=nothing,
        post::Function=identity)

Evaluate `expr` in module `M` and convert the output.
"""
function eval_convert(expr::AbstractString, M,
        process::Union{Nothing,Function}=nothing,
        post::Union{Nothing,Function}=identity)

    ex = Meta.parse("begin $expr end")
    out = Core.eval(M, ex)
    out = apply_process_post(expr, out, process, post)
end

"""
    sco(expr::AbstractString;
    M=Main, process::Union{Nothing,Function}=nothing,
    post::Function=identity)

Show code and output for `expr`.
Process the output by applying `post` or `convert_output` to it.
Then, post-process the output by applying `post` to it.
"""
function sco(expr::AbstractString;
        M=Main,
        process::Union{Nothing,Function}=nothing,
        post::Function=identity)
    code = remove_hide_comment(expr)
    code = code_block(strip(code))
    out = eval_convert(expr, M, process, post)
    """
    $code
    $out
    """
end

"""
    scob(expr::AbstractString; M=Main)

Show code and output in a block for `expr`.
"""
function scob(expr::AbstractString; M=Main)
    post = output_block
    sco(expr; M, post)
end

"""
    sc(expr::AbstractString; M=Main)

Show only code for `expr`, that is, evaluate `expr` but hide the output.
"""
function sc(expr::AbstractString; M=Main)
    eval_convert(expr, M)
    code = remove_hide_comment(expr)
    code = code_block(strip(code))
end

function sco(f::Function, types; M=Main, process::Union{Nothing,Function}=nothing,
        post::Function=identity, fcall="")

    fdef = Books.CodeTracking.code_string(f, types)
    fdef = remove_hide_comment(fdef)
    code = add_method_call(fdef, fcall)
    # Also here, f and types do not contain all the required information.
    ex = Meta.parse(fcall)
    out = Core.eval(M, ex)
    path = escape_expr(fcall)
    out = apply_process_post(fcall, out, process, post; path)
    """
    $code
    $out
    """
end

"""
    extract_function_call(ex0)

Extract function call before `gen_call_with_extracted_types_and_kwargs` throws this information away.
"""
function extract_function_call(ex0)
    fcall = ex0[end]  # Mandatory argument according to Julia source code.
    string(fcall)::String
end

"""
    @sco(f::Function, types;
        process::Union{Nothing,Function}=nothing, post::Function=identity)

Show code and output for `f()`; to show only code, use [`@sc`](@ref).
See [`sco`](@ref) for more information about `process` and `post`.
"""
macro sco(ex0...)
    fcall = extract_function_call(ex0)
    ex0 = (:(fcall = $fcall), ex0...)
    InteractiveUtils.gen_call_with_extracted_types_and_kwargs(__module__, :sco, ex0)
end

