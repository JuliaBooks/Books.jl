module BooksDocs

import Latexify

using Books
using CodeTracking
using DataFrames
using Gadfly

include("includes.jl")

function build()
    Books.gen(; M=BooksDocs, fail_on_error=true)
    Books.build_all()
end

end # module
