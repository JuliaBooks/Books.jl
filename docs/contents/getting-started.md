# Getting started {#sec:getting-started}

The easiest way to get started is to copy over the files in `docs/`, step inside that directory and serve your book via

```
pkg> add Books

julia> using Books

julia> serve()
[...]
 LiveServer listening on http://localhost:8001/ ...
  (use CTRL+C to shut down)
```

I'm using this package for multiple projects and have tried to set as many default configuration settings as possible.
For your project, override the settings in your `config.toml` and `metadata.yml` files.
In summary, the `metadata.yml` file is read by Pandoc while generating the outputs.
This file contains settings for the output appearance, author and more, see @sec:metadata.
The `config.toml` file is read by Books.jl before calling Pandoc, so contains settings which are essentially passed to Pandoc, see @sec:config.
Still, these defaults can be overwritten.
For the templates, see @sec:templates.

## metadata.yml {#sec:metadata}

The `metadata.yml` file is read by Pandoc.
Settings in this file affect the behaviour of Pandoc and get inserted in the templates.
For more info on templates, see @sec:templates.
The following default settings are used by Books.jl.
You can override settings by placing a `metadata.yml` file at the root directory of your project.

```{.include}
_generated/metadata.md
```

## config.toml {#sec:config}

## Templates {#sec:templates}

Unlike `metadata.yml` and `config.toml`, the default templates should be good for most users.
To override these, create one or more of the files listed in @tbl:templates.

File | Description | Affects
--- | --- | ---
`pandoc/style.csl` | Citation style | all outputs
`pandoc/style.css` | style sheet | website
`pandoc/template.html` | HTML template | website
`pandoc/template.tex` | PDF template | PDF

: Default templates. {#tbl:templates}

Here, the citation style defaults to APA, because it is the only style that I could find that correctly supports parenthetical and in-text citations. For example,

- in-text: @orwell1945animal
- parenthetical: [@orwell1945animal]

For other citation styles from the [citation-style-language](https://github.com/citation-style-language/styles), users have to manually specify the author in the in-text citations.
