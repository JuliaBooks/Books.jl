"""
    lstrip_lines(text)

Strip whitespace at the left of lines.
Helper function for testing.
"""
function lstrip_lines(text)
    lines = split(text, '\n')
    lines = lstrip.(lines)
    text = join(lines, '\n')
    return text
end

@testset "sitemap" begin
    html_suffix = Books.HTML_SUFFIX
    online_url = "https://example.com"
    online_url_prefix = "Foo.jl/"
    link = "index"
    actual = Books.html_loc(online_url, online_url_prefix, link)
    @test actual == "https://example.com/Foo.jl/index$(html_suffix)"

    project = "test"
    cd(joinpath(Books.PROJECT_ROOT, "docs")) do
        h = Books.pandoc_html(project)
        text = Books.sitemap(project, h)
        @test startswith(text, "<?xml")
        @test endswith(rstrip(text), "</urlset>")
        text = lstrip_lines(text)
        expected = """
            <url>
            <loc>https://books.huijzer.xyz/welcome$html_suffix</loc>
            <lastmod>$(today())</lastmod>
            <changefreq>monthly</changefreq>
            </url>
            """
        @test contains(text, expected)
    end
end
