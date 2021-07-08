function pandoc_file(filename)
    user_path = joinpath("pandoc", filename)
    fallback_path = joinpath(PROJECT_ROOT, "defaults", filename)
    isfile(user_path) ? user_path : fallback_path
end

include_lua_filter = joinpath(PROJECT_ROOT, "src", "include-codeblocks.lua")
include_files = "--lua-filter=$include_lua_filter"
crossref = "--filter=pandoc-crossref"
citeproc = "--citeproc"

function csl()
    csl_path = pandoc_file("style.csl")
    csl = "--csl=$csl_path"
end

extra_args = [
    "--number-sections",
    "--top-level-division=chapter"
]

function inputs(project)
    H = config(project, "homepage_contents")::String
    C = config(project, "contents")::Vector{String}
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
    extra_directories = config(project, "extra_directories")::Vector
    copy_extra_directory.(extra_directories)
end

function call_pandoc(args)::Tuple{Base.Process, String}
    pandoc() do pandoc_bin
        pandoc_crossref() do _
            cmd = `$pandoc_bin $args`
            stdout = IOBuffer()
            p = run(pipeline(cmd; stdout))
            out = String(take!(stdout))::String
            return (p, out)
        end
    end
end

function copy_css()
    filename = "style.css"
    css_path = pandoc_file(filename)
    cp(css_path, joinpath(BUILD_DIR, filename); force=true)
end

@memoize function is_mousetrap_enabled()::Bool
    meta = default_metadata()::Dict
    if "mousetrap" in keys(meta)
        meta["mousetrap"]::Bool
    else
        false
    end
end

@memoize function copy_mousetrap()
    if is_mousetrap_enabled()
        filename = "mousetrap.min.js"
        from = pandoc_file(filename)
        cp(from, joinpath(BUILD_DIR, filename); force=true)
    end
end

@memoize function copy_juliamono()
    filename = "JuliaMono-Regular.woff2"
    from_path = joinpath(JULIAMONO_PATH, "webfonts", filename)
    cp(from_path, joinpath(BUILD_DIR, filename); force=true)
end

function pandoc_html(project::AbstractString)
    copy_extra_directories(project)
    html_template_path = pandoc_file("template.html")
    template = "--template=$html_template_path"
    output_filename = joinpath(BUILD_DIR, "index.html")
    output = "--output=$output_filename"
    metadata_path = config(project, "metadata_path")::String
    write_metadata(metadata_path)
    metadata = "--metadata-file=$metadata_path"
    copy_css()
    copy_mousetrap()
    copy_juliamono()

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
    ]::Vector{String}
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

function html(; project="default", extra_head="")
    copy_extra_directories(project)
    url_prefix = is_ci() ? ci_url_prefix(project)::String : ""
    c = config(project, "contents")
    write_html_pages(url_prefix, pandoc_html(project), extra_head)
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
    artifact = Artifacts.artifact"JuliaMono"
    dir = joinpath(artifact, "juliamono-0.040")
    # The forward slash is required by LaTeX.
    dir * '/'
end
const JULIAMONO_PATH = juliamono_path()

function pdf(; project="default")
    copy_extra_directories(project)
    latex_template_path = pandoc_file("template.tex")
    template = "--template=$latex_template_path"
    file = config(project, "output_filename")
    output_filename = joinpath(BUILD_DIR, "$file.pdf")
    output = "--output=$output_filename"
    metadata_path = config(project, "metadata_path")::String
    write_metadata(metadata_path)
    metadata = "--metadata-file=$metadata_path"
    input_files = ignore_homepage(project, inputs(project))
    juliamono_template_var = "--variable=juliamono-path:$JULIAMONO_PATH"

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
            extra_args
        ]
        output_tex_filename = joinpath(BUILD_DIR, "$file.tex")
        println("Wrote $output_tex_filename (for debugging purposes)")
        tex_output = "--output=$output_tex_filename"
        call_pandoc([args; tex_output])

        out = call_pandoc([args; output])
        if !isnothing(out)
            println("Built $output_filename")
        end
    end

    nothing
end

function docx(; project="default")
    file = config(project, "output_filename")
    output_filename = joinpath(BUILD_DIR, "$file.docx")
    output = "--output=$output_filename"
    metadata_path = config(project, "metadata_path")::String
    write_metadata(metadata_path)
    metadata = "--metadata-file=$metadata_path"
    input_files = ignore_homepage(project, inputs(project))

    args = [
        input_files;
        include_files;
        crossref;
        citeproc;
        csl();
        metadata;
        output
    ]
    out = call_pandoc(args)
    if !isnothing(out)
        println("Built $output_filename")
    end
    nothing
end

function build_all(; project="default", extra_head="")
    mkpath(BUILD_DIR)
    filename = "favicon.png"
    cp(joinpath("pandoc", filename), joinpath(BUILD_DIR, filename); force=true)
    html(; project, extra_head)
    pdf(; project)
    docx(; project)
end
