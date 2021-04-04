@testset "html" begin
    @test B.split_keepdelim("a. 1 b. 2", r"[a|b]") == SubString{String}["a. 1 ", "b. 2"]

    s = """
        <img src="build/im/example.png" alt="example" />
        and
        <img src="build/im/bar.png" alt="bar" />
        """
    @test B.fix_png_images(s) == """
        <img src="/im/example.svg" alt="example" />
        and
        <img src="/im/bar.svg" alt="bar" />
        """

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
    tuples = B.section_infos(text)
    @test tuples[1] == (num = "1", id = "sec:intro", text = "Introduction")
    @test tuples[2] == (num = "1.1", id = "subsection", text = "Subsection")
    @test tuples[3] == (num = "", id = "references", text = "References")
    @test tuples[4] == (num = "3", id = "id", text = "Getting Started")
    @test tuples[5] == (num = "", id = "id", text = "Getting Started")

    names = B.html_page_names(bodies)
    @test names == ["welcome", "getting-started", "something", "embedding-code"]

    text = "<h1 data-number=\"1\" id=\"前言\"><span class=\"header-section-number\">1</span> 前言</h1>"
    tuples = B.section_infos(text)
    @test tuples[1] == (num = "1", id = "前言", text = "前言")
end
