@testset "build" begin
    docs_dir = joinpath(Books.PROJECT_ROOT, "docs")
    url_prefix = ""
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

        mkpath(joinpath(Books.BUILD_DIR, "images"))
        gen("test"; project="test")
        out = Books._pandoc_html("test", url_prefix)
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
        @test strip(actual) == strip(exp)
    end

    out = cd(docs_dir) do
        test_markdown_path = joinpath(docs_dir, "contents", "test.md")
        test_markdown = raw"""
            # Test {#sec:test}

            @undefined_reference.
            """
        write(test_markdown_path, test_markdown)

        mkpath(joinpath(Books.BUILD_DIR, "images"))
        gen("test"; project="test")
        try
            Books._pandoc_html("test", url_prefix; fail_on_error=true)
            error("Expected _pandoc_html to fail.")
        catch
        end
        try
            Books.html("test", fail_on_error=false)
            error("Expected _pandoc_html to fail.")
        catch
        end
    end

    out = cd(docs_dir) do
        test_markdown_path = joinpath(docs_dir, "contents", "test.md")
        third_level_indentation = """
            1. This is the second level
                * This is the third level

                   ```jl
                   s = "x = 1 + 2"
                   sco(s)
                   ```

                * Another item
            """
        write(test_markdown_path, third_level_indentation)

        mkpath(joinpath(Books.BUILD_DIR, "images"))
        gen("test"; project="test")
        out = Books.embed_output(third_level_indentation)

        lines = split(out, '\n')
        # Due to, probably, the Regex, it can happen that the first line gets indented too much.
        @test lines[4] == "       ```language-julia"
        @test lines[5] == "       x = 1 + 2"
    end

    out = cd(docs_dir) do
        test_markdown_path = joinpath(docs_dir, "contents", "test.md")
        inline_code = """
            Ans: `jl 1 + 1`.
            """
        write(test_markdown_path, inline_code)

        mkpath(joinpath(Books.BUILD_DIR, "images"))
        gen("test"; project="test")
        out = Books.embed_output(inline_code)

        lines = split(out, '\n')
        @test lines[1] == "Ans: 2."
    end

    # Four indentations.
    not_evaluated_block = """
            ```jl
            x = 1 + 1
            y = 2 + 2
            ```
        """
    out = Books.embed_output(not_evaluated_block)
    @test out == "    ```jl\n    x = 1 + 1\n    y = 2 + 2\n    ```\n"
end
