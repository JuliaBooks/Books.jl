"""
    split_html(html)

Split `html` into chapters.
We need this function because Pandoc needs all the files at the same time to allow for cross-references.

!!! warning

    This function assumes that every chapter starts with a `h1` heading like `# Introduction`.
"""
function split_html(h=pandoc_html())
    head_pattern = "<!-- end head -->"
    head, after_head = split(h, head_pattern)
    foot_pattern = "<!-- begin foot -->"
    body, foot = split(after_head, foot_pattern)

    start = "<h1"
    bodies = split(body, start)
    bodies = [start*c for c in bodies[2:end]]
    (head = head, bodies = bodies, foot = foot)
end

html_page_names(chs=chapters) = ["index"; chs]

html_href(text, link) = """<a href="$link">$text</a>"""
html_li(text) = """<li>$text</li>"""

function section_infos(text)
    lines = split(text, '\n')
    rx = r"data-number=\"([^\"]*)\" id=\"([^\"([^\"]*)\""
    tuples = []
    for line in lines
        m = match(rx, line)
        if !isnothing(m)
            number, id = m.captures 
            line_end = split(line, " ")[end]
            text = line_end[1:end-5]
            tuple = (number, id, text)
            push!(tuples, tuple)
        end
    end
    tuples
end

function pandoc_title(metadata="metadata.yml")
    meta = read(metadata, String)
    lines = split(meta, '\n')
    for line in lines
        if startswith(line, "title: ")
            return line[7:end]
        end
    end
end

"""
    add_menu([chs, splitted])

Menu including numbered sections.
"""
function add_menu(chs=chapters, splitted=split_html())
    head, bodies, foot = splitted
    title = pandoc_title()
    
    names = html_page_names(chs)
    menu_items = []
    for (name, body) in zip(names, bodies)
        tuples = section_infos(body)
        for section in tuples
            number, id, text = section
            link = "$name.html#$id"
            link_text = "<b>$number</b> $text"
            item = html_href(link_text, link)
            push!(menu_items, item)
        end
    end
    list = join(html_li.(menu_items), '\n')
    menu = """
    <aside class="books-menu">
    <div class="books-title">
    $title
    </div>
    $list
    </aside>
    """

    (head = head, menu = menu, bodies = bodies, foot = foot)
end

function html_pages(chs=chapters, h=pandoc_html())
    head, menu, bodies, foot = add_menu(chs, split_html(h))
    create_page(body) = """
    $head 
    <div class="books-outside">
    $menu 
    <div class="books-content"> 
    $body $foot
    </div>
    </div>
    """
    pages = create_page.(bodies)
    names = html_page_names(chs)
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
