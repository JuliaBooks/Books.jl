@testset "build" begin
    docs_dir = joinpath(Books.PROJECT_ROOT, "docs")
    out = cd(docs_dir) do
        test_markdown_path = joinpath(docs_dir, "contents", "test.md")
        test_markdown = raw"""
            # Test {#sec:test}

            This test file is not included in the documentation.

            ```jl
            s = "x = 1 + 1"
            sco(s)
            ```
            """
        write(test_markdown_path, test_markdown)

        gen("test"; project="test")
        out = Books.pandoc_html("test")
        return out
    end

    sec = "<h1 data-number=\"1\" id=\"sec:test\">"
    @test contains(out, sec)
    test_page_begin = first(findfirst(sec, out))
    test_page_end = first(findfirst("<!-- begin foot -->", out)) - 1
    test_page = SubString(out, test_page_begin, test_page_end)
    lines = split(test_page, '\n')
    expected = [
        """<h1 data-number="1" id="sec:test"><span class="header-section-number">1</span> Test</h1>""",
        """<p>This test file is not included in the documentation.</p>""",
        """<pre class="language-julia"><code>x = 1 + 1</code></pre>""",
        """<p>2</p>"""
    ]
    for (actual, exp) in zip(lines, expected)
        @test actual == exp
    end
end
