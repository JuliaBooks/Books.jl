sc_test_function(x) = x

@testset "showcode" begin
    s = @sc sc_test_function(3)
    @test s == """
        ```
        sc_test_function(x) = x
        ```
        """
end
