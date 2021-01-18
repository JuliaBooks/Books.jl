
@testset "html" begin
    text = """
    <h1 data-number="1" id="sec:intro"><span class="header-section-number">1</span> Introduction</h1>
    <p>This is the introduction.</p>
    <h2 data-number="1.1" id="subsection"><span class="header-section-number">1.1</span> Subsection</h2>
    """
    tuples = B.section_infos(text)
    @test tuples[1] == ("1", "sec:intro", "Introduction")
    @test tuples[2] == ("1.1", "subsection", "Subsection")
end
