# Demo {#sec:demo}

We can refer to a section with the normal [pandoc-crossref](https://lierdakil.github.io/pandoc-crossref/){target="_blank"} syntax.
For example,

```language-markdown
See @sec:getting-started.
```

> See @sec:getting-started.

We can refer to citations such as @orwell1945animal and [@orwell1949nineteen] or to equations such as @eq:example.

$$ y = \frac{\sin{x}}{\cos{x}} $$ {#eq:example}

To show your TeX equations, surround them by double dollar signs (`e.g., $$ x = 3 $$`) for display math and by single dolor sign (e.g., `$x = 3$`) for inline math.

## Embedding output {#sec:embedding-output}

For embedding code, you can use the `jl` inline code or code block.
For example, to show the Julia version, define a code block like

    ```jl
    YourModule.julia_version()
    ```

in a Markdown file.
Then, in your package, define the method `julia_version()`:

```
julia_version() = "This book is built with Julia $VERSION."
```

Next, call `using Books, MyPackage` and `gen()` to run all the defined in the Markdown files.
If you prefer to be less explicit, you can call `gen(; M=YourModule)` to allow for:

    ```jl
    julia_version()
    ```

instead of `YourModule.julia_version()`.
When passing your module `M` as keyword argument, `Books.jl` will evaluate all code blocks inside that module.

Alternatively, if you work on a large project and want to only generate the output for one or more Markdown files in `contents/`, such as `index.md`, use

```language-julia
gen("index")
```

Calling `gen` will place the text

```jl
BooksDocs.julia_version_example()
```

at the right path so that it can be included by Pandoc.
You can also embed output inline with single backticks like

```
`jl YourModule.julia_version()`
```

or just call Julia's constant `VERSION` directly from within the Markdown file.
For example,

```language-markdown
This book is built with Julia `jl "$(BACKTICK)jl VERSION$(BACKTICK)"`.
```

This book is built with Julia `jl VERSION`.

While doing this, it is expected that you also have the browser open and a server running, see @sec:getting-started.
That way, the page is immediately updated when you run `gen`.

Note that it doesn't matter where you define the function `julia_version`, as long as it is in your module.
To save yourself some typing, and to allow yourself to get some coffee while Julia gets up to speed, you can start Julia for your package with

```
$ julia --project -ie 'using MyPackage'
```

which allows you to re-generate all the content by calling

```
julia> gen()
```

To run this method automatically when you make a change in your package, ensure that you loaded [`Revise.jl`](https://github.com/timholy/Revise.jl) before loading your package and run

```language-julia
entr(gen, ["contents"], [MyPackage])
```

Which will automatically run `gen()` whenever one of the files in `contents/` changes or any code in the `MyPackage` module.
To only run `gen` for one file, such as `contents/my_text.md`, use:

```language-julia
entr(() -> gen("my_text"), ["contents"], [MyPackage])
```

Or, the equivalent helper function exported by `Books.jl`:

```language-julia
entr_gen("my_text"; M=[MyPackage])
```

With this, `gen("my_text")` will be called every time something changes in one of the files in the contents folder or when something changes in `YourModule`.
Note that you can run this while `serve` is running in another terminal in the background.
Then, your Julia code is executed and the website is automatically updated every time you change something in `content` or `MyPackage`.
Also note that `gen` is a drop-in replacement for `entr_gen`, so you can always add or remove `entr_` to run a block one time or multiple times.

In the background, `gen` passes the methods through `convert_output(expr::String, path, out::T)` where `T` can, for example, be a DataFrame or a plot.
To show that a DataFrame is converted to a Markdown table, we define a method

```jl
@sc(BooksDocs.my_table())
```

and add its output to the Markdown file with

    ```jl
    BooksDocs.my_table()
    ```

Then, it will show as

```jl
BooksDocs.my_table()
```

where the caption and the label are inferred from the `path`.
Refer to @tbl:my_table with

```language-markdown
@tbl:my_table
```

To show multiple objects, pass a `Vector`:

```jl
@sco BooksDocs.multiple_df_vector()
```

When you want to control where the various objects are saved, use `Options`.
This way, you can pass a informative path with plots for which informative captions, cross-reference labels and image names can be determined.

```jl
@sco BooksDocs.multiple_df_example()
```

To define the labels and/or captions manually, see @sec:labels-captions.
For showing multiple plots, see @sec:plots.

Most things can be done via functions.
However, defining a struct is not possible, because `@sco` cannot locate the struct definition inside the module.
Therefore, it is also possible to pass code and specify that you want to evaluate and show code (sc) without showing the output:

    ```jl
    s = """
        struct Point
            x
            y
        end
        """
    sc(s)
    ```

which shows as

```jl
s = """
    struct Point
        x
        y
    end
    """
sc(s)
```

and show code and output (sco).
For example,

    ```jl
    sco("p = Point(1, 2)")
    ```

shows as

```jl
sco("p = Point(1, 2)")
```

Note that this is starting to look a lot like R Markdown where the syntax would be something like

    ```{r, results='hide'}
    x = rnorm(100)
    ```

I guess that there is no perfect way here.
The benefit of evaluating the user input directly, as Books.jl is doing, seems to be that it is more extensible if I'm not mistaken.
Possibly, the reasoning is that R Markdown needs to convert the output directly, whereas Julia's better type system allows for converting in much later stages, but I'm not sure.

> **Tip**: When using `sco`, the code is evaluated in the `Main` module.
> This means that the objects, such as the `Point` struct defined above, are available in your REPL after running `gen()`.

## Labels and captions {#sec:labels-captions}

To set labels and captions, wrap your object in `Options`:

```jl
@sco(BooksDocs.options_example())
```

which can be referred to with

```
@tbl:foo
```
> @tbl:foo

It is also possible to pass only a caption or a label.
This package will attempt to infer missing information from the `path`, `caption` or `label` when possible:

```jl
BooksDocs.options_example_doctests()
```

## Obtaining function definitions {#sec:function_code_blocks}

So, instead of passing a string which `Books.jl` will evaluate, `Books.jl` can also obtain the code for a method directly.
(Thanks to `CodeTracking.@code_string`.)
For example, inside our package, we can define the following method:

```jl
@sc(BooksDocs.my_data())
```

To show code and output (sco) for this method, use the `@sco` macro.
This macro is exported by Books, so ensure that you have `using Books` in your package.

    ```jl
    @sco BooksDocs.my_data()
    ```

This gives

```jl
@sco BooksDocs.my_data()
```

To only show the source code, use `@sc`:

    ```jl
    @sc BooksDocs.my_data()
    ```

resulting in

```jl
@sc BooksDocs.my_data()
```

To override options for your output, use the `pre` keyword argument of `@sco`:

    ```jl
    let
        caption = "This caption is set via the pre keyword."
        pre(out) = Options(out; caption)
        @sco pre=pre my_data()
    end
    ```

which appears to the reader as:

```jl
let
    caption = "This caption is set via the pre keyword."
    pre(out) = Options(out; caption)
    @sco pre=pre my_data()
end
```

See `?sco` for more information.
Since we're using methods as code blocks, we can use the code shown in one code block in another.
For example, to determine the mean of column A:

    ```jl
    @sco BooksDocs.my_data_mean(my_data())
    ```

shows as

```jl
@sco BooksDocs.my_data_mean(my_data())
```

Or, we can show the output inline, namely `jl BooksDocs.my_data_mean(my_data())`, by using

```
`jl BooksDocs.my_data_mean(my_data())`
```

It is also possible to show methods with parameters.
For example,

    ```jl
    @sc BooksDocs.hello("" )
    ```

shows

```jl
@sc BooksDocs.hello("")
```

Now, we can show

```jl
scob("""
BooksDocs.hello("World")
""")
```

Here, the `M` can be a bit confusing for readers.
If this is a problem, you can export the method `hello` to avoid it.
If you are really sure, you can export all symbols in your module with something like [this](https://discourse.julialang.org/t/exportall/4970/16).

## Plots {#sec:plots}

For image types from libraries that `Books.jl` doesn't know about such as plotting types from `Plots.jl` and `Makie.jl`, it is required to extend two methods.
First of all, extend `Books.is_image` so that it returns true for the figure type of the respective plotting library.
For example for `Plots.jl` set

```julia
import Books

Books.is_image(plot::Plots.Plot) = true
```
and extend `Books.svg` and `Books.png` too.
For example, for `Plots.jl`:

```jl
@sc Books.svg("foo", plot(1:10))
```

Adding plots to books is actually a bit tricky, because we want to show vector graphics (SVG) on the web, but these are not supported (well) by LaTeX.
Therefore, portable network graphics (PNG) images are also created and passed to LaTeX, so set `Books.png` too:

```jl
@sc Books.png("foo", plot(1:10))
```

Then, plotting works:

```jl
@sco BooksDocs.example_plot()
```

For multiple images, use `Options.(objects, paths)`:

```jl
@sc BooksDocs.multiple_example_plots()
```

Resulting in one `Plots.jl` (@fig:example_plot_2) and one `CairoMakie.jl` (@fig:example_plot_3) plot:

```jl
BooksDocs.multiple_example_plots()
```

To change the size, change the resolution of the image:

```jl
@sco BooksDocs.image_options_plot()
```

And, for adjusting the caption, use `Options`:

```jl
@sco BooksDocs.combined_options_plot()
```

or the caption can be specified in the Markdown file:

    ```jl
    p = BooksDocs.image_options_plot()
    Options(p; caption="Label specified in Markdown.")
    ```

```jl
p = BooksDocs.image_options_plot()
Options(p; caption="Label specified in Markdown.")
```

\

```jl
@sco BooksDocs.plotsjl()
```

This time, we also pass `link_attributes` to Pandoc (@fig:makie) to shrink the image width on the page:

```jl
@sco BooksDocs.makiejl()
```

## Other notes

### Multilingual books

For an example of a multilingual book setup, say English and Chinese, see <https://juliadatascience.io>.

### Footnotes

Footnotes can be added via regular Markdown syntax:

```
Some sentence[^foot].

[^foot]: Footnote text.
```

> Some sentence[^foot].

[^foot]: Footnote text.

### Show

When your method returns an output type `T` which is unknown to Books.jl, it will be passed through `show(io::IO, ::MIME"text/plain", object::T)`.
So, if the package that you're using has defined a new `show` method, this will be used.
For example, for a grouped DataFrame:

```jl
sco("groupby(DataFrame(; A=[1]), :A)")
```

### Note box

To write note boxes, you can use

```
> **_NOTE:_**  The note content.
```

> **_NOTE:_**  The note content.

This way is fully supported by Pandoc, so it will be correctly converted to outputs such as PDF.

### Advanced `sco` options

To enforce output to be embedded inside a code block, use `scob`.
For example,

```jl
sco("""
scob("
df = DataFrame(A = [1], B = [Date(2018)])
string(df)
")
""")
```

or, with a string

```jl
scob("s = \"Hello\"")
```

Another way to change the output is via the keyword arguments `pre`, `process` and `post` for `sco`.
The idea of these arguments is that they allow you to pass a function to alter the processing that Books.jl does.
`pre` is applied **before** `Books.convert_output`, `process` is applied **instead** of `Books.convert_output` and `post` is applied **after** `Books.convert_output`.
For example, to force books to convert a DataFrame to a string instead of a Markdown table, use:

    ```jl
    s = "df = DataFrame(A = [1], B = [Date(2018)])"
    sco(s; process=string, post=output_block)
    ```

which shows the following to the reader:

```jl
s = "df = DataFrame(A = [1], B = [Date(2018)])"
sco(s; process=string, post=output_block)
```

Without `process=string`, the output would automatically be converted to a Markdown table by Books.jl and then wrapped inside a code block, which will cause Pandoc to show the raw output instead of a table.

```jl
s = "df = DataFrame(A = [1], B = [Date(2018)])"
sco(s; process=without_caption_label, post=output_block)
```

Without `post=output_block`, the DataFrame would be converted to a string, but not wrapped inside a code block so that Pandoc will treat is as normal Markdown:

```jl
s = """
    df = DataFrame(A = [2], B = [Date(2018)])
    Options(df; caption=nothing, label=nothing) # hide
    """
sco(s; process=string)
```

This also works for `@sco`.
For example, for `my_data` we can use:

    ```jl
    @sco process=string post=output_block my_data()
    ```

which will show as:

```jl
@sco process=string post=output_block my_data()
```

### Fonts

The code blocks default to JuliaMono in HTML and PDF.
For the HTML, this package automatically handles JuliaMono.
However, for the PDF, this just doesn't work out (see, e.g., [257](https://github.com/JuliaBooks/Books.jl/pull/257)).
To get JuliaMono to work with the PDF build, install it globally.
See the instructions at the [JuliaMono site](https://juliamono.netlify.app/download/#installation).
On Linux, you can use `Books.install_extra_fonts()`, but beware that it might override user settings.

Ligatures from JuliaMono are disabled. For example, none of these symbols are combined into a single glyph.

```
|> => and <=
```

### Long lines in code blocks

```language-plain
When code or output is getting too long, a horizontal scrollbar is visible on the website to scroll horizontally and a red arrow is visible in the PDF.
```

### Code blocks in lists

To embed code blocks inside lists, indent by 3 spaces and place an empty line before and after the code block.
For example, this will show as:

1. This is a list item with some code and output:

   ```jl
   scob("x = 2 + 1")
   ```

2. And the list continues
    * with an example on the third level:

       ```jl
       scob("x = 3 + 1")
       ```

    * another third level item
    * and another

