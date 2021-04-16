# Getting started {#sec:getting-started}

The easiest way to get started is to

1. copy over the files in [docs/](https://github.com/rikhuijzer/Books.jl/tree/main/docs)
1. step inside that directory and
1. serve your book via:

```{.include}
_gen/serve_example.md
```

To generate all the Julia output (see @sec:embedding-output for more information) use

```{.include}
_gen/generate_example.md
```

As the number of outputs increases, you might want to only update one output:

```{.include}
_gen/gen_function_docs.md
```

To avoid code duplication between projects, this package tries to have good defaults for many settings.
For your project, you can override the default settings by creating `Config.toml` and `Metadata.yml` files.
In summary, the `Metadata.yml` file is read by Pandoc while generating the outputs.
This file contains settings for the output appearance, author and more, see @sec:metadata.
The `Config.toml` file is read by Books.jl before calling Pandoc, so contains settings which are essentially passed to Pandoc, see @sec:config.
Still, these defaults can be overwritten.
If you also want to override the templates, then see @sec:templates.

## Metadata.yml {#sec:metadata}

The `Metadata.yml` file is read by Pandoc.
Settings in this file affect the behaviour of Pandoc and get inserted in the templates.
For more info on templates, see @sec:templates.
The following default settings are used by Books.jl.
You can override settings by placing a `Metadata.yml` file at the root directory of your project.

```{.include}
_gen/default_metadata.md
```

## Config.toml {#sec:config}

The `Config.toml` file is used by Books.jl.
Settings in this file affect how Pandoc is called.
In `Config.toml`, you can define multiple projects; at least define `projects.default`.
The settings of `projects.default` are used when you call `pdf()` or `serve()`.
To use other settings, for example the settings for `dev`, use `pdf(project="dev")` or `serve(project="dev")`.

Below, the default configuration is shown.
When not defining a `Config.toml` file or omitting any of the settings, such as `port`, these defaults will be used.
The benefit of multiple projects is, for example, that you can run a `dev` project locally which contains more information than the `default` project.
One example could be where you write a paper, book or report and have a page with some notes.

The meaning of `contents` is discussed in @sec:about_contents.
The `pdf_filename` is used by `pdf()` and the `port` setting is used by `serve()`.

```{.include}
_gen/default_config.md
```

Here, the `extra_directories` allows you to specify directories which need to be moved into `build`, which makes them available for the local server and online.
This is, for instance, useful for images like @fig:book_store.

<pre>
![Book store.](images/book-store.jpg){#fig:book_store}
</pre>

![Book store.](images/book-store.jpg){#fig:book_store}

### About contents {#sec:about_contents}

The files listed in `contents` are read from the `contents/` directory and passed to Pandoc in the order specified by this list.
It doesn't matter whether the files contain headings or at what levels the heading are.
Pandoc will just place the texts behind each other.

This list doesn't mention `index.md` located in `contents/`.
`index.md` is added automatically when generating html output and will be the [homepage](/) for the website.
It typically contains the link to the generated PDF.
Note that content placed `index.md` is only added to the html output and not to pdf or other outputs.

## Templates {#sec:templates}

Unlike `Metadata.yml` and `Config.toml`, the default templates should be good for most users.
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
