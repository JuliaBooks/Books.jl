function homepage_intro()
    books_project_path = joinpath(pkgdir(Books), "Project.toml")
    project_info = read(books_project_path, String)
    project_info = TOML.parse(project_info)

    books_version = project_info["version"]
    text = """
    This website introduces and demonstrates the package
    [Books.jl](https://github.com/rikhuijzer/Books.jl){target="_blank"}
    at version $books_version and is available as
    [**PDF**](/books.pdf){target="_blank"}
    and
    [docx](/books.docx){target="_blank"}.
    These pages were built on $(today()) with Julia $VERSION.
    """
end
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

multiple_df_vector() =
    [DataFrame(Z = [3]), DataFrame(U = [4, 5], V = [6, 7])]

function multiple_df_example()
    objects = [
        DataFrame(X = [3, 4], Y = [5, 6]),
        DataFrame(U = [7, 8], V = [9, 10])
    ]
    filenames = ["a", "b"]
    Options.(objects, filenames)
end

sum_example() = code("""
    a = 2
    b = 3

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
    df = (x=I, y=I.^2)
    xy = data(df) * mapping(:x, :y)
    fg = draw(xy)
end

function multiple_example_plots()
    paths = ["example_plot_$i" for i in 2:3]
    I = 1:30
    df = (x=I, y=I.*2, z=I.^3)
    objects = [
        draw(data(df) * mapping(:x, :y))
        draw(data(df) * mapping(:x, :z))
    ]
    Options.(objects, paths)
end

function image_options_plot()
    I = 1:0.1:30
    df = (x=I, y=sin.(I))
    xy = data(df) * visual(Lines) * mapping(:x, :y)
    axis = (width = 600, height = 140)
    draw(xy; axis)
end

function combined_options_plot()
    fg = image_options_plot()
    Options(fg; caption="Sine function")
end

chain() = MCMCChains.Chains([1])
