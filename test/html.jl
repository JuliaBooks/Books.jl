
@testset "html" begin
    text = """
    <h1 data-number="1" id="sec:intro"><span class="header-section-number">1</span> Introduction</h1>
    <p>This is the introduction.</p>
    <h2 data-number="1.1" id="subsection"><span class="header-section-number">1.1</span> Subsection</h2>
    <h1 class="unnumbered" id="references"> References</h1>
    <h1 data-number="3" id="id"><span class="header-section-number">3</span> Getting Started</h1>
    <h1 class="unnumbered" id="id"> Getting Started</h1>
    """
    tuples = B.section_infos(text)
    @test tuples[1] == ("1", "sec:intro", "Introduction")
    @test tuples[2] == ("1.1", "subsection", "Subsection")
    @test tuples[3] == ("", "references", "References")
    @test tuples[4] == ("3", "id", "Getting Started")
    @test tuples[5] == ("", "id", "Getting Started")
end
