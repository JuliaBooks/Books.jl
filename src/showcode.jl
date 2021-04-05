"""
    @sc(f)

Show code for `f()`; to also show output, use [`@sco`](@ref).
See the documentation or tests for examples.
"""
macro sc(f)
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

function convert_output(path, cf::CodeAndFunction)
    code = cf.code
    f = cf.f
    out = f()
    out = convert_output(path, out)
    """
    $code
    $out
    """
end
