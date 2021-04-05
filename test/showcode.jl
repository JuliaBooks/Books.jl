sc_test_function() = 1

@testset "showcode" begin
    s = @sc sc_test_function
    @test s == """
        ```
        sc_test_function() = 1
        ```
        """
end
