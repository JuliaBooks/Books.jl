function pandoc_file(filename)
    user_path = joinpath("pandoc", filename)
    fallback_path = joinpath(PROJECT_ROOT, "defaults", filename)
    isfile(user_path) ? user_path : fallback_path
end

include_files_lua = joinpath(PROJECT_ROOT, "src", "include-files.lua")
include_files = "--lua-filter=$include_files_lua"
crossref = "--filter=pandoc-crossref"
citeproc = "--citeproc"

install_extra_fonts()

function csl()
    csl_path = pandoc_file("style.csl")
    csl = "--csl=$csl_path"
end

extra_args = [
    "--number-sections",
    "--top-level-division=chapter"
]

function inputs(project)
    H = config(project, "homepage_contents")
    C = config(project, "contents")
    names = [H; C]
    [joinpath("contents", "$name.md") for name in names]
end

"""
    copy_extra_directory(dir)

Copy an extra directory such as "images" into build.
"""
function copy_extra_directory(dir)
    if !isdir(dir)
        error("Couldn't find `$(dir)` even though it was listed in `extra_directories`")
    end
    from = dir
    to = joinpath(BUILD_DIR, dir)
    cp(from, to; force=true)
end

"""
    copy_extra_directories(project)

Copy the extra directories defined for `project`.
"""
function copy_extra_directories(project)
    extra_directories = config(project, "extra_directories")
    copy_extra_directory.(extra_directories)
end

function call_pandoc(args)
    pandoc() do pandoc_bin
        pandoc_crossref() do _
            cmd = `$pandoc_bin $args`
            stdout = IOBuffer()
            p = run(pipeline(cmd; stdout))
            out = String(take!(stdout))
            return (p, out)
        end
    end
end

function pandoc_html(project::AbstractString)
    copy_extra_directories(project)
    html_template_path = pandoc_file("template.html")
    template = "--template=$html_template_path"
    output_filename = joinpath(BUILD_DIR, "index.html")
    output = "--output=$output_filename"
    filename = "style.css"
    css_path = pandoc_file(filename)
    cp(css_path, joinpath(BUILD_DIR, filename); force=true)
    metadata_path = write_metadata(config(project, "metadata_path"))
    metadata = "--metadata-file=$metadata_path"

    args = [
        inputs(project);
        include_files;
        crossref;
        citeproc;
        "--mathjax";
        csl();
        metadata;
        template;
        extra_args;
        # output
    ]
    _, out = call_pandoc(args)
    out
end

"""
    ci_url_prefix(project)

Return the url prefix when `is_ci() == true`.

# Example
```jldoctest
julia> cd(pkgdir(Books)) do
           Books.ci_url_prefix("default")
       end
""

julia> cd(joinpath(pkgdir(Books), "docs")) do
           Books.ci_url_prefix("default")
       end
"/Books.jl"
```
"""
function ci_url_prefix(project)
    user_setting = config(project, "online_url_prefix")
    user_setting
end

function html(; project="default")
    copy_extra_directories(project)
    url_prefix = is_ci() ? ci_url_prefix(project) : ""
    c = config(project, "contents")
    write_html_pages(url_prefix, c, pandoc_html(project))
end

"""
    ignore_homepage(project, input_paths)

By default, the homepage is only shown to website visitors.
However, the user can show the homepage also to offline visitors via the configuration option.
"""
function ignore_homepage(project, input_paths)
    c = config(project)
    override::Bool = config(project, "include_homepage_outside_html")
    override ? input_paths : input_paths[2:end]
end

function juliamono_path()
    artifact = Artifacts.artifact"juliamono"
    dir = joinpath(artifact, "juliamono-0.040")
    # The forward slash is required by LaTeX.
    dir * '/'
end

function pdf(; project="default")
    copy_extra_directories(project)
    latex_template_path = pandoc_file("template.tex")
    template = "--template=$latex_template_path"
    file = config(project, "output_filename")
    output_filename = joinpath(BUILD_DIR, "$file.pdf")
    output = "--output=$output_filename"
    metadata_path = write_metadata(config(project, "metadata_path"))
    metadata = "--metadata-file=$metadata_path"
    input_files = ignore_homepage(project, inputs(project))
    juliamono_template_var = "--variable=juliamono-path:$(juliamono_path())"

    Tectonic.tectonic() do tectonic_bin
        pdf_engine = "--pdf-engine=$tectonic_bin"

        args = [
            input_files;
            include_files;
            crossref;
            citeproc;
            csl();
            metadata;
            template;
            "--listings";
            pdf_engine;
            juliamono_template_var;
            extra_args;
            output
        ]
        out = call_pandoc(args)
        if !isnothing(out)
            println("Built $output_filename")
        end

        # For debugging purposes.
        output_filename = joinpath(BUILD_DIR, "$file.tex")
        args[end] = "--output=$output_filename"
        call_pandoc(args)
    end

    nothing
end

function docx(; project="default")
    file = config(project, "output_filename")
    output_filename = joinpath(BUILD_DIR, "$file.docx")
    output = "--output=$output_filename"
    metadata_path = write_metadata(config(project, "metadata_path"))
    metadata = "--metadata-file=$metadata_path"
    input_files = ignore_homepage(project, inputs(project))

    args = [
        input_files;
        include_files;
        crossref;
        citeproc;
        metadata;
        output
    ]
    out = call_pandoc(args)
    if !isnothing(out)
        println("Built $output_filename")
    end
    nothing
end

function build_all(; project="default")
    mkpath(BUILD_DIR)
    filename = "favicon.png"
    cp(joinpath("pandoc", filename), joinpath(BUILD_DIR, filename); force=true)
    html(; project)
    pdf(; project)
    docx(; project)
end
