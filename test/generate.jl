@testset "generate" begin
    @test code_block("lorem") == """
        ```language-julia
        lorem
        ```
        """

    @test contains(B.convert_output(nothing, nothing, DataFrame(A = [1])), "---")

    I = 1:30
    p = plot(I, I.^2)

    mktemp() do path, io
        @test contains(B.convert_output("tmp", nothing, p), ".png")
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


    evaluated_block = """
        ```jl
        foo
        ```
        """
    @test match(Books.CODEBLOCK_PATTERN, evaluated_block)[1] == "foo"

    # Three indentations should be evaluated.
    evaluated_block = """
           ```jl
           foo
           ```
        """
    @test match(Books.CODEBLOCK_PATTERN, evaluated_block)[1] == "foo"

    function read_outcome(block::AbstractString)
        cd(joinpath(Books.PKGDIR, "docs")) do
            exprs = Books.extract_expr(block)
            userexpr = first(exprs)
            Books.evaluate_and_write(Main, userexpr)
            path = Books.escape_expr(userexpr.expr)
            out = read(path, String)
            return out
        end
    end

    evaluated_block = """
        1. This is a code block in a list with 3 spaces indentation because Pandoc would see it as a nested level otherwise.
           ```jl
           s = "x = 1"
           sco(s)
           ```
        """
    m = match(Books.CODEBLOCK_PATTERN, evaluated_block)
    @test m[1] == "s = \"x = 1\"\n   sco(s)"
    @test m[2] == "   "

    out = strip(read_outcome(evaluated_block))
    @test out == "```language-julia\n   x = 1\n   ```\n   \n   \n   1"

    # Blocks with four indentations should not be evaluated.
    # This functionality is useful for the Books.jl documentation.
    not_evaluated_block = """
            ```jl
            1 + 1
            ```
        """
    @test isempty(Books.extract_expr(not_evaluated_block))
end
