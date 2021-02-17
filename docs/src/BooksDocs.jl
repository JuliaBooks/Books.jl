module BooksDocs

import Latexify

using Books
using CodeTracking
using DataFrames

export build_all

sum_example() = c"""
    a = 3
    b = 4

    a + b
    """

sum_example_definition() = code_block(@code_string sum_example())

example_table() = DataFrame(A = [1, 2], B = [3, 4])
example_table_definition() = code_block(@code_string example_table()) 

code_example_table() = c"""
    using DataFrames

    DataFrame(A = [1, 2], B = [3, 4])
    """

code_example_table_definition() = code_block(@code_string code_example_table())

julia_version() = "This method is defined to work around a bug in the regex."

julia_version_example() = """
```
This book is built with Julia $VERSION.
```"""

function build_all()
    Books.generate_dynamic_content(; M=BooksDocs, fail_on_error=true)
    Books.build_all()
end

end # module
