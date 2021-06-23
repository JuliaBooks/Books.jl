# About {#sec:about}

Similar to [Bookdown](https://bookdown.org){target="_blank"} this package is, basically, a wrapper around [Pandoc](https://pandoc.org/){target="_blank"}.
For websites, this package allows for:

- Building a website spanning multiple pages.
- Live reloading the website to see changes quickly; thanks to Pandoc and [LiveServer.jl](https://github.com/tlienart/LiveServer.jl){target="_blank"}.
- Cross-references from one web page to a section on another page.
- Embedding dynamic output, while still allowing normal Julia package utilities, such as unit testing and live reloading (Revise.jl).
- Showing code blocks as well as output.

If you don't need PDFs or EPUBs, then [Franklin.jl](https://github.com/tlienart/Franklin.jl){target="_blank"} is probably a better choice.
To create single pages and PDFs containing code blocks, see [Weave.jl](https://github.com/JunoLab/Weave.jl){target="_blank"}.

One of the main differences with Franklin.jl, Weave.jl and knitr (Bookdown) is that this package completely decouples the computations from the building of the output.
The benefit of this is that you can spawn two separate processes, namely the one to serve your webpages:

```jl
M.serve_example()
```

and the one where you do the computations for your package:

```
$ julia --project -ie 'using Books'

julia> gen()
[...]
Updating html
```

This way, the website remains responsive when the computations are running.
Thanks to LiveServer.jl and Pandoc, updating the page after changing text or code takes less than a second.
Also, because the `serve` process does relatively few things, it almost never crashes.

As another benefit, the decoupling allows you to have more flexiblity in when you want to run what code.
In combination with Revise.jl, you can quickly update your code and see the updated output.

Finally, a big difference with this package and other packages is that you decide yourself what you want to show for a code block.
For example, in R

<pre>
```{r, results='hide'}
print("Hello, world!")
```
</pre>

shows the code and not the output.
Instead, in Books, you would write

<pre>
```jl
sc(raw"""
print("Hello, world!")
"""
)
```
</pre>

which is displayed as

```jl
sc(raw"""
print("Hello, world!")
"""
)
```

Here, `sc` is one of the convenience methods exported by Books.jl.
Although this approach is more verbose in some cases, it is also much more flexible.
In essence, you can come up with your own pre- or post-processing logic.
For example, lets write

<pre>
```jl
code = """
    df = DataFrame(a=[1, 2], b=[3, 4])
    Options(df, caption="A table", label=nothing)
    """
repeat(sco(code), 4)
```
</pre>

which shows the code and output (`sco`) 4 times:

```jl
code = """
    df = DataFrame(a=[1, 2], b=[3, 4])
    Options(df, caption="A table", label=nothing)
    """
repeat(sco(code), 4)
```


