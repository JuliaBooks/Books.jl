@testset "output" begin
    V = ["a", "b"]
    out = Books.convert_output(missing, missing, V)
    @test out == output_block(string(V))

    df = DataFrame(foo_bar_baz = [1])
    out = Books.convert_output(missing, missing, df)
    # Without escaping the underscores (_), Latexify would change _ to *.
    @test contains(out, "foo_bar_baz")

    p = plot(1:30, 1:30)
    filename = "plotstest"
    opts = Options(p; filename)
    out = Books.convert_output(missing, missing, opts)
    @test out == "![Plotstest.](_build/im/plotstest.png){#fig:plotstest}"

    link_attributes = "width=50%"
    opts = Options(p; filename, link_attributes)
    out = Books.convert_output(missing, missing, opts)
    @test out == "![Plotstest.](_build/im/plotstest.png){width=50% #fig:plotstest}"
end
