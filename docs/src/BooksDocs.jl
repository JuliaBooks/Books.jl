module BooksDocs

import Latexify

using Books
using CodeTracking
using DataFrames

function sum_example()
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
end

sum_example_definition() = code_block(@code_string sum_example())

function Books.convert_output(out::DataFrame)
    string(Latexify.latexify(out; env=:mdtable, latex=false))
end

example_table() = DataFrame(A = [1, 2], B = [3, 4])
example_table_definition() = code_block(@code_string example_table()) 

convert_output_definition() = code_block(@code_string Books.convert_output(DataFrame()))

function build_all()
    Books.generate_dynamic_content(; M=BooksDocs, fail_on_error=true)
    Books.build_all()
end

julia_version() = "This method is defined to work around a bug in the regex."

julia_version_example() = """
```
This book is built with Julia $VERSION.
```"""

end # module
