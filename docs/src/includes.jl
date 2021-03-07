serve_example() = code_block(raw"""
    $ julia --project -e 'using Books; serve()'
    Watching ./pandoc/favicon.png
    Watching ./src/plots.jl
    [...]
     ✓ LiveServer listening on http://localhost:8001/ ...
      (use CTRL+C to shut down)
    """)

generate_example() = code_block(raw"""
    $ julia --project -e  'using Books; using Foo; M = Foo'

    julia> Books.generate_content(; M)
    Running example() for _generated/example.md
    Running julia_version() for _generated/julia_version.md
    Running example_plot() for _generated/example_plot.md
    Writing plot images for example_plot
    [...]
    """)

generate_content_function_docs() = Books.doctest(@doc generate_content(::Function))

function default_metadata()
    path = joinpath(Books.DEFAULTS_DIR, "metadata.yml")
    text = read(path, String)
    code_block(text)
end

function default_config()
    path = joinpath(Books.DEFAULTS_DIR, "config.toml")
    text = read(path, String)
    code_block(text)
end

df_example() = DataFrame(X = [1, 2], Y = ["a", "b"])
df_example_def() = code_block(@code_string df_example())

multiple_df_example() =
    outputs([DataFrame(Z = [3]), DataFrame(U = [4, 5], V = [6, 7])])
multiple_df_example_def() = code_block(@code_string multiple_df_example())

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

function multiple_example_plots()
    paths = ["example_plot_$i" for i in 2:3]
    X = 1:30
    objects = [
        plot(x = X, y = X),
        plot(x = X, y = X.^3)
    ]
    outputs(paths, objects)
end
multiple_example_plots_def() = code_block(@code_string multiple_example_plots())
