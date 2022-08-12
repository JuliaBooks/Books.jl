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
        s = $CodeTracking.@code_string $(f)
        s = $remove_hide_comment(s)
        $code_block(s)
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

function apply_process_post(
        expr,
        out,
        pre::Function,
        process::Union{Nothing,Function},
        post::Function;
        path::Union{Nothing,String}=nothing
    )
    out = pre(out)
    if isnothing(process)
        out = convert_output(expr, path, out)
    else
        out = process(out)
    end
    out = post(out)
    return out
end

"""
    eval_convert(expr::AbstractString, M,
        process::Union{Nothing,Function}=nothing,
        post::Function=identity)

Evaluate `expr` in module `M` and convert the output.
"""
function eval_convert(expr::AbstractString,
        M,
        pre::Union{Nothing,Function}=identity,
        process::Union{Nothing,Function}=nothing,
        post::Union{Nothing,Function}=identity
    )

    ex = Meta.parse("begin $expr end")
    out = Core.eval(M, ex)
    out = apply_process_post(expr, out, pre, process, post)
end

"""
    sco(
        expr::AbstractString;
        M=Main,
        pre::Function=identity,
        process::Union{Nothing,Function}=nothing,
        post::Function=identity
    )

Show code and output for `expr`.
Process the output by applying `pre`, `process` or `post` to it.
Specifically,

- `pre` is applied before `convert_output`
- `process` is applied instead of `convert_output`
- `post` is applied after convert output

For example, for
```julia
let
    pre(out) = Options(out; label="l")
    post = string
    sco("DataFrame(x = [1])"; pre, post)
end
```

the DataFrame will go through three stages:

1. `pre` adds the label "l" to the object
1. `process` is nothing, so `convert_output` will do its usual stuff, namely converting
    the DataFrame object to Markdown.
1. `post` converts the output to a string (even though this is already done by `convert_output` in this case).

So, to disable `convert_output`, pass `process=nothing` or `process=identity`.
"""
function sco(expr::AbstractString;
        M=Main,
        pre::Function=identity,
        process::Union{Nothing,Function}=nothing,
        post::Function=identity
    )
    code = remove_hide_comment(expr)
    code = code_block(strip(code))
    out = eval_convert(expr, M, pre, process, post)
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
precompile(scob, (String,))

"""
    sc(expr::AbstractString; M=Main)

Show only code for `expr`, that is, evaluate `expr` but hide the output.
"""
function sc(expr::AbstractString; M=Main)
    eval_convert(expr, M)
    code = remove_hide_comment(expr)
    code = code_block(strip(code))
end
precompile(sc, (String,))

function sco_macro_helper(
        f::Function,
        types;
        M=Main,
        pre::Function=identity,
        process::Union{Nothing,Function}=nothing,
        post::Function=identity,
        fcall::String=""
    )

    fdef = Books.CodeTracking.code_string(f, types)
    fdef = remove_hide_comment(fdef)
    code = add_method_call(fdef, fcall)
    # Also here, f and types do not contain all the required information.
    ex = Meta.parse(fcall)
    out = Core.eval(M, ex)
    path = escape_expr(fcall)
    out = apply_process_post(fcall, out, pre, process, post; path)
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
    return string(fcall)::String
end

"""
    my_gen_call_with_extracted_types_and_kwargs(__module__, fcn, ex0)

This is a copy from InteractiveUtils.
For some reason, using the one from InteractiveUtils causes objects to be placed inside
`Books.jl`.

For example, when using `my_gen_call_with_extracted_types_and_kwargs`:
```
julia> foo(x) = x

julia> macroexpand(Main, :(@sco pre=foo f(1)))
:(Books.sco_macro_helper(f, (Base.typesof)(1), fcall = "f(1)", pre = foo))
```

And, when using `gen_call_with_extracted_types_and_kwargs`:
```
julia> macroexpand(Main, :(@sco pre=foo f(1)))
:(Books.sco_macro_helper(f, (Base.typesof)(1), fcall = "f(1)", pre = Books.foo))
```
"""
function my_gen_call_with_extracted_types_and_kwargs(__module__, fcn, ex0)
    kws = Expr[]
    arg = ex0[end] # Mandatory argument
    for i in 1:length(ex0)-1
        x = ex0[i]
        if x isa Expr && x.head === :(=) # Keyword given of the form "foo=bar"
            if length(x.args) != 2
                return Expr(:call, :error, "Invalid keyword argument: $x")
            end
            push!(kws, Expr(:kw, esc(x.args[1]), esc(x.args[2])))
        else
            return Expr(:call, :error, "@$fcn expects only one non-keyword argument")
        end
    end
    return gen_call_with_extracted_types(__module__, fcn, arg, kws)
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
    return my_gen_call_with_extracted_types_and_kwargs(__module__, :sco_macro_helper, ex0)
end
