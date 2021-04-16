function pandoc_file(filename)
    user_path = joinpath("pandoc", filename)
    fallback_path = joinpath(PROJECT_ROOT, "defaults", filename)
    isfile(user_path) ? user_path : fallback_path
end

include_files_lua = joinpath(PROJECT_ROOT, "src", "include-files.lua")
include_files = "--lua-filter=$include_files_lua"
crossref = "--filter=pandoc-crossref"
citeproc = "--citeproc"
metadata_path = joinpath(GENERATED_DIR, "Metadata.yml")
metadata = "--metadata-file=$metadata_path"

function csl()
    csl_path = pandoc_file("style.csl")
    csl = "--csl=$csl_path"
end

extra_args = [
    "--number-sections",
    "--top-level-division=chapter"
]

function inputs(project)
    C = config(project)["contents"]
    [joinpath("contents", "$content.md") for content in C]
end

"""
    copy_extra_directory(dir)

Copy an extra directory such as "images" into build.
"""
function copy_extra_directory(dir)
    if !isdir(dir)
        error("Couldn't find $dir even though it was listed in `extra_directories`")
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
    extra_directories = config(project)["extra_directories"]
    copy_extra_directory.(extra_directories)
end

function call_pandoc(args)
    write_metadata()
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

function pandoc_html(project::AbstractString, url_prefix)
    copy_extra_directories(project)
    html_template_path = pandoc_file("template.html")
    template = "--template=$html_template_path"
    output_filename = joinpath(BUILD_DIR, "index.html")
    output = "--output=$output_filename"
    index_path = joinpath("contents", "index.md")
    html_inputs = [index_path; inputs(project)]
    filename = "style.css"
    css_path = pandoc_file(filename)
    cp(css_path, joinpath(BUILD_DIR, filename); force=true)

    args = [
        html_inputs;
        include_files;
        crossref;
        citeproc;
        "--mathjax";
        "--metadata=url-prefix:$url_prefix";
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
julia> cd(pkdir(Books)) do
           Books.ci_url_prefix("default")
       end
""

julia> cd("docs") do
           Books.ci_url_prefix("default")
       end
"/Books.jl"
"""
function ci_url_prefix(project)
    user_setting = config(project)["online_url_prefix"]
    if user_setting != ""
        user_setting = '/' * user_setting
    end
    user_setting
end

function html(; project="default")
    copy_extra_directories(project)
    url_prefix = is_ci() ? ci_url_prefix(project) : ""
    C = config(project)["contents"]
    write_html_pages(url_prefix, C, pandoc_html(project, url_prefix))
end

function pdf(; project="default")
    copy_extra_directories(project)
    latex_template_path = pandoc_file("template.tex")
    template = "--template=$latex_template_path"
    file = config(project)["output_filename"]
    output_filename = joinpath(BUILD_DIR, "$file.pdf")
    output = "--output=$output_filename"

    Tectonic.tectonic() do tectonic_bin
        pdf_engine = "--pdf-engine=$tectonic_bin"

        args = [
            inputs(project);
            include_files;
            crossref;
            citeproc;
            csl();
            metadata;
            template;
            "--listings";
            pdf_engine;
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
    file = config(project)["output_filename"]
    output_filename = joinpath(BUILD_DIR, "$file.docx")
    output = "--output=$output_filename"

    args = [
        inputs(project);
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
