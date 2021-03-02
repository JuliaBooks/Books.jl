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
