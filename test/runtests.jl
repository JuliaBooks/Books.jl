using Books
using Documenter
using Test

B = Books

DocMeta.setdocmeta!(
  Books,
  :DocTestSetup,
  :(using Books; using DataFrames);
  recursive=true
)
doctest(Books)

include("output.jl")
include("html.jl")
include("showcode.jl")
include("generate.jl")
