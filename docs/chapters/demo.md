# Demo {#sec:demo}

We can refer to the chapter Getting Started with @sec:getting-started.

We can refer to citations such as @orwell1945animal and [@orwell1945animal] or to equations like @eq:sin.

$$ y = sin(x) $$ {#eq:sin}

## Embedding code

For embedding code, you can use the `include-files` Lua filter.
For example, generate a Markdown file `sum.md` with Julia and include it with

<pre>
```{.include}
build/sum.md
```
</pre>

So, to eval some code and write it aforementioned file, you can use something like

```{.include}
build/sum-definition.md
```

which gives

```{.include}
build/sum.md
```

I'll probably add some helper functions in this package when I'm more sure about how the interface should look.
