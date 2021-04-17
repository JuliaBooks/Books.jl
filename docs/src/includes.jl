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

    julia> Books.gen(; M)
    Running example() for _gen/example.md
    Running julia_version() for _gen/julia_version.md
    Running example_plot() for _gen/example_plot.md
    Writing plot images for example_plot
    [...]
    """)

gen_function_docs() = Books.doctest(@doc gen(::Function))

function docs_metadata()
    path = joinpath(pkgdir(BooksDocs), "metadata.yml")
    text = read(path, String)
    code_block(text)
end

function default_metadata()
    path = joinpath(Books.DEFAULTS_DIR, "metadata.yml")
    text = read(path, String)
    code_block(text)
end

function docs_config()
    path = joinpath(pkgdir(BooksDocs), "config.toml")
    text = read(path, String)
    code_block(text)
end

function default_config()
    path = joinpath(Books.DEFAULTS_DIR, "config.toml")
    text = read(path, String)
    code_block(text)
end

my_table() = DataFrame(U = [1, 2], V = [:a, :b], W = [3, 4])

multiple_df_example() =
    Outputs([DataFrame(Z = [3]), DataFrame(U = [4, 5], V = [6, 7])])

sum_example() = code("""
    a = 3
    b = 4

    a + b
    """)

sum_example_definition() = code_block(@code_string sum_example())

example_table() = DataFrame(A = [1, 2], B = [3, 4], C = [5, 6])
example_table_definition() = code_block(@code_string example_table())

function my_data()
    DataFrame(A = [1, 2], B = [3, 4], C = [5, 6], D = [7, 8])
end

function my_data_mean()
    df = my_data()
    Statistics.mean(df.A)
end

options_example() = Options(DataFrame(A = [1], B = [2], C = [3]);
                        caption="My DataFrame", label="foo")

options_example_doctests() = Books.doctest(@doc Books.caption_label)

code_example_table() = code("""
    using DataFrames

    DataFrame(A = [1, 2], B = [3, 4], C = [5, 6])
    """)

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

module_fail() = code("DataFrame(A = [1], B = [2])"; mod=U)

module_fix() = code("""
    using DataFrames

    DataFrame(A = [1], B = [2])"""; mod=U)

module_example_definition() = code_block("""
    module U end
    $(@code_string module_example())
    """)

function example_plot()
    I = 1:30
    Gadfly.plot(x=I, y=I.^2)
end

function multiple_example_plots()
    paths = ["example_plot_$i" for i in 2:3]
    I = 1:30
    objects = [
        plot(x=I, y=I),
        plot(x=I, y=I.^3)
    ]
    Outputs(objects; paths)
end

function image_options_plot()
    I = 1:0.1:30
    p = plot(x=I, y=sin.(I), Geom.line)
    ImageOptions(p; width=6inch, height=2inch)
end

function combined_options_plot()
    imageoptions = image_options_plot()
    Options(imageoptions; caption="Sine function")
end
