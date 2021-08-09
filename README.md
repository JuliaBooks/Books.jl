# Books.jl

Create books with Julia.

[![CI Testing](https://github.com/rikhuijzer/Books.jl/workflows/CI/badge.svg)](https://github.com/rikhuijzer/Books.jl/actions?query=workflow%3ACI+branch%3Amain)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

In a nutshell, this package is meant to generate books (or dashboards) with embedded Julia output.
Via Pandoc, the package can live serve a website and build various outputs including a website, PDF, and Docx.
For Julia code, the package can either show the code and the output, show the code or show only the output.
For many standard output types, such as DataFrames and plots, the package will automatically handle proper embedding in the output documents, and also try to guess suitable captions and labels.
Also, it is possible to work via the live server, which shows changes within seconds.

This package assumes that:

- the user is comfortable with managing two REPLs,
- the user wants to embed Julia code,
- Markdown sections and subsections (level 2) should be numbered and listed in the HTML menu, and
- the book (website, PDF and Docx) is built via CI.

The reason that numbering of sections is always assumed is to allow the book to be printed.
Without section numbers, it is difficult to refer to other parts of the book.

If you do not want numbered sections, but instead a more dynamic website with links, then checkout [Franklin.jl](https://github.com/tlienart/Franklin.jl).
If you want a small report instead of a book with numbered sections, then [Weave.jl](https://github.com/JunoLab/Weave.jl) might be more suitable for your problem.

Currently, this package is used to write the [Julia Data Science book](https://github.com/JuliaDataScience/JuliaDataScience).

## Usage

To install this package (Julia 1.6 on MacOS/Linux), use
```
pkg> add Books
```

See, the [documentation](https://rikhuijzer.github.io/Books.jl) for more information.

### Windows

Currently, Windows is not supported.
Some regexes expects paths to contain a forward slash and things like that.
For now, I don't plan to invest time in supporting Windows, but PRs for Windows are welcome.
