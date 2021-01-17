export
    book,
    html,
    pdf

crossref = "--filter=pandoc-crossref"
citeproc = "--filter=pandoc-citeproc"
metadata = "--metadata-file=metadata.yml"
extra_args = ["--number-sections", "--top-level-division=chapter"]

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
    inputs = [
        "index.md",
        "chapters/introduction.md",
        "chapters/demo.md"
    ]
    output_filename = "build/html/index.html"
    output = "--output=$output_filename"

    args = [
        inputs;
        crossref;
        citeproc;
        metadata;
        extra_args;
        # output
    ]
    pandoc(args)
end

function pdf()
    "not implemented"
end

function book()
    html()
    pdf()
end
