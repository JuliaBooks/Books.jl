# Demo {#sec:demo}

We can refer to a section with the normal [pandoc-crossref](https://lierdakil.github.io/pandoc-crossref/){target="_blank"} syntax.
For example,

<pre>
See @sec:getting-started.
</pre>

> See @sec:getting-started.

We can refer to citations such as @orwell1945animal and [@orwell1945animal] or to equations like @eq:sin.

$$ y = sin(x) $$ {#eq:sin}

## Embedding output {#sec:embedding-output}

For embedding code, you can use the `include-files` Lua filter.
This package can automatically run methods based on the included filenames.
For example, generate a Markdown file `sum.md` with Julia and include it with

<pre>
```{.include}
_generated/julia_version.md
```
</pre>

Then, in your package, define the method `julia_version`:
```
julia_version() = "This book is built with Julia $VERSION."
```

Next, ensure that you call `Books.generate_content(; M = Foo)`, where `Foo` is the name of your module.
This will place the text

```{.include}
_generated/julia_version_example.md
```

at the aforementioned path so that it can be included by Pandoc.
Note that it doesn't matter where you define the function `julia_version`, as long as it is in your module.

Of these evaluated methods, the output is passed through `convert_output(path, out::T)` where `T` can, for example, be a DataFrame.
To show this, we define a method

```{.include}
_generated/my_table_def.md
```

and add its output to the Markdown file with

<pre>
```{.include}
_generated/my_table.md
```
</pre>

Then, it will show as

```{.include}
_generated/my_table.md
```

where the caption and the label are inferred from the `path`.
Refer to @tbl:my_table with
```
@tbl:my_table
```

> @tbl:my_table

To show multiple objects, use `Outputs`:

```{.include}
_generated/multiple_df_example_def.md
```

which will appear as

```{.include}
_generated/multiple_df_example.md
```

To add labels and captions to these tables based on the `path`, use `Outputs(objects; paths)` instead of `Outputs(objects)`.
To change the labels and/or captions, see @sec:labels-captions.
For showing multiple plots, see @sec:plots.

## Labels and captions {#sec:labels-captions}

To set labels and captions, wrap your object in `Options`:

```{.include}
_generated/options_example_def.md
```

giving

```{.include}
_generated/options_example.md
```
which can be referred to with
```
@tbl:foo
```
> @tbl:foo

It is also possible to pass only a caption or a label.
This package will attempt to infer missing information from the `path`, `caption` or `label` when possible:

```{.include}
_generated/options_example_doctests.md
```

## Showing code blocks {#sec:code-blocks}

Like in @sec:embedding-output, first define a method like

```{.include}
_generated/sum_example_definition.md
```

Then, add this method via

<pre>
```{.include}
_generated/sum_example.md
```
</pre>

which gives as output

```{.include}
_generated/sum_example.md
```

Here, how the output should be handled is based on the output type of the function.
In this case, the output type is of type `Code`.
Methods for other outputs exist too:

```{.include}
_generated/example_table_definition.md
```

shows

```{.include}
_generated/example_table.md
```

Alternatively, we can show the same by creating something of type `Code`.

```{.include}
_generated/code_example_table_definition.md
```

which shows as

```{.include}
_generated/code_example_table.md
```

because the output of the code block is of type DataFrame.

In essence, this package doesn't hide the implementation behind synctactic sugar.
Instead, this package calls functions and gives you the freedom to decide what to do from there.
As an example, we can pass `Module` objects to `code` to evaluate the code block in a specific module.

```{.include}
_generated/module_example_definition.md
```

When calling `module_example`, it shows as

```{.include}
_generated/module_example.md
```

Similarily, we can get the value of x:

```{.include}
_generated/module_call_x.md
```

Unsuprisingly, creating a DataFrame will now fail because we haven't loaded DataFrames

```{.include}
_generated/module_fail.md
```

Which is easy to fix

```{.include}
_generated/module_fix.md
```

## Plots {#sec:plots}

Conversions for Gadfly are also included, see @fig:example_plot.
This is actually a bit tricky, because we want to show vector graphics (SVG) on the web, but these are not supported (well) by LaTeX.
Therefore, portable network graphics (PNG) images are passed to LaTeX via cairosvg;
I found that this tool does the best conversions without relying on Cairo.jl.
(Cairo.jl doesn't work for me on NixOS.)

```{.include}
_generated/example_plot.md
```

If the output is a string instead of the output you expected, then check whether you load the related packages in time.
For example, for this Gadfly plot, you need to load Gadfly.jl together with Books.jl for Requires.jl to work.

For multiple images, use `Outputs(objects; paths)`:

```{.include}
_generated/multiple_example_plots_def.md
```

Resulting in @fig:example_plot_2 and @fig:example_plot_3:

```{.include}
_generated/multiple_example_plots.md
```

## Other notes

### Level 3 headings

These are hidden from the website menu.
