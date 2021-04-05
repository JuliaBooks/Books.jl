sc_test_function() = 1

@testset "showcode" begin
    s = @sc sc_test_function
    code = "sc_test_function() = 1"
    @test s == code_block(code)

    s = @sco sc_test_function
    @test s.code == code
    @test s.f == sc_test_function
end
