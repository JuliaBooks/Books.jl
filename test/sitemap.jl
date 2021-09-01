"""
    lstrip_lines(text)

Strip whitespace at the left of lines.
Helper function for testing.
"""
function lstrip_lines(text)
    lines = split(text, '\n')
    lines = lstrip.(lines)
    text = join(text, '\n')
    return text
end

@testset "sitemap" begin
    project = "default"
    cd(joinpath(Books.PROJECT_ROOT, "docs")) do
        h = Books.pandoc_html(project)
        text = Books.sitemap(h)
        expected = """
            <url>
            <loc>http://https://rikhuijzer.github.io/Books.jl</loc>
            <lastmod>$(today())</lastmod>
            <changefreq>monthly</changefreq>
            </url>
            """
        @test text == expected
    end
end
