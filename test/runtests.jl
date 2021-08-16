import Pkg

using Books
using DataFrames
using Documenter
using Test

B = Books

DocMeta.setdocmeta!(
  Books,
  :DocTestSetup,
  :(using Books;
    cd(joinpath(pkgdir(Books), "docs"));
    mkpath(Books.GENERATED_DIR);
    using DataFrames);
  recursive=true
)

if VERSION in Pkg.Types.VersionRange(v"1.6", v"1.6.10")
    doctest(Books)
end

@testset "Books.jl" begin
    include("output.jl")
    include("build.jl")
    include("html.jl")
    include("showcode.jl")
    include("generate.jl")
end
