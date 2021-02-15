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
