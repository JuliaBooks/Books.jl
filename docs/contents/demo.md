# Demo {#sec:demo}

We can refer to a section with the normal [pandoc-crossref](https://lierdakil.github.io/pandoc-crossref/){target="_blank"} syntax.
For example,

<pre>
See @sec:getting-started.
</pre>

> See @sec:getting-started.

We can refer to citations such as @orwell1945animal and [@orwell1945animal] or to equations such as @eq:example.

$$ y = \frac{\sin{x}}{\cos{x}} $$ {#eq:example}

## Embedding output {#sec:embedding-output}

For embedding code, you can use the `{.include}` code block.
This package will run your methods based on the filenames in these code blocks.
For example, to show the Julia version, use

<pre>
```{.include}
_gen/julia_version.md
```
</pre>

Then, in your package, define the method `julia_version()`:
```
julia_version() = "This book is built with Julia $VERSION."
```

Next, ensure that you call `using Books; gen(; M = Foo)`, where `Foo` is the name of your module.
This will place the text

```{.include}
_gen/julia_version_example.md
```

at the aforementioned path so that it can be included by Pandoc.
While doing this, it is expected that you also have the browser open and a server running, see @sec:getting-started.
That way, the page is immediately updated when you run `gen`.


Note that it doesn't matter where you define the function `julia_version`, as long as it is in your module.
To save yourself some typing, and to allow yourself to get some coffee while Julia gets up to speed, you can start Julia for some package `Foo` with

```
$ julia --project -ie 'using Books; using Foo; M = Foo; gen(; M)'
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

julia> entr(f, [], [M])
[...]
```

In the background, `gen` passes the methods through `convert_output(path, out::T)` where `T` can, for example, be a DataFrame or a plot.
To show that a DataFrame is converted to a Markdown table, we define a method

```{.include}
_gen/my_table-sc.md
```

and add its output to the Markdown file with

<pre>
```{.include}
_gen/my_table.md
```
</pre>

Then, it will show as

```{.include}
_gen/my_table.md
```

where the caption and the label are inferred from the `path`.
Refer to @tbl:my_table with
```
@tbl:my_table
```

> @tbl:my_table

To show multiple objects, pass a `Vector`:

```{.include}
_gen/multiple_df_vector-sco.md
```

When you want to control where the various objects are saved, use `Options`.
This way, you can pass a informative path with plots for which informative captions, cross-reference labels and image names can be determined.

```{.include}
_gen/multiple_df_example-sco.md
```

To define the labels and/or captions manually, see @sec:labels-captions.
For showing multiple plots, see @sec:plots.

## Labels and captions {#sec:labels-captions}

To set labels and captions, wrap your object in `Options`:

```{.include}
_gen/options_example-sco.md
```

which can be referred to with

```
@tbl:foo
```
> @tbl:foo

It is also possible to pass only a caption or a label.
This package will attempt to infer missing information from the `path`, `caption` or `label` when possible:

```{.include}
_gen/options_example_doctests.md
```

## String code blocks {#sec:string_code_blocks}

There are two ways to show code blocks.
One way is by passing your code as a string.
This is how similar packages work.
However, with `Books.jl`, the aim is to work with functions and *not* with code as strings as discussed at the end of @sec:about.
See @sec:function_code_blocks for a better way for showing code blocks.

Like in @sec:embedding-output, first define a method like

```{.include}
_gen/sum_example_definition.md
```

Then, add this method via

<pre>
```{.include}
_gen/sum_example.md
```
</pre>

which gives as output

```{.include}
_gen/sum_example.md
```

Here, how the output should be handled is based on the output type of the function.
In this case, the output type is of type `Code`.
Methods for other outputs exist too:

```{.include}
_gen/example_table_definition.md
```

shows

```{.include}
_gen/example_table.md
```

Alternatively, we can show the same by creating something of type `Code`:

```{.include}
_gen/code_example_table-sc.md
```

which shows as

```{.include}
_gen/code_example_table.md
```

because the output of the code block is of type DataFrame.

In essence, this package doesn't hide the implementation behind synctactic sugar.
Instead, this package calls functions and gives you the freedom to decide what to do from there.
As an example, we can pass `Module` objects to `code` to evaluate the code block in a specific module.

```{.include}
_gen/module_example_definition.md
```

When calling `module_example`, it shows as

```{.include}
_gen/module_example.md
```

Similarily, we can get the value of x:

```{.include}
_gen/module_call_x.md
```

Unsuprisingly, creating a DataFrame will now fail because we haven't loaded DataFrames

```{.include}
_gen/module_fail.md
```

Which is easy to fix

```{.include}
_gen/module_fix.md
```

## Function code blocks {#sec:function_code_blocks}

So, instead of passing a string which `Books.jl` will evaluate, `Books.jl` can also obtain the code for a method directly.
(Thanks to `CodeTracking.@code_string`.)
For example, we can define the following method:

```{.include}
_gen/my_data-sc.md
```

and call it by adding the `-sco` (source code and output) suffix to the path:

<pre>
```{.include}
_gen/my_data-sco.md
```
</pre>

This gives

```{.include}
_gen/my_data-sco.md
```

To only show the source code, use the `-sc` suffix:

<pre>
```{.include}
_gen/my_data-sc.md
```
</pre>

giving

```{.include}
_gen/my_data-sc.md
```

Since we're using methods as code blocks, we can use the code shown in one code block in another.
For example, to determine the mean of column A:

```{.include}
_gen/my_data_mean-sco.md
```

## Plots {#sec:plots}

Conversions for Gadfly are also included, see @fig:example_plot.
This is actually a bit tricky, because we want to show vector graphics (SVG) on the web, but these are not supported (well) by LaTeX.
Therefore, portable network graphics (PNG) images are passed to LaTeX via cairosvg;
I found that this tool does the best conversions without relying on Cairo.jl.
(Cairo.jl doesn't work for me on NixOS.)

```{.include}
_gen/example_plot-sco.md
```

If the output is a string instead of the output you expected, then check whether you load the related packages in time.
For example, for this Gadfly plot, you need to load Gadfly.jl together with Books.jl for Requires.jl to work.

For multiple images, use `Options.(objects, paths)`:

```{.include}
_gen/multiple_example_plots-sc.md
```

Resulting in @fig:example_plot_2 and @fig:example_plot_3:

```{.include}
_gen/multiple_example_plots.md
```

For changing the size, use `ImageOptions`:

```{.include}
_gen/image_options_plot-sco.md
```

Or, use the combination for setting captions and size

```{.include}
_gen/combined_options_plot-sco.md
```

## Other notes

When your method returns an output type `T` which is unknown to Books.jl, it will be passed through `show(io::IO, ::MIME"text/plain", object::T)`.
So, if the package that you're using has defined a new `show` method, this will be used.
For example, for `MCMCChains`

```{.include}
_gen/chain-sco.md
```
