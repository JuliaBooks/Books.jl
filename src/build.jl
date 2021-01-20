import TOML

export
    build_all,
    html,
    pdf

include_files_lua = joinpath(dirname(pathof(Books)), "include-files.lua")
include_files = "--lua-filter=$include_files_lua"
crossref = "--filter=pandoc-crossref"
citeproc = "--filter=pandoc-citeproc"
metadata = "--metadata-file=metadata.yml"
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
        run(pipeline(cmd; stdout))
        out = String(take!(stdout))
        return out
    catch e
        println(e)
    end
end

function pandoc_html()
    template = "--template=pandoc/template.html"
    output_filename = joinpath(build_dir, "index.html")
    output = "--output=$output_filename"
    html_inputs = ["index.md"; inputs()]
    filename = "style.css"
    cp(joinpath("pandoc", filename), joinpath(build_dir, filename); force=true)

    args = [
        html_inputs;
        include_files;
        crossref;
        citeproc;
        metadata;
        template;
        extra_args;
        # output
    ]
    pandoc(args)
end

function html()
    write_html_pages(chapters(), pandoc_html())
end

function pdf()
    eisvogel_path = joinpath("pandoc", "eisvogel.tex")
    template = "--template=$eisvogel_path"
    output_filename = joinpath(build_dir, "book.pdf")
    output = "--output=$output_filename"

    args = [
        inputs();
        include_files;
        crossref;
        citeproc;
        template;
        metadata;
        extra_args;
        output
    ]
    pandoc(args)
    println("Built $output_filename")
    nothing
end

function build_all()
    mkpath(build_dir)
    filename = "favicon.png"
    cp(joinpath("pandoc", filename), joinpath(build_dir, filename))
    html()
    pdf()
end
