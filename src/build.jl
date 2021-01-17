export
    book,
    html,
    pdf

crossref = "--filter=pandoc-crossref"
citeproc = "--filter=pandoc-citeproc"
metadata = "--metadata-file=metadata.yml"
extra_args = [
    "--number-sections",
    "--top-level-division=chapter"
]
chapters = [
    "introduction",
    "demo",
    "references"
]
build_dir = "build"
mkpath(build_dir)

inputs() = [joinpath("chapters", "$chapter.md") for chapter in chapters]

function pandoc(args) 
    cmd = `pandoc $args`
    @show cmd
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

    args = [
        html_inputs;
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
    write_html_pages(chapters, pandoc_html())
end

function pdf()
    template = "--template=pandoc/eisvogel.tex"
    output_filename = joinpath(build_dir, "book.pdf")
    output = "--output=$output_filename"

    args = [
        inputs();
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

function book()
    html()
    pdf()
end
