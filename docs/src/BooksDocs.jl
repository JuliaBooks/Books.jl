module BooksDocs

import Books
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
    println("Writing $path")
    write(path, text)
    path
end

function write_sum_definition()
    code = """
    ```
    $(CodeTracking.@code_string write_sum())

    function build_all()
        write_sum()
    end
    ```
    """
    path = joinpath(build_dir, "sum-definition.md")
    println("Writing $path")
    write(path, code)
    path
end

function build_all()
    rm(build_dir; force=true, recursive=true)
    mkpath(build_dir)
    write_sum()
    write_sum_definition()
    Books.build_all()
end

end # module
