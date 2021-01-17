# Books.jl

Creating books with Julia

## Usage

Go into a directory containing the Julia project for a book that you want to build.
To serve your book as a website, run
```
julia --project -e 'using Books; serve()'
```

## Developer information

To build the docs, use
```
julia --project -e 'cd("docs"); using Books; serve()'
```
