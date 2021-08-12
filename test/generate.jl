using AlgebraOfGraphics
using CairoMakie
using DataFrames

@testset "generate" begin
    @test code_block("lorem") == """
        ```language-julia
        lorem
        ```
        """

    @test contains(B.convert_output(nothing, nothing, DataFrame(A = [1])), "---")

    X = 1:30
    df = (x=X, y=X.*2)
    xy = data(df) * mapping(:x, :y)
    fg = draw(xy)

    mktemp() do path, io
        @test contains(B.convert_output("tmp", nothing, fg), ".png")
    end
    im_dir = joinpath(B.BUILD_DIR, "im")
    rm(im_dir; force=true, recursive=true)

    @test strip(B.convert_output(nothing, nothing, code("DataFrame(A = [1])"))) == """
        ```
        DataFrame(A = [1])
        ```
        |   A |
        | ---:|
        |   1 |"""


    valid_block = """
        ```jl
        foo
        ```
        """
    @test match(Books.CODEBLOCK_PATTERN, valid_block)[1] == "foo"

    invalid_block = """
        <pre>
        ```jl
        foo
        ```
        </pre>
        """
    @test match(Books.CODEBLOCK_PATTERN, invalid_block) === nothing
end

module Foo
    using Books
    using Test

    B = Books

    @test B.caller_module() == Main.Foo

    foo() = "lorem"
    fail_on_error = true
    # Broken for some reason.
    # B.evaluate_include("foo()", Foo, fail_on_error)
    # path = joinpath(B.GENERATED_DIR, "foo-ob--cb-.md")
    # mkpath(B.GENERATED_DIR)
    # @test read(path, String) == "lorem"
    # rm(dir; force=true, recursive=true)
end
