import TOML

export
    build_all,
    html,
    pdf

const project_root = dirname(dirname(pathof(Books)))
function pandoc_file(filename)
    user_path = joinpath("pandoc", filename)
    fallback_path = joinpath(project_root, "pandoc", filename)
    isfile(user_path) ? user_path : fallback_path
end

include_files_lua = joinpath(project_root, "src", "include-files.lua")
include_files = "--lua-filter=$include_files_lua"
crossref = "--filter=pandoc-crossref"
citeproc = "--filter=pandoc-citeproc"
metadata = "--metadata-file=metadata.yml"

function csl()
    csl_path = pandoc_file("style.csl")
    csl = "--csl=$csl_path"
end

extra_args = [
    "--number-sections",
    "--top-level-division=chapter"
]
function chapters()
    content = read("config.toml", String)    
    t = TOML.parse(content)
    t["chapters"]
end

build_dir = "build"
mkpath(build_dir)

inputs() = [joinpath("chapters", "$chapter.md") for chapter in chapters()]

function pandoc(args) 
    cmd = `pandoc $args`
    try 
        stdout = IOBuffer()
        p = run(pipeline(cmd; stdout))
        out = String(take!(stdout))
        return (p, out)
    catch e
        println(e)
    end
end

function pandoc_html()
    html_template_path = pandoc_file("template.html")
    template = "--template=$html_template_path"
    output_filename = joinpath(build_dir, "index.html")
    output = "--output=$output_filename"
    html_inputs = ["index.md"; inputs()]
    filename = "style.css"
    css_path = pandoc_file(filename)
    cp(css_path, joinpath(build_dir, filename); force=true)

    args = [
        html_inputs;
        include_files;
        crossref;
        citeproc;
        csl();
        metadata;
        template;
        extra_args;
        # output
    ]
    _, out = pandoc(args)
    out
end

function html()
    # rm(build_dir; force = true, recursive = true)
    # mkpath(build_dir)
    write_html_pages(chapters(), pandoc_html())
end

function pdf()
    latex_template_path = pandoc_file("template.tex")
    template = "--template=$latex_template_path"
    output_filename = joinpath(build_dir, "book.pdf")
    output = "--output=$output_filename"

    args = [
        inputs();
        include_files;
        crossref;
        citeproc;
        csl();
        metadata;
        template;
        "--listings";
        extra_args;
        output
    ]
    pandoc(args)
    println("Built $output_filename")
    
    # For debugging purposes.
    output_filename = joinpath(build_dir, "book.tex")
    args[end] = "--output=$output_filename"
    pandoc(args)
    
    nothing
end

function build_all()
    mkpath(build_dir)
    filename = "favicon.png"
    cp(joinpath("pandoc", filename), joinpath(build_dir, filename); force=true)
    html()
    pdf()
end
