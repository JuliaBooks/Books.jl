sc_test_function() = 1

@testset "showcode" begin
    s = @sc sc_test_function()
    fdef = "sc_test_function() = 1"
    @test s == code_block(fdef)

    s = sco("x = 3")
    @test s == "```language-julia\nx = 3\n```\n\n3\n"
    s = sco("""
        y = 2 # hide
        x = 3
        """)
    @test s == "```language-julia\nx = 3\n```\n\n3\n"

    s = sco(raw"""
        x = 3
        "x = $x"
        """)

    s = @sco sc_test_function()
    @test s == """
        ```language-julia
        sc_test_function() = 1
        sc_test_function()
        ```

        1
        """
end

function remove_line(s::String, i::Int)
    lines = split(s, '\n')
    lines = [lines[1:i-1]; lines[i+1:end]]
    join(lines, '\n')
end

@testset "@sco consistent with sco" begin
    process(x) = x + 1
    post = output_block

    with_macro = @sco(process=(x -> x + 1), post=output_block, sc_test_function())
    without_macro = sco("sc_test_function()", process=(x -> x + 1), post=output_block)

    # Remove the function definition.
    with_macro = remove_line(with_macro, 2)

    @test with_macro == without_macro
end
