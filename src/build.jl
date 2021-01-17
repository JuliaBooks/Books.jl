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
inputs = [
    "chapters/introduction.md",
    "chapters/demo.md"
]

function pandoc(args) 
    cmd = `pandoc $args`
    @show cmd
    try 
        stdout = IOBuffer()
        run(pipeline(cmd; stdout))
        println(String(take!(stdout)))
    catch e
        println(e)
    end
end

function html()
    template = "--template pandoc/template.html"
    output_filename = "build/html/index.html"
    output = "--output=$output_filename"
    html_inputs = ["index.md"; inputs]

    args = [
        html_inputs;
        crossref;
        citeproc;
        metadata;
        extra_args;
        # output
    ]
    pandoc(args)
end

function pdf()
    template = "--template pandoc/template.html"
    pdf_dir = joinpath("build", "pdf")
    output_filename = joinpath(pdf_dir, "book.pdf")
    output = "--output=$output_filename"
    if !isdir(pdf_dir); mkpath(pdf_dir); end

    args = [
        inputs;
        crossref;
        citeproc;
        metadata;
        extra_args;
        output
    ]
    pandoc(args)
end

function book()
    html()
    pdf()
end
