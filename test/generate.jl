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

    invalid_block = """
        <pre class="language-julia">
        ```jl
        x = 1 + 1
        ```
        </pre>
        which is displayed as
        ```jl
        x = 1 + 1
        ```
        """
    @test !contains(match(Books.CODEBLOCK_PATTERN, invalid_block).match, "pre")

    valid_block = """
        1. This is a code block in a list with 3 spaces indentation because Pandoc would see it as a nested level otherwise.
           ```jl
           s = "x = 1"
           sco(s)
           ```
        """
    m = match(Books.CODEBLOCK_PATTERN, valid_block)
    @test m[1] == "s = \"x = 1\"\n   sco(s)"
    @test m[2] == "   "

    out = cd(joinpath(Books.PROJECT_ROOT, "docs")) do
        userexpr = first(Books.extract_expr(valid_block))
        Books.evaluate_and_write(Main, userexpr)
        path = Books.escape_expr(userexpr.expr)
        out = read(path, String)
        return out
    end
    @test out == "   ```language-julia\n   x = 1\n   ```\n   \n   1\n   "
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
