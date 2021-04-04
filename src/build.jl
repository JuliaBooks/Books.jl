function pandoc_file(filename)
    user_path = joinpath("pandoc", filename)
    fallback_path = joinpath(PROJECT_ROOT, "defaults", filename)
    isfile(user_path) ? user_path : fallback_path
end

include_files_lua = joinpath(PROJECT_ROOT, "src", "include-files.lua")
include_files = "--lua-filter=$include_files_lua"
crossref = "--filter=pandoc-crossref"
citeproc = "--citeproc"
metadata_path = joinpath(GENERATED_DIR, "metadata.yml")
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
    html_template_path = pandoc_file("template.html")
    template = "--template=$html_template_path"
    output_filename = joinpath(BUILD_DIR, "index.html")
    output = "--output=$output_filename"
    html_inputs = ["index.md"; inputs(project)]
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

function html(; project="default")
    url_prefix = is_ci() ? '/' * config(project)["online_url_prefix"] : ""
    C = config(project)["contents"]
    write_html_pages(url_prefix, C, pandoc_html(project, url_prefix))
end

function pdf(; project="default")
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
