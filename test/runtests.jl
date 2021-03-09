using Books
using Documenter
using Test

B = Books

if v"1.6.0-rc1" ≤ VERSION
    DocMeta.setdocmeta!(
      Books,
      :DocTestSetup,
      :(using Books; using DataFrames; mkpath(Books.GENERATED_DIR));
      recursive=true
    )
    doctest(Books)
end

include("output.jl")
include("html.jl")
include("generate.jl")
