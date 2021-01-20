module BooksDocs

import CodeTracking

build_dir = "build"

function sum(a, b, c)
    # Example calculation.
    a + b + c
end

function write_sum()
    definition = """
    a = 3
    b = 4

    a + b
    """
    ans = eval(Meta.parse("begin $definition end"))

    text = """
    ```
    $definition
    ```
    ```
    $ans
    ```
    """

    path = joinpath(build_dir, "sum.md")
    write(path, text)
    path
end

function write_sum_definition()
    code = """
    ```
    $(CodeTracking.@code_string write_sum())

    function build()
        write_sum()
    end
    ```
    """
    path = joinpath(build_dir, "sum-definition.md")
    write(path, code)
    path
end

function build()
    write_sum()
    write_sum_definition()
    nothing
end

end # module
