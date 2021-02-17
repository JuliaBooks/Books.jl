using DataFrames

@testset "generate" begin
    dir = "_generated"
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

    @test contains(B.convert_output(DataFrame(A = [1])), "---")
end

module Foo
    using Books
    using Test

    @test Books.caller_module() == Main.Foo

    dir = "_generated"
    function foo()
        "lorem"
    end
    path = joinpath(dir, "foo.md")
    Books.evaluate_include(path, nothing, true)
    @test read(path, String) == "lorem"
    rm(dir; force = true, recursive = true)
end
