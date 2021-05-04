using Books
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
doctest(Books)

@testset "Books.jl" begin
  include("output.jl")
  include("html.jl")
  include("showcode.jl")
  include("generate.jl")
end
