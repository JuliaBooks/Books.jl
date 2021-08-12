# Deploying Books.jl to a Web Service

## GitHub Pages

### Initial Configuration

To configure your book for deployment to GitHub Pages, you will need to do the following setup:



### Setting Up Continuous Integration

Now, to have `Books.jl` automatically build your website each time you make a commit to your repository, you will need to create two directories in your repository called `.github/workflows`.
Within that folder, add the following example Continuous Integration configuration as a file called `CI.yml`:

```yml
name: CI

on:
  push:
    branches:
      - main
  pull_request:
  workflow_dispatch:

jobs:
  build-and-deploy:
    runs-on: ubuntu-20.04
    steps:
      - uses: actions/checkout@v2
        with:
          persist-credentials: false

      - uses: julia-actions/setup-julia@v1
        with:
          version: "1.6"

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

      # Enforce most recent version.
      - name: Install Books.jl#main
        run: julia --project -e 'using Pkg;
          Pkg.add(url="https://github.com/rikhuijzer/Books.jl#main");'

      - name: Install dependencies
        run: julia --project -e 'using Pkg; Pkg.instantiate();
                using Books; Books.install_dependencies()'

      - name: Deploy to secondary branch
        if: ${{ github.event_name != 'pull_request' }}
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          force_orphan: true
          publish_dir: ./_build/
```
