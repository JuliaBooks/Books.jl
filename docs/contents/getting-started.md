# Getting started {#sec:getting-started}

The easiest way to get started is to

1. copy over the files in [docs/](https://github.com/rikhuijzer/Books.jl/tree/main/docs)
1. step inside that directory and
1. serve your book via:

```{.include}
_generated/serve_example.md
```

To generate all the Julia output (see @sec:embedding-code for more information) use

```{.include}
_generated/generate_example.md
```

As the number of outputs increases, you might want to only update one output:

```{.include}
_generated/generate_content_function_docs.md
```

To avoid code duplication between projects, this package tries to have good defaults for many settings.
For your project, you can override the default settings by creating `config.toml` and `metadata.yml` files.
In summary, the `metadata.yml` file is read by Pandoc while generating the outputs.
This file contains settings for the output appearance, author and more, see @sec:metadata.
The `config.toml` file is read by Books.jl before calling Pandoc, so contains settings which are essentially passed to Pandoc, see @sec:config.
Still, these defaults can be overwritten.
If you also want to override the templates, then see @sec:templates.

## metadata.yml {#sec:metadata}

The `metadata.yml` file is read by Pandoc.
Settings in this file affect the behaviour of Pandoc and get inserted in the templates.
For more info on templates, see @sec:templates.
The following default settings are used by Books.jl.
You can override settings by placing a `metadata.yml` file at the root directory of your project.

```{.include}
_generated/default_metadata.md
```

## config.toml {#sec:config}

The `metadata.yml` file is used by Books.jl.
Settings in this file affect how Pandoc is called.
Note that `contents` is discussed in more detail in @sec:about_contents.

```{.include}
_generated/default_config.md
```

### About contents {#sec:about_contents}

The files listed in `contents` are read from the `contents/` directory and passed to Pandoc in the order specified by this list.
It doesn't matter whether the files contain headings or at what levels the heading are.
Pandoc will just place the texts behind each other.

This list doesn't mention `index.md` located at the root directory of your project.
`index.md` is added automatically when generating html output and will be the [homepage](/) for the website and typically contains a link to the generated PDF.

## Templates {#sec:templates}

Unlike `metadata.yml` and `config.toml`, the default templates should be good for most users.
To override these, create one or more of the files listed in @tbl:templates.

File | Description | Affects
--- | --- | ---
`pandoc/style.csl` | citation style | all outputs
`pandoc/style.css` | style sheet | website
`pandoc/template.html` | HTML template | website
`pandoc/template.tex` | PDF template | PDF

: Default templates. {#tbl:templates}

Here, the citation style defaults to APA, because it is the only style that I could find that correctly supports parenthetical and in-text citations. For example,

- in-text: @orwell1945animal
- parenthetical: [@orwell1945animal]

For other citation styles from the [citation-style-language](https://github.com/citation-style-language/styles), users have to manually specify the author in the in-text citations.
