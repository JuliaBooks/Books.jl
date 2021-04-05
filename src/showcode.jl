"""
    sc(method)

Show code for method; to also show output, use [`sco`](@ref).
See the documentation or tests for examples.
"""
macro sc(method)
    esc(quote
        s = Books.CodeTracking.@code_string $(method)
        code_block(s)
    end)
end
