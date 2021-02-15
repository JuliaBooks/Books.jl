# Demo {#sec:demo}

We can refer to the chapter Getting Started with @sec:getting-started.

We can refer to citations such as @orwell1945animal and [@orwell1945animal] or to equations like @eq:sin.

$$ y = sin(x) $$ {#eq:sin}

## Embedding code {#sec:embedding-code}

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

Next, ensure that you call `Books.generate_dynamic_content(M = Foo)`, where `Foo` is the name of your module.
This will place the text 

```{.include}
_generated/julia_version_example.md
```

at the aforementioned path so that it can be included by Pandoc.
Note that it doesn't matter where you define the function `julia_version`, as long as it is in your module.

## Showing code blocks

Like in @sec:embedding-code, first define a method like

```{.include}
_generated/sum_example_definition.md
```

Then, add this via

<pre>
```{.include}
_generated/sum_example.md
```
</pre>

which gives as output

```{.include}
_generated/sum_example.md
```

I'll probably add more helper functions for this once I know how the interface should look.

## Overloading the export

You can overload `convert_output(out::T)` for any type `T`.
For example, to create tables for DataFrames define

```{.include}
_generated/convert_output_definition.md
```

Then,

```{.include}
_generated/example_table_definition.md
```

can be called, like in @sec:embedding-code, and returns

```{.include}
_generated/example_table.md
```

## Other notes

### Level 3 headings

These are hidden from the menu.
