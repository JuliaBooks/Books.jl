"""
    split_keepdelim(str::AbstractString, dlm::Regex)

Split on regex while keeping the matches.
Based on https://github.com/JuliaLang/julia/issues/20625#issuecomment-581585151.
"""
function split_keepdelim(str::AbstractString, dlm::Regex)
    dlm = string(dlm)[3:end-1]
    rx = Regex("(?=$dlm)")
    split(str, rx)
end

"""
    split_html(h::AbstractString=pandoc_html())

Split `html` into chapters.
We need this function because Pandoc needs all the files at the same time to allow for cross-references.
"""
function split_html(h::AbstractString=pandoc_html())
    head_pattern = "<!-- end head -->"
    head, after_head = split(h, head_pattern)
    foot_pattern = "<!-- begin foot -->"
    body, foot = split(after_head, foot_pattern)

    start = r"<h[1|2]"
    bodies = split_keepdelim(body, start)[2:end]
    (head = head, bodies = bodies, foot = foot)
end

function section_infos(text)
    lines = split(text, '\n')
    numbered_rx = r"data-number=\"([^\"]*)\" id=\"([^\"([^\"]*)\""
    unnumbered_rx = r"class=\"unnumbered\" id=\"([^\"([^\"]*)\""
    tuples = []
    for line in lines
        m = match(numbered_rx, line)
        if !isnothing(m)
            number, id = m.captures 
            line_end = split(line, '>')[end-1]
            text = line_end[2:end-4]
            tuple = (num = number, id = id, text = lstrip(text))
            push!(tuples, tuple)
        end
        m = match(unnumbered_rx, line)
        if !isnothing(m)
            id = m.captures[1]
            interesting_region = split(line, '>')[end-1]
            text = interesting_region[1:end-4]
            tuple = (num = "", id = id, text = lstrip(text))
            push!(tuples, tuple)
        end
    end
    tuples
end

function html_page_name(html)
    sections = section_infos(html)
    id = first(sections).id
    if contains(id, ':')
        start = findfirst(':', id) + 1
        id = id[start:end]
    end
    id
end

"""
    html_page_names(bodies)

Give the page names for the html bodies.
"""
function html_page_names(bodies) 
    names = html_page_name.(bodies)
    ["index"; names]
end

html_href(text, link) = """<a href="$link">$text</a>"""
html_li(text) = """<li>$text</li>"""

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
    add_menu([splitted])

Menu including numbered sections.
"""
function add_menu(splitted=split_html())
    head, bodies, foot = splitted
    title = pandoc_title()
    
    names = html_page_names(bodies)
    menu_items = []
    skip_homepage(z) = Iterators.peel(z)[2]
    for (name, body) in skip_homepage(zip(names, bodies))
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
    <input type="checkbox" id="menu">
    <label for="menu">☰</label>
    <div class="books-title">
    <a href="/">$title</a>
    </div>
    <div class="books-menu-content">
    $list
    </div>
    </aside>
    """

    (head = head, menu = menu, bodies = bodies, foot = foot)
end

function html_pages(chs=chapters(), h=pandoc_html())
    head, menu, bodies, foot = add_menu(split_html(h))
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
    names = html_page_names(bodies)
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

function write_html_pages(chs=chapters(), h=pandoc_html())
    pages = fix_links(html_pages(chs, h))
    mkpath(build_dir) # For some reason, this is necessary in CI.
    for name in keys(pages)
        path = joinpath(build_dir, "$name.html")
        write(path, pages[name])
    end
end
