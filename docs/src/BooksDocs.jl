module BooksDocs

import Latexify

using Books
using CodeTracking
using DataFrames
using Gadfly

sum_example() = code("""
    a = 3
    b = 4

    a + b
    """)

sum_example_definition() = code_block(@code_string sum_example())

example_table() = DataFrame(A = [1, 2], B = [3, 4])
example_table_definition() = code_block(@code_string example_table()) 

code_example_table() = code("""
    using DataFrames

    DataFrame(A = [1, 2], B = [3, 4])
    """)

code_example_table_definition() = code_block(@code_string code_example_table())

julia_version() = "This method is defined to work around a bug in the regex."

julia_version_example() = """
```
This book is built with Julia $VERSION.
```"""

module U end

function module_example()
    code("x = 3"; mod=U)
end

module_call_x() = code("x"; mod=U)

module_fail() = code("DataFrame(A = [1])"; mod=U)

module_fix() = code("""
    using DataFrames 

    DataFrame(A = [1])"""; mod=U)

module_example_definition() = code_block("""
    module U end
    $(@code_string module_example())
    """)

example_plot() = code("""
    using Gadfly

    X = 1:30
    plot(x = X, y = X.^2)
    """)

function build()
    Books.generate_dynamic_content(; M=BooksDocs, fail_on_error=true)
    Books.build_all()
end

end # module
