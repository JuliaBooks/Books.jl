# Demo {#sec:demo}

We can refer to a section with the normal [pandoc-crossref](https://lierdakil.github.io/pandoc-crossref/){target="_blank"} syntax.
For example,

<pre>
See @sec:getting-started.
</pre>

> See @sec:getting-started.

We can refer to citations such as @orwell1945animal and [@orwell1949nineteen] or to equations such as @eq:example.

$$ y = \frac{\sin{x}}{\cos{x}} $$ {#eq:example}

## Embedding output {#sec:embedding-output}

For embedding code, you can use the `jl` inline code or code block.
For example, to show the Julia version, define a code block like

<pre>
```jl
M.julia_version()
```
</pre>

in a Markdown file.
Then, in your package, define the method `julia_version()`:

```
M.julia_version() = "This book is built with Julia $VERSION."
```

Next, ensure that you call `using Books; gen(; M)`, where `M = YourModule`.
Alternatively, if you work on a large project and want to only generate the output for one or more Markdown files in `contents/`, such as `index.md`, use

```jl
M.markdown_gen_example()
```

Calling `gen` will place the text

```jl
M.julia_version_example()
```

at the right path so that it can be included by Pandoc.
You can also embed output inline with single backticks like

```
`jl julia_version()`
```

or just call Julia's constant `VERSION` directly from within the Markdown file:

```
This book is built with Julia `jl string(VERSION)`.
```

This book is built with Julia `jl string(VERSION)`.

While doing this, it is expected that you also have the browser open and a server running, see @sec:getting-started.
That way, the page is immediately updated when you run `gen`.

Note that it doesn't matter where you define the function `julia_version`, as long as it is in your module.
To save yourself some typing, and to allow yourself to get some coffee while Julia gets up to speed, you can start Julia for your package with

```
$ julia --project -ie 'using Books; using MyPackage; M = MyPackage'
```

which allows you to re-generate all the content by calling

```
julia> gen()
```

To run this method automatically when you make a change in your package, ensure that you loaded [Revise.jl](https://github.com/timholy/Revise.jl) before loading your package and run

```
julia> entr(gen, ["contents"], [M])
[...]
```

where M is the name of your module.
Which will automatically run `gen()` whenever one of the files in `contents/` changes or any code in the module `M`.
In the background, `gen` passes the methods through `convert_output(expr::String, path, out::T)` where `T` can, for example, be a DataFrame or a plot.
To show that a DataFrame is converted to a Markdown table, we define a method

```jl
@sc(M.my_table)
```

and add its output to the Markdown file with

<pre>
```jl
M.my_table()
```
</pre>

Then, it will show as

```jl
M.my_table()
```

where the caption and the label are inferred from the `path`.
Refer to @tbl:my_table with
```
@tbl:my_table
```

> @tbl:my_table

To show multiple objects, pass a `Vector`:

```jl
@sco(M.multiple_df_vector)
```

When you want to control where the various objects are saved, use `Options`.
This way, you can pass a informative path with plots for which informative captions, cross-reference labels and image names can be determined.

```jl
@sco(M.multiple_df_example)
```

To define the labels and/or captions manually, see @sec:labels-captions.
For showing multiple plots, see @sec:plots.

Most things can be done via functions.
However, defining a struct is not possible, because `@sco` cannot locate the struct definition inside the module.
Therefore, it is also possible to pass code and specify that you want to evaluate and show code (sc) without showing the output:

<pre>
```jl
sc("
struct Point
    x
    y
end
")
```
</pre>

```jl
sc("
struct Point
    x
    y
end
")
```

and show code and output (sco).
For example,

<pre>
```jl
sco("p = Point(1, 2)")
```
</pre>

shows as

```jl
sco("p = Point(1, 2)")
```

Note that this is starting to look a lot like R Markdown where the syntax would be something like

<pre>
```{r, results='hide'}
x = rnorm(100)
```
</pre>

I guess that there is no perfect way here.
The benefit of evaluating the user input directly, as Books.jl is doing, seems to be that it is more extensible if I'm not mistaken.
Possibly, the reasoning is that R Markdown needs to convert the output directly, whereas Julia's better type system allows for converting in much later stages, but I'm not sure.

> **Tip**: After you run `gen()` with the `Point` struct defined above, the struct will be available in your REPL.

## Labels and captions {#sec:labels-captions}

To set labels and captions, wrap your object in `Options`:

```jl
@sco(M.options_example)
```

which can be referred to with

```
@tbl:foo
```
> @tbl:foo

It is also possible to pass only a caption or a label.
This package will attempt to infer missing information from the `path`, `caption` or `label` when possible:

```jl
M.options_example_doctests()
```

## Obtaining function definitions {#sec:function_code_blocks}

So, instead of passing a string which `Books.jl` will evaluate, `Books.jl` can also obtain the code for a method directly.
(Thanks to `CodeTracking.@code_string`.)
For example, we can define the following method:

<pre>
```jl
M.my_data()
```
</pre>

To show code and output (sco), use the `@sco` macro.
This macro is exported by Books, so ensure that you have `using Books` in your package.

<pre>
```jl
@sco(M.my_data)
```
</pre>

This gives

```jl
@sco(M.my_data)
```

To only show the source code, use `@sc`:

<pre>
```jl
@sc(M.my_data)
```
</pre>

resulting in

```jl
@sc(M.my_data)
```

Since we're using methods as code blocks, we can use the code shown in one code block in another.
For example, to determine the mean of column A:

```jl
@sco(M.my_data_mean)
```

Or, we can show the output inline, namely `jl M.my_data_mean()`, by using

```
`jl M.my_data_mean()`
```

## Plots {#sec:plots}

An AlgebraOfGraphics plot is shown below in @fig:example_plot.
For Plots.jl and Makie.jl see, respectively section @sec:plotsjl and @sec:makie.
This is actually a bit tricky, because we want to show vector graphics (SVG) on the web, but these are not supported (well) by LaTeX.
Therefore, portable network graphics (PNG) images are also created and passed to LaTeX when building a PDF.

```jl
@sco(M.example_plot)
```

If the output is a string instead of the output you expected, then check whether you load the related packages in time.
For example, for this plot, you need to load AlgebraOfGraphics.jl together with Books.jl so that Requires.jl will load the code for handling AlgebraOfGraphics objects.

For multiple images, use `Options.(objects, paths)`:

```jl
@sc(M.multiple_example_plots)
```

Resulting in @fig:example_plot_2 and @fig:example_plot_3:

```jl
M.multiple_example_plots()
```

For changing the size, use `axis` from AlgebraOfGraphics:

```jl
@sco(M.image_options_plot)
```

And, for adjusting the caption, use `Options`:

```jl
@sco(M.combined_options_plot)
```

or the caption can be specified in the Markdown file:

<pre>
```jl
Options(M.image_options_plot(); caption="Label specified in Markdown.")
```
</pre>

```jl
Options(M.image_options_plot(); caption="Label specified in Markdown.")
```

### Plots {#sec:plotsjl}

```jl
@sco(M.plotsjl)
```

### Makie {#sec:makie}

```jl
@sco(M.makiejl)
```

## Other notes

### Multilingual books

For an example of a multilingual book setup, say English and Chinese, see the book by [Jun Tian](https://github.com/LearnJuliaTheFunWay/LearnJuliaTheFunWay.jl).

### Show

When your method returns an output type `T` which is unknown to Books.jl, it will be passed through `show(io::IO, ::MIME"text/plain", object::T)`.
So, if the package that you're using has defined a new `show` method, this will be used.
For example, for `MCMCChains`,

```jl
@sco(M.chain)
```

### Note box

To write note boxes, you can use

```
> **_NOTE:_**  The note content.
```

> **_NOTE:_**  The note content.

This way is fully supported by Pandoc, so it will be correctly converted to outputs such as PDF or DOCX.

### String interpolation

For string interpolation, add a backslash before the dollar sign when using `sc` or `sco`.
