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
You can also embed the output inline with single backticks like

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
To save yourself some typing, and to allow yourself to get some coffee while Julia gets up to speed, you can start Julia for some package `Foo` with

```
$ julia --project -ie 'using Books; using Foo; M = Foo; gen()'
```

which allows you to re-generate all the content by calling

```
julia> gen(; M)
```

Also, it allows you to quickly restart Julia after you have updated some constants such as structs.
To re-generate only the content for one method like, for example, the method `my_plot`, use

```
julia> gen(M.my_plot)
[...]
```

To run this method automatically when you make a change in your package, ensure that you loaded [Revise.jl](https://github.com/timholy/Revise.jl) before loading your package and run

```
julia> f() = gen(M.my_plot);

julia> entr(f, ["contents"], [M])
[...]
```

Which will automatically run `f()` whenever one of the files in `contents/` changes or any code in the module `M`.
In the background, `gen` passes the methods through `convert_output(expr::String, path, out::T)` where `T` can, for example, be a DataFrame or a plot.
To show that a DataFrame is converted to a Markdown table, we define a method

```jl
@sc(my_table)
```

and add its output to the Markdown file with

<pre>
```jl
my_table()
```
</pre>

Then, it will show as

```jl
my_table()
```

where the caption and the label are inferred from the `path`.
Refer to @tbl:my_table with
```
@tbl:my_table
```

> @tbl:my_table

To show multiple objects, pass a `Vector`:

```jl
@sco(multiple_df_vector)
```

When you want to control where the various objects are saved, use `Options`.
This way, you can pass a informative path with plots for which informative captions, cross-reference labels and image names can be determined.

```jl
@sco(multiple_df_example)
```

To define the labels and/or captions manually, see @sec:labels-captions.
For showing multiple plots, see @sec:plots.

## Labels and captions {#sec:labels-captions}

To set labels and captions, wrap your object in `Options`:

```jl
@sco(options_example)
```

which can be referred to with

```
@tbl:foo
```
> @tbl:foo

It is also possible to pass only a caption or a label.
This package will attempt to infer missing information from the `path`, `caption` or `label` when possible:

```jl
options_example_doctests()
```

## Function code blocks {#sec:function_code_blocks}

So, instead of passing a string which `Books.jl` will evaluate, `Books.jl` can also obtain the code for a method directly.
(Thanks to `CodeTracking.@code_string`.)
For example, we can define the following method:

<pre>
```jl
my_data()
```
</pre>

To show code and output (sco), use the `@sco` macro.
This macro is exported by Books, so ensure that you have `using Books` in your package.

<pre>
```jl
@sco(my_data)
```
</pre>

This gives

```jl
@sco(my_data)
```

To only show the source code, use the `-sc` suffix:

<pre>
```jl
@sc(my_data)
```
</pre>

resulting in

```jl
@sc(my_data)
```

Since we're using methods as code blocks, we can use the code shown in one code block in another.
For example, to determine the mean of column A:

```jl
@sco(my_data_mean)
```

Or, we can show the output inline, namely `jl my_data_mean()`, by using

```
`jl my_data_mean()`
```

## Plots {#sec:plots}

An AlgebraOfGraphics plot is shown below in @fig:example_plot.
For Plots.jl and Makie.jl see, respectively section @sec:plotsjl and @sec:makie.
This is actually a bit tricky, because we want to show vector graphics (SVG) on the web, but these are not supported (well) by LaTeX.
Therefore, portable network graphics (PNG) images are also created and passed to LaTeX when building a PDF.

```jl
@sco(example_plot)
```

If the output is a string instead of the output you expected, then check whether you load the related packages in time.
For example, for this plot, you need to load AlgebraOfGraphics.jl together with Books.jl so that Requires.jl will load the code for handling AlgebraOfGraphics objects.

For multiple images, use `Options.(objects, paths)`:

```jl
@sc(multiple_example_plots)
```

Resulting in @fig:example_plot_2 and @fig:example_plot_3:

```jl
multiple_example_plots()
```

For changing the size, use `axis` from AlgebraOfGraphics:

```jl
@sco(image_options_plot)
```

And, for adjusting the caption, use `Options`:

```jl
@sco(combined_options_plot)
```

or the caption can be specified in the Markdown file:

<pre>
```jl
Options(image_options_plot(); caption="Label specified in Markdown.")
```
</pre>

```jl
Options(image_options_plot(); caption="Label specified in Markdown.")
```

### Plots {#sec:plotsjl}

```jl
@sco(plotsjl)
```

### Makie {#sec:makie}

```jl
@sco(makiejl)
```

## Other notes

### Multilingual books

For an example of a multilingual book setup, say English and Chinese, see the book by [Jun Tian](https://github.com/LearnJuliaTheFunWay/LearnJuliaTheFunWay.jl).

### Show

When your method returns an output type `T` which is unknown to Books.jl, it will be passed through `show(io::IO, ::MIME"text/plain", object::T)`.
So, if the package that you're using has defined a new `show` method, this will be used.
For example, for `MCMCChains`,

```jl
@sco(chain)
```

### Note box

To write note boxes, you can use

```
> **_NOTE:_**  The note content.
```

> **_NOTE:_**  The note content.

This way is fully supported by Pandoc, so it will be correctly converted to outputs such as PDF or DOCX.
