# Deploying Books.jl to a Web Service

## GitHub Pages

### Initial Configuration

To configure your book for deployment to GitHub Pages, you will need to do the following setup:

1. Create a small module that utilizes the packages needed for your book.

2. Configure your repository for GitHub Pages

3. Set up continuous integration to automatically build your website anytime you push to your repository

### Create Book Module



### Configure GitHub Repository for Serving Website



### Setting Up Continuous Integration

Now, to have `Books.jl` automatically build your website each time you make a commit to your repository, you will need to create two directories in your repository called `.github/workflows`.
Within that folder, add the following example continuous integration configuration as a file called `CI.yml`:

```yml
name: CI

on:
  push:
    branches:
      - main
      - master
  pull_request:
  workflow_dispatch:

jobs:
  test-and-deploy:
    name: Test and deploy
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false
      matrix:
        version:
          - "1"
        os:
          - ubuntu-latest

    steps:
      - uses: actions/checkout@v2
        with:
          persist-credentials: false

      - uses: julia-actions/setup-julia@v1
        with:
          version: ${{ matrix.version }}

      - uses: actions/cache@v1
        env:
          cache-name: cache-artifacts
        with:
          path: ~/.julia/artifacts
          key: ${{ runner.os }}-test-${{ env.cache-name }}-${{ hashFiles('**/Project.toml') }}
          restore-keys: |
            ${{ runner.os }}-test-${{ env.cache-name }}-
            ${{ runner.os }}-test-
            ${{ runner.os }}-

      - name: Install Julia dependencies
        uses: julia-actions/julia-buildpkg@latest

      - name: Install extra dependencies
        run: julia --project -e 'using Books; Books.install_dependencies()'

      # YOU WILL NEED TO REPLACE THIS PACKAGE WITH THE NAME OF YOUR BOOK MODULE
      - name: Build the book
        run: julia --project -e 'using TestBook; TestBook.build()'

      - name: Deploy to secondary branch
        # Always updates documentation when ubuntu passes, which is fine.
        if: ${{ ( github.event_name == 'push' || github.event_name == 'workflow_dispatch') && runner.os == 'Linux' }}
        uses: peaceiris/actions-gh-pages@v3
        with:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          force_orphan: true
          publish_dir: ./_build/
```

As you will notice, you will need to modify one section in this script.
If your book's module is named `MyBook`, you will need to change this section in the configuration:

```yml
      # YOU WILL NEED TO REPLACE THIS PACKAGE WITH THE NAME OF YOUR BOOK MODULE
      - name: Build the book
        run: julia --project -e 'using TestBook; TestBook.build()'
```

To this:

```yml
      - name: Build the book
        run: julia --project -e 'using MyBook; MyBook.build()'
```

Now with this complete, push your changes to your book's repository and GitHub Actions should now generate and serve your website!
