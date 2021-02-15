# Demo {#sec:demo}

We can refer to the chapter Getting Started with @sec:getting-started.

We can refer to citations such as @orwell1945animal and [@orwell1945animal] or to equations like @eq:sin.

$$ y = sin(x) $$ {#eq:sin}

## Embedding code

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

Next, ensure that you call `Books.generate_dynamic_content()`.
This will place the text 

```{.include}
_generated/julia_version_example.md
```

at the aforementioned path so that it is included by Pandoc.
Note that it doesn't matter where you define the function `julia_version`, as long as it is in your module.

## Embedding images


## Other notes

### Level 3 headings

These are hidden from the menu.
