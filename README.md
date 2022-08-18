<p align="center">
  <img width="60%" src="https://user-images.githubusercontent.com/20724914/137941103-50f5d3a8-b447-4b09-807d-7161ceeadf34.png">
</p>

<h1 align="center">Books.jl</h1>

<h3 align="center">
  Create books with Julia
</h3>

<p align="center">
    <a href="https://github.com/JuliaBooks/Books.jl/actions?query=workflow%3ACI+branch%3Amain">
        <img src="https://github.com/JuliaBooks/Books.jl/workflows/CI/badge.svg" alt="CI">
    </a>
    <a href="https://huijzer.xyz/Books.jl/">
        <img src="https://img.shields.io/badge/Documentation-main-blue" alt="Documentation">
    </a>
    <a href="https://github.com/invenia/BlueStyle">
        <img src="https://img.shields.io/badge/Code%20Style-Blue-4495d1.svg" alt="Code Style Blue">
    </a>
</p>

In a nutshell, this package is meant to generate books (or reports or dashboards) with embedded Julia output.
Via Pandoc, the package can live serve a website and build various outputs including a website and PDF.
For many standard output types, such as DataFrames and plots, the package can run your code and will automatically handle proper embedding in the output documents, and also try to guess suitable captions and labels.
Also, it is possible to work via the live server, which shows changes within seconds.

This package assumes that:

- the user is comfortable with managing two REPLs,
- the user wants to run Julia code and embed the output in a book,
- the book (website and PDF) is built via CI, and
- Markdown sections and subsections (level 2) should be numbered and listed in the HTML menu.

The reason that numbering of sections is always assumed is to allow the book to be printed.
Without section numbers, it is difficult to refer to other parts of the book.

If you do not want numbered sections, but instead a more dynamic website with links, then checkout [Franklin.jl](https://github.com/tlienart/Franklin.jl) or my [template repository for Franklin with Pluto](https://github.com/rikhuijzer/JuliaTutorialsTemplate).
If you want a small report instead of a book with numbered sections, then [Weave.jl](https://github.com/JunoLab/Weave.jl) might be more suitable for your problem.

This package is used to create the [Julia Data Science book](https://juliadatascience.io).

## Usage

To install this package (Julia 1.6/1.7/1.8 on MacOS/Linux), use
```
pkg> add Books
```

See, the [documentation](https://huijzer.xyz/Books.jl/) for more information.

### Windows

Currently, this package (probably) does not work on Windows.
This seems to be due to differences in maximum file path lengths.
I have to look into it a bit more to fix it, but it's not a priority for me.

### Getting help

If you run into problems when using this package, feel free to open an issue here at GitHub or click [this](
https://discourse.julialang.org/new-topic?title=Books.jl%20-%20Your%20question%20here&category=usage&tags=Books&body=You%20can%20write%20your%20question%20in%20this%20space.
) link to ask a question at Discourse.
For short questions, feel free to send me a PM at <https://julialang.zulipchat.com/>.
