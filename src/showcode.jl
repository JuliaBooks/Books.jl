"""
    @sc(f)

Show code for `f()`; to also show output, use [`@sco`](@ref).
See the documentation or tests for examples.
"""
macro sc(f)
    println("Obtaining source code for $f()")
    esc(quote
        s = Books.CodeTracking.@code_string $(f)()
        code_block(s)
    end)
end

"""
    CodeAndFunction(code::AbstractString, f::Function)

This struct is used by [`@sco`](@ref).
"""
struct CodeAndFunction
    code::AbstractString
    f::Function
end

"""
    @sco(f)

Show code and output for `f()`; to show only code, use [`@sc`](@ref).
See the documentation or tests for examples.
"""
macro sco(f)
    esc(quote
        code = @sc $(f)
        CodeAndFunction(code, $(f))
    end)
end

function convert_output(expr, path, cf::CodeAndFunction)
    code = cf.code
    f = cf.f
    out = f()
    out = convert_output(expr, path, out)
    """
    $code
    $out
    """
end


"""
    CodeAndOutput(code::AbstractString)

This struct is used by [`sco`](@ref).
"""
struct CodeAndOutput
    code::AbstractString
end

"""
    eval_convert(expr::AbstractString)

Evaluate `expr` and convert the output.
This should be evaluated inside the correct module since it is typically called
inside `Core.eval(M, ex)` in `generate.jl`.
"""
function eval_convert(expr::AbstractString, M)
    ex = Meta.parse("begin $expr end")
    out = Core.eval(M, ex)
    out = convert_output(expr, nothing, out)
end

"""
    sco(expr::AbstractString; M=Main)

Show code and output for `expr`.
"""
function sco(expr::AbstractString; M=Main)
    out = eval_convert(expr, M)
    code = code_block(lstrip(expr))
    """
    $code

    $out
    """
end

"""
    sc(expr::AbstractString; M=Main)

Show only code for `expr`, that is, evaluate `expr` but hide the output.
"""
function sc(expr::AbstractString; M=Main)
    eval_convert(expr, M)
    code_block(lstrip(expr))
end
