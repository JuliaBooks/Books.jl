# About {#sec:about}

Basically, this package is a wrapper around [Pandoc](https://pandoc.org/){target="_blank"}; similar to [Bookdown](https://bookdown.org){target="_blank"}.
Note that Pandoc does the heavy lifting and this package adds features on top.
For websites, this package allows for:

- Building a website spanning multiple pages.
- Live reloading the website to see changes quickly; thanks to [LiveServer.jl](https://github.com/tlienart/LiveServer.jl){target="_blank"}.
- Cross-references from one web page to a section on another page.

If you don't need PDFs or EPUBs, then [Franklin.jl](https://github.com/tlienart/Franklin.jl){target="_blank"} is a much better choice.
To create single pages and PDFs containing code blocks, see [Weave.jl](https://github.com/JunoLab/Weave.jl){target="_blank"}.

One of the main differences with Franklin.jl, Weave.jl and knitr (Bookdown) is that this package completely decouples the computations from the building of the output.
I think that this is a major improvement, because it makes everything feel much more responsive.
Often, I just want to change a bit of text without re-running the computations or I want to update a very specific section of the code.
In combination with Revise and thanks to LiveServer.jl, updating the page after changing text or code takes less than a second.
