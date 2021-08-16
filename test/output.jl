@testset "output" begin
    V = ["a", "b"]
    out = Books.convert_output(missing, missing, V)
    @test out == output_block(string(V))

    df = DataFrame(foo_bar_baz = [1])
    out = Books.convert_output(missing, missing, df)
    # Without escaping the underscores (_), Latexify would change _ to *.
    @test contains(out, "foo_bar_baz")
end
