@testset "output" begin
    V = ["a", "b"]
    out = Books.convert_output(missing, missing, V)
    @test out == code_block(string(V))
end
