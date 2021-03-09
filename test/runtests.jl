using Books
using Documenter
using Test

B = Books

DocMeta.setdocmeta!(
  Books,
  :DocTestSetup,
  :(using Books; using DataFrames; mkpath(Books.GENERATED_DIR));
  recursive=true
)
doctest(Books)

include("output.jl")
include("html.jl")
include("generate.jl")
