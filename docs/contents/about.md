# About {#sec:about}

Basically, this package is a wrapper around [Pandoc](https://pandoc.org/){target="_blank"}; similar to [Bookdown](https://bookdown.org){target="_blank"}.
Note that Pandoc does the heavy lifting and this package adds features on top.
For websites, this package allows for:

- Building a website spanning multiple pages.
- Live reloading the website to see changes quickly; thanks to Pandoc and [LiveServer.jl](https://github.com/tlienart/LiveServer.jl){target="_blank"}.
- Cross-references from one web page to a section on another page.
- Embedding dynamic output, while still allowing normal Julia package utilities, such as unit testing and live reloading (Revise.jl).
- Showing code blocks as well as output.

If you don't need PDFs or EPUBs, then [Franklin.jl](https://github.com/tlienart/Franklin.jl){target="_blank"} is probably a better choice.
To create single pages and PDFs containing code blocks, see [Weave.jl](https://github.com/JunoLab/Weave.jl){target="_blank"}.

One of the main differences with Franklin.jl, Weave.jl and knitr (Bookdown) is that this package completely decouples the computations from the building of the output.
The benefit of this is that you can spawn two separate processes, namely the one to serve your webpages

```
$ julia --project -e 'using Books; serve()'
Watching ./pandoc/favicon.png
Watching ./src/plots.jl
[...]
 ✓ LiveServer listening on http://localhost:8001/ ...
  (use CTRL+C to shut down)
```

and the one where you do the computations for your package `Foo`

```
$ julia --project -e  'using Books; using Foo; M = Foo'

julia> Books.generate_dynamic_content(; M)
Running example() for _generated/example.md
Running julia_version() for _generated/julia_version.md
Running example_plot() for _generated/example_plot.md
Writing plot images for example_plot
[...]
```

This way, the website remains responsive when the computations are running.
Thanks to LiveServer.jl and Pandoc, updating the page after changing text or code takes less than a second.
Also, because the `serve` process does relatively few things, it doesn't often crash.
A drawback of this decoupling is that you need to link your text to the correct computation in the Markdown file, whereas in other packages you would insert the code as a string.

The decoupling also allows the output, which you want to include, to be evaluated inside your package, see @sec:embedding-code.
This means that you don't have to define all your dependencies in a `@setup` (Documenter.jl) or `# hideall` (Franklin.jl / Literate.jl) code block.
(Granted, you could work your way around it by only calling methods inside a package.)
The dependencies, such as `using DataFrames`, are available from your package.
This provides all the benefits which Julia packages normally have, such as unit testing and live reloading via Revise.jl.
