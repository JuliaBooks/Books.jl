# Welcome {-}

[//]: # (This file is only included on the website.)

This website introduces and demonstrates [Books.jl](https://github.com/rikhuijzer/Books.jl){target="_blank"} and is available as [PDF](/book.pdf){target="_blank"}.

Basically, this package is a wrapper around [Pandoc](https://pandoc.org/){target="_blank"}; similar to [Bookdown](https://bookdown.org){target="_blank"}.
Note that Pandoc does the heavy lifting and this package only adds a few features.
For html, this package allows:

- Building a website spanning multiple pages,
- Live reloading the website to see changes quickly; thanks to [LiveServer.jl](https://github.com/tlienart/LiveServer.jl){target="_blank"},
- Cross-references from one html page to a section on another page.

If you don't need PDFs or EPUBs, then [Franklin.jl](https://github.com/tlienart/Franklin.jl){target="_blank"} is a much better choice.
To create single pages and PDFs containing code blocks, see [Weave.jl](https://github.com/JunoLab/Weave.jl){target="_blank"}.
