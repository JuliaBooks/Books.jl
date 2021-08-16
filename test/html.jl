@testset "html" begin
    @test B.split_keepdelim("a. 1 b. 2", r"[a|b]") == SubString{String}["a. 1 ", "b. 2"]

    s = """
        <img src="$(B.BUILD_DIR)/im/example.png" alt="example" />
        and
        <img src="$(B.BUILD_DIR)/im/bar.png" alt="bar" />
        """
    url_prefix = ""
    cd(joinpath(Books.PROJECT_ROOT, "docs")) do
        dir = joinpath(Books.BUILD_DIR, "im")
        mkpath(dir)
        touch(joinpath(dir, "example.svg"))
        @test B.fix_image_urls(s, url_prefix) == """
            <img src="/im/example.svg" alt="example" />
            and
            <img src="/im/bar.png" alt="bar" />
            """
    end

    h = """
    <body>
    <!-- end head -->
    <h1 class="unnumbered" id="welcome">Welcome</h1>
    <p>Lorem ipsum</p>
    <h2 data-number="0.1" id="sec:getting-started">Getting started</h2>
    <p>Dolar</p>
    <h1 data-number="1" id="sec:something">Something</h1>
    <p>Baz</p>
    <h2 data-number="1.1" id="embedding-code">Embedding code</h2>
    <!-- begin foot -->
    <div class="license">John Doe</div>
    """

    head, bodies, foot = B.split_html(h)
    @test contains(head, "<body>")
    @test length(bodies) == 4
    @test contains(foot, "John")

    text = """
    <h1 data-number="1" id="sec:intro"><span class="header-section-number">1</span> Introduction</h1>
    <p>This is the introduction.</p>
    <h2 data-number="1.1" id="subsection"><span class="header-section-number">1.1</span> Subsection</h2>
    <h1 class="unnumbered" id="references"> References</h1>
    <h1 data-number="3" id="id"><span class="header-section-number">3</span> Getting Started</h1>
    <h1 class="unnumbered" id="id"> Getting Started</h1>
    """
    infos = B.section_infos(text)
    @test infos[1] == Books.SectionInfo("1", "sec:intro", "Introduction")
    @test infos[2] == Books.SectionInfo("1.1", "subsection", "Subsection")
    @test infos[3] == Books.SectionInfo("", "references", "References")
    @test infos[4] == Books.SectionInfo("3", "id", "Getting Started")
    @test infos[5] == Books.SectionInfo("", "id", "Getting Started")

    ids_texts = B.html_page_name.(bodies)
    id_names = getproperty.(ids_texts, :id)
    @test id_names == ["welcome", "getting-started", "something", "embedding-code"]

    text = "<h1 data-number=\"1\" id=\"前言\"><span class=\"header-section-number\">1</span> 前言</h1>"
    infos = B.section_infos(text)
    @test infos[1] == Books.SectionInfo("1", "前言", "前言")

    names = ["test"]
    page = raw"""
        <!DOCTYPE html>
        <link rel="stylesheet" href="/files/style.css"/>
        <a href="#sec:foo">Foo</a>
        <h2 data-number="3.5" id="sec:foo"><span class="header-section-number">3.5</span> Foo</h2>
        <p> <a href="https://www.example.com">Jump</a></p>
        """
    pages = [page]
    docs_dir = joinpath(pkgdir(Books), "docs")
    cd(docs_dir) do
        url_prefix = Books.ci_url_prefix("default")
        @test url_prefix != ""
        actual = Books.fix_links(names, pages, url_prefix) |> last |> first
        expected = """
            <!DOCTYPE html>
            <link rel="stylesheet" href="/Books.jl/files/style.css"/>
            <a href="/Books.jl/test.html#sec:foo">Foo</a>
            <h2 data-number="3.5" id="sec:foo"><span class="header-section-number">3.5</span> Foo</h2>
            <p> <a href="https://www.example.com">Jump</a></p>
            """
        @test actual == expected
    end
    url_prefix = ""
    actual = Books.fix_links(names, pages, url_prefix) |> last |> first
    expected = """
        <!DOCTYPE html>
        <link rel="stylesheet" href="/files/style.css"/>
        <a href="/test.html#sec:foo">Foo</a>
        <h2 data-number="3.5" id="sec:foo"><span class="header-section-number">3.5</span> Foo</h2>
        <p> <a href="https://www.example.com">Jump</a></p>
        """
    @test actual == expected
end
