# Books.jl

Create books with Julia.

## Usage

To install this package, use
```
julia> ]

pkg> add https://github.com/rikhuijzer/books.jl
```

Next, go into a directory containing the Julia project for a book that you want to build.
See the `docs` folder of this project for an example project.
Then, you can serve your book as a website via
```
julia --project -ie 'using Books; serve()'
```

If you just want to build your book, use
```
$ julia --project

julia> build_all()
```
or 
```
julia> html()
```
or
```
julia> pdf()
```

## Code evaluation

Unlike [Franklin.jl](https://github.com/tlienart/Franklin.jl), [Weave.jl](https://github.com/JunoLab/Weave.jl) or [Bookdown](https://bookdown.org/) this project does not evaluate code.
To generate parts of the output, write plots and text to files and pick them up with Pandoc.
For images, use `![caption](build/files/image.md)`.
For text (including tables), use the `include-files` [lua filter](https://github.com/pandoc/lua-filters).

```{.include}
build/files/table.md
```

There is something to say for both approaches.
I like this decoupling of code from the pages because it is more flexible, stable and quick, and interacts better with Julia's testing module, the REPL and [Revise.jl](https://github.com/timholy/Revise.jl).
The drawback of this approach is that it requires more file and session management.
