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

So, to eval some code and write it to aforementioned file, you could use

```{.include}
build/sum-definition.md
```

which gives

```{.include}
build/sum.md
```

## Embedding images

```{.include}
_generated/example.md
```

## Other notes

### Level 3 headings

These are hidden from the menu.
