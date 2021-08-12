# Getting started {#sec:getting-started}

The easiest way to get started is to

1. copy over the files in [docs/](https://github.com/rikhuijzer/Books.jl/tree/main/docs)
1. step inside that directory and
1. serve your book via:

```jl
M.serve_example()
```

To generate all the Julia output (see @sec:embedding-output for more information) use

```
$ julia --project -e  'using Books; using MyPackage; M = MyPackage'

julia> gen()
[...]
Updating html
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
You can override settings by placing a `metadata.yml` file at the root directory of your project.
For example, the metadata for this project contains:

```jl
M.docs_metadata()
```

The following defaults are set by Books.jl.

```jl
M.default_metadata()
```

## config.toml {#sec:config}

The `config.toml` file is used by Books.jl.
Settings in this file affect how Pandoc is called.
In `config.toml`, you can define multiple projects; at least define `projects.default`.
The settings of `projects.default` are used when you call `pdf()` or `serve()`.
To use other settings, for example the settings for `dev`, use `pdf(project="dev")` or `serve(project="dev")`.

Below, the default configuration is shown.
When not defining a `config.toml` file or omitting any of the settings, such as `port`, these defaults will be used.
You don't have to copy all these defaults, only _override_ the settings that you want to change.
The benefit of multiple projects is, for example, that you can run a `dev` project locally which contains more information than the `default` project.
One example could be where you write a paper, book or report and have a page with some notes.

The meaning of `contents` is discussed in @sec:about_contents.
The `pdf_filename` is used by `pdf()` and the `port` setting is used by `serve()`.
For this documentation, the following config is used

```jl
M.docs_config()
```

Which overrides some settings from the following default settings

```jl
M.default_config()
```

Here, the `extra_directories` allows you to specify directories which need to be moved into `_build`, which makes them available for the local server and online.
This is, for instance, useful for images like @fig:store:

<pre class="language-markdown">
![Book store.](images/book-store.jpg){#fig:book_store}
</pre>

![Book store.](images/book-store.jpg){#fig:store}

### About contents {#sec:about_contents}

The files listed in `contents` are read from the `contents/` directory and passed to Pandoc in the order specified by this list.
It doesn't matter whether the files contain headings or at what levels the heading are.
Pandoc will just place the texts behind each other.

This list doesn't mention the [homepage](/) for the website.
That one is specified on a per project basis with `homepage_contents`, which defaults to `index`.
The homepage typically contains the link to the generated PDF.
Note that the homepage is only added to the html output and not to pdf or other outputs.

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
