@testset "generate" begin
    paths = [
        joinpath("_generated", "example.md"),
        joinpath("_generated", "example2.md"),
        joinpath("_generated", "example3.md")
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

end

module Foo
    using Books
    using Test

    dir = "_generated"
    function foo(path)
        mkpath(dirname(path))
        write(path, "lorem")
    end
    path = joinpath(dir, "foo.md")
    Books.evaluate_include(path)
    @test read(path, String) == "lorem"
    rm(dir; force = true, recursive = true)
end
