import Gadfly
using DataFrames

@testset "generate" begin
    @test code_block("lorem") == """
        ```
        lorem
        ```
        """

    dir = B.GENERATED_DIR
    paths = [
        joinpath(dir, "example.md"),
        joinpath(dir, "example2.md"),
        joinpath(dir, "example3.md")
    ]
    include_text = """
    ```{.include}
    $(paths[1])
    ```

    ```{.include}
    $(paths[2])
    $(paths[3])
    ```
    """
    @test B.include_filenames(include_text) == paths

    @test B.method_name(joinpath(dir, "foo.md")) == "foo"

    @test contains(B.convert_output(nothing, DataFrame(A = [1])), "---")
    mktemp() do path, io
        @test contains(B.convert_output(path, Gadfly.plot()), ".png")
    end

    @test strip(B.convert_output(nothing, code("DataFrame(A = [1])"))) == """
    ```
    DataFrame(A = [1])
    ```
    |   A |
    | ---:|
    |   1 |"""
end

module Foo
    using Books
    using Test

    B = Books

    @test B.caller_module() == Main.Foo

    dir = B.GENERATED_DIR
    function foo()
        "lorem"
    end
    path = joinpath(dir, "foo.md")
    B.evaluate_include(path, nothing, true)
    @test read(path, String) == "lorem"
    rm(dir; force = true, recursive = true)
end
