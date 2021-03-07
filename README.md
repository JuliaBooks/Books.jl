# Books.jl

Create books with Julia.

[![CI Testing](https://github.com/rikhuijzer/Books.jl/workflows/CI/badge.svg)](https://github.com/rikhuijzer/Books.jl/actions?query=workflow%3ACI+branch%3Amain)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

## Usage

To install this package, use
```
pkg> add Books
```

Next, go into a directory containing the Julia project for a book that you want to build.
See the `docs` folder of this project for an example project.
Then, you can serve your book as a website via
```
julia --project -ie 'using Books; serve()'
```

For more information, see the [documentation](https://books.huijzer.xyz).
