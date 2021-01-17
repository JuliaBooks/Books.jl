"""
    split_html(html)

Split `html` into chapters.
We need this function because Pandoc needs all the files at the same time to allow for cross-references.

!!! warning

    This function assumes that every chapter starts with a main heading like `# Introduction`.
"""
function split_html(h)
    head_pattern = "<!-- end head -->"
    head, after_head = split(h, head_pattern)
    foot_pattern = "<!-- begin foot -->"
    body, foot = split(after_head, foot_pattern)

    start = "<h1 data-number="
    chapters = split(body, start)
    chapters = [start*c for c in chapters[2:end]]
    (head = head, chapters = chapters, foot = foot)
end

function html_pages(chapters, h)
    head, html_chapters, foot = split_html(h)
    pages = [head * c * foot for c in html_chapters]
    keys = ["index"; chapters]
    Dict(zip(keys, pages))
end

function write_html_pages(chapters, h)
    pages = html_pages(chapters, h)
    for chapter in keys(pages)
        path = joinpath(build_dir, "$chapter.html")
        write(path, pages[chapter])
    end
end

write_html_pages() = write_html_pages(chapters, html())
