"""
    split_html(html)

Split `html` into chapters.
We need this function because Pandoc needs all the files at the same time to allow for cross-references.

!!! warning

    This function assumes that every chapter starts with a `h1` heading like `# Introduction`.
"""
function split_html(h)
    head_pattern = "<!-- end head -->"
    head, after_head = split(h, head_pattern)
    foot_pattern = "<!-- begin foot -->"
    body, foot = split(after_head, foot_pattern)

    start = "<h1"
    chapters = split(body, start)
    chapters = [start*c for c in chapters[2:end]]
    (head = head, chapters = chapters, foot = foot)
end

function html_pages(chs=chapters, h=pandoc_html())
    head, html_chapters, foot = split_html(h)
    pages = [head * c * foot for c in html_chapters]
    names = ["index"; chs]
    Dict(zip(names, pages))
end

"""
    map_ids(pages=html_pages())

Returns a mapping from `id` to `page_name`.
This is used to allow one page to link to elements on another page.
"""
function map_ids(pages=html_pages())
    mapping = Dict()
    rx = r"id=\"([^\"]*)\""
    for name in keys(pages)
        html = pages[name]     
        matches = eachmatch(rx, html)
        for m in matches
            capture = first(m.captures)
            if startswith(capture, "sec:")
                key = '#' * capture
                mapping[key] = name
            end
        end
    end
    mapping
end

function fix_links(pages=html_pages())
    mapping = map_ids(pages)
    rx = r"href=\"([^\"]*)\""
    uncapture(capture) = "href=\"$capture\""
    for name in keys(pages)
        html = pages[name]     
        function replace_match(s) 
            capture = first(match(rx, s).captures)
            if startswith(capture, "#sec:")
                page_link = mapping[capture]
                return uncapture("/$page_link.html$capture")
            elseif startswith(capture, "#ref-")
                page_link = "references"
                return uncapture("/$page_link.html$capture")
            else
                return uncapture(capture)
            end
        end
        fixed = replace(html, rx => replace_match)
        pages[name] = fixed
    end
    pages
end

function write_html_pages(chs=chapters, h=pandoc_html())
    pages = fix_links(html_pages(chapters, h))
    for name in keys(pages)
        path = joinpath(build_dir, "$name.html")
        write(path, pages[name])
    end
end
