using Books
using Documenter
using Test

B = Books

DocMeta.setdocmeta!(
  Books,
  :DocTestSetup,
  :(using Books);
  recursive=true
)
doctest(Books)

include("output.jl")
include("html.jl")
include("generate.jl")
