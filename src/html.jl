import YAML
import URIs

"""
    split_keepdelim(str::AbstractString, delim::Regex)

Split on regex while keeping the matches.
Based on https://github.com/JuliaLang/julia/issues/20625#issuecomment-581585151.
"""
function split_keepdelim(str::AbstractString, delim::Regex)
    delim = string(delim)[3:end-1]
    rx = Regex("(?=$delim)")
    split(str, rx)
end

"""
    fix_png_image(h::AbstractString, url_prefix)

Fix a single html image string.

```jldoctest
julia> h = "img src=\\"_build/im/imaginary.png\\" ";

julia> url_prefix = "Foo.jl";

julia> Books.fix_png_image(h, url_prefix) # Only replaces if file exists.
"img src=\\"Foo.jl/im/imaginary.png\\" "
```
"""
function fix_png_image(h::AbstractString, url_prefix)
    path_prefix = "\"$(BUILD_DIR)/"
    png_filename = h[20:end-2]
    h = replace(h, path_prefix => "\"$(url_prefix)/")
    svg_filename = png_filename[1:end-4] * ".svg"
    svg_path = joinpath(Books.BUILD_DIR, "im", svg_filename)
    if isfile(svg_path)
        h = replace(h, ".png\"" => ".svg\"")
    end
    return h
end

"""
    fix_image_urls(h::AbstractString, url_prefix)

Change all the PNG images to SVG.
This is neccessary, because LaTeX doesn't accept SVG images.
Also, add the `url_prefix`.
"""
function fix_image_urls(h::AbstractString, url_prefix)
    html_image_src = r"""img src="_build\/im\/[^\.]*\.png" """
    fix_png_image_partial(h::AbstractString) = fix_png_image(h, url_prefix)
    replace(h, html_image_src => fix_png_image_partial)
end

"""
    split_html(h::AbstractString)

Split `h` into chapters.

We need this function because Pandoc needs all the files at the same time to allow for cross-references.

# Example
```
julia> h = Books.pandoc_html("default");

julia> head, bodies, foot = Books.split_html(h);
```
"""
function split_html(h::AbstractString)
    head_pattern = "<!-- end head -->"
    head, after_head = split(h, head_pattern)
    foot_pattern = "<!-- begin foot -->"
    body, foot = split(after_head, foot_pattern)

    start = r"<h[1|2]"
    bodies = split_keepdelim(body, start)[2:end]
    bodies::Vector{String} = string.(bodies)
    (head = head, bodies = bodies, foot = foot)
end

struct SectionInfo
    num::String
    id::String
    text::String
end

function section_infos(text)
    lines = split(text, '\n')
    numbered_rx = r"data-number=\"([^\"]*)\" id=\"([^\"([^\"]*)\""
    unnumbered_rx = r"class=\"unnumbered\" id=\"([^\"([^\"]*)\""
    V = Vector{SectionInfo}()
    for line in lines
        m = match(numbered_rx, line)
        if !isnothing(m)
            number, id = m.captures
            line_end = split(line, '>')[end-1]
            text = line_end[nextind(line_end, 0, 2):prevind(line_end, end, 4)]
            info = SectionInfo(number, id, lstrip(text))
            push!(V, info)
        end
        m = match(unnumbered_rx, line)
        if !isnothing(m)
            id = m.captures[1]
            interesting_region = split(line, '>')[end-1]
            text = interesting_region[nextind(interesting_region, 0, 1):prevind(interesting_region, end, 4)]
            info = SectionInfo("", id, lstrip(text))
            push!(V, info)
        end
    end
    V
end

"""
    html_page_name(html)

Return page name for a html body.
For example, returns "about" or "getting-started".
"""
function html_page_name(html)
    sections = section_infos(html)
    id = first(sections).id
    if contains(id, ':')
        start = findfirst(':', id)::Int + 1
        id = id[start:end]
    end
    id = string(id)::String
    text = first(sections).text
    text = string(text)::String
    (; id, text)
end

function html_href(text, link, level)
    threshold = 33
    if threshold < length(text)
        shortened = text[1:threshold]::String
        text = shortened * ".."
    end
    """<a class="menu-level-$level" href="$link">$text</a>"""
end
html_li(text) = """<li>$text</li>"""

function pandoc_metadata(file=joinpath(GENERATED_DIR, "metadata.yml"))::Dict
    data = YAML.load_file(file)
end

function section_level(num::AbstractString)
    rx = r"\."
    matches = eachmatch(rx, num)
    n_dots = length(collect(matches))
    n_dots + 1
end

function previous_and_next_buttons(body::String, menu_items::Vector{String}, i::Int)
    max = length(menu_items)
    prev = 2 < i ? menu_items[i - 2] : ""
    prev = strip(prev)
    text_prev = prev == "" ? "" : "<kbd>←</kbd>"
    next = i < max ? menu_items[i] : ""
    next = strip(next)
    text_next = next == "" ? "" : "<kbd>→</kbd>"
    # Note that changing the element below might require a mousetrap Javascript in template.html update.
    """
    $body

    <div class="bottom-nav">
        <p id="nav-prev" style="text-align: left;">
            $prev $text_prev
            <span id="nav-next" style="float: right;">
                $text_next $next
            </span>
        </p>
    </div>
    """
end

"""
    add_previous_and_next_buttons(bodies::Vector{String}, menu_items::Vector{String})

Add buttons at bottom of page to navigate to the previous or next section.
"""
function add_previous_and_next_buttons(bodies::Vector{String}, menu_items::Vector{String})
    for (i, body) in enumerate(bodies)
        bodies[i] = previous_and_next_buttons(body, menu_items, i)
    end
    bodies
end

"""
    add_menu(head, bodies, foot)

Menu including numbered sections.
"""
function add_menu(head, bodies, foot)
    data = pandoc_metadata()::Dict{Any, Any}
    title = data["title"]::String
    subtitle = "subtitle" in keys(data) ? data["subtitle"]::String : ""

    ids_texts = html_page_name.(bodies)
    ids = ids_texts2links(ids_texts)
    menu_items::Vector{String} = []
    skip_homepage(z) = Iterators.peel(z)[2]
    for (id, body) in skip_homepage(zip(ids, bodies))
        V = section_infos(body)
        for info in V
            num = info.num
            text = info.text
            link = "/$id$(HTML_SUFFIX)"
            link_text = "<b>$num</b> $text"
            level = section_level(num)
            if level < 3
                item = html_href(link_text, link, level)
                item = string(item)::String
                push!(menu_items, item)
            end
        end
    end
    bodies = add_previous_and_next_buttons(bodies, menu_items)
    list = join(html_li.(menu_items), '\n')
    menu = """
    <aside class="books-menu">
    <input type="checkbox" id="menu">
    <label for="menu">☰</label>
    <div class="books-title">
    <a href="/">$title</a>
    </div><br />
    <span class="books-subtitle">
    $subtitle
    </span>
    <div class="books-menu-content">
    $list
    </div>
    </aside>
    """

    (head = head, menu = menu, bodies = bodies, foot = foot)
end

"""
    update_title(head, name)

Return an updated `head` where the title is based on the page `name`.

```jldoctest
julia> head = "<!DOCTYPE html><title>Book - Books.jl</title>\n";

julia> name = "About";

julia> Books.update_title(head, name)
"<!DOCTYPE html><title>About - Books.jl</title>\n"
"""
function update_title(head, name)
    rx = r"<title>[^<]*<\/title>"
    function replace_name(match)
        before_minus, after_minus = split(match, " - ")
        "<title>$name - $after_minus"
    end
    replace(head, rx => replace_name)
end

function create_page(head, menu, name, body, foot)
    head = update_title(head, name)
    page = """
    $head
    <div class="books-container">
    $menu
    <div class="books-content">
    $body
    $foot
    """
    page = rstrip(page)
end

function add_extra_head(head, extra_head::AbstractString)
    before = "\n</head>"
    # All entries in the head have two spaces in front.
    after = "\n  $extra_head $before"
    replace(head, before => after)
end

function extract_footnotes(last_body)
    lines = split(last_body, '\n')
    footnotes_start = """<section class="footnotes" role="doc-endnotes">"""
    start_index = findfirst(contains(footnotes_start), lines)
    if isnothing(start_index) # Project doesn't contain footnotes.
        return (last_body, [])
    end
    footnotes_end = "</section>"
    stop_index = findfirst(contains(footnotes_end), lines[start_index:end]) + start_index
    footnotes = lines[start_index:stop_index]
    without_footnotes = [lines[1:start_index-1]; lines[stop_index+1:end]]
    last_body = join(without_footnotes, '\n')
    return (last_body, footnotes)
end

function locate_footnotes(bodies)::Dict{String,Int}
    id_locations = Dict{String,Int}()
    rx = r"<a href=\"#(fn[0-9]*)\" class=\"footnote-ref\""
    for (body_index, body) in enumerate(bodies)
        M = eachmatch(rx, body)
        for m in M
            id = string(m[1])::String
            id_locations[id] = body_index
        end
    end
    return id_locations
end

function redistribute_footnotes!(bodies, footnotes)
    filter!(contains("footnote-back"), footnotes)
    id_locations = locate_footnotes(bodies)
    rx = r"id=\"(fn[0-9]*)\""

    # Group footnotes per body (webpage).
    body_footnotes = Dict{Int,Vector{AbstractString}}()
    for footnote in footnotes
        m = match(rx, footnote)
        id = string(m[1])::String
        num = id[3:end]
        # Lists start counting at 1 whereas the footnotes should stick to the id.
        footnote_text_start = "endnote\"><p>"
        footnote = replace(footnote, footnote_text_start => "$(footnote_text_start) $(num). ")
        body_index = id_locations[id]
        if body_index in keys(body_footnotes)
            push!(body_footnotes[body_index], footnote)
        else
            body_footnotes[body_index] = [footnote]
        end
    end

    # Add a footnote section per body (webpage).
    bodies_with_footnotes = keys(body_footnotes)
    for body_index in bodies_with_footnotes
        footnotes = join(body_footnotes[body_index], '\n')
        text = """
            <section class="footnotes" role="doc-endnotes">
            <hr />
            <ol>
            $footnotes
            </ol>
            </section>
            """
        bodies[body_index] = bodies[body_index] * text
    end
    return bodies
end

"""
    fix_footnotes(bodies)

Return bodies where references are in the correct body instead of in the last one.
By default, Pandoc will place the endnotes for footnotes at the end.
Usually, this would mean behind the references.
"""
function fix_footnotes(bodies)
    last_body = bodies[end]
    without_footnotes, footnotes = extract_footnotes(last_body)
    bodies[end] = without_footnotes
    bodies = redistribute_footnotes!(bodies, footnotes)
    return bodies
end

function html_pages(h, extra_head="")
    head, bodies, foot = split_html(h)
    head, menu, bodies, foot = add_menu(head, bodies, foot)
    head = add_extra_head(head, extra_head)
    bodies = fix_footnotes(bodies)
    ids_texts = html_page_name.(bodies)
    id_names = getproperty.(ids_texts, :id)
    text_names = getproperty.(ids_texts, :text)
    pages = create_page.(head, menu, text_names, bodies, foot)
    (names = id_names, pages = pages)
end

"""
    map_ids(names, pages)

Returns a mapping from `id` to `page_name`.
This is used to allow one page to link to elements on another page.
"""
function map_ids(names, pages)
    mapping = Dict()
    rx = r"id=\"([^\"]*)\""
    for (name, page) in zip(names, pages)
        html = page
        matches = eachmatch(rx, html)
        for m in matches
            capture = first(m.captures)::SubString{String}
            if startswith(capture, "sec:")
                key = '#' * capture
                mapping[key] = name
            end
        end
    end
    mapping
end

"""
    fix_links(names, pages, url_prefix)

Update links by adding `url_prefix` and pointing to the correct page.
"""
function fix_links(names, pages, url_prefix)
    mapping = map_ids(names, pages)
    rx = r"href=\"([^\"]*)\""
    uncapture(capture) = "href=\"$capture\""
    updated_pages = []
    function fix_page(name, page)
        function replace_match(s)
            capture = first(match(rx, s).captures)::SubString{String}
            if startswith(capture, "#sec:")
                page_link = mapping[capture]
                return uncapture("$url_prefix/$page_link$(HTML_SUFFIX)$capture")
            elseif startswith(capture, "#ref-")
                page_link = "references"
                return uncapture("$url_prefix/$page_link$(HTML_SUFFIX)$capture")
            elseif URIs.URI(URIs.unescapeuri(capture)).scheme == ""
                return uncapture("$url_prefix$capture")
            else
                return uncapture(capture)
            end
        end
        fixed = replace(page, rx => replace_match)
        return fixed
    end

    fixed_pages = [fix_page(name, page) for (name, page) in zip(names, pages)]
    (names, fixed_pages)
end

function write_html_pages(url_prefix, h::AbstractString, extra_head="")
    h = fix_image_urls(h, url_prefix)
    names, pages = html_pages(h, extra_head)
    names, pages = fix_links(names, pages, url_prefix)
    for (i, (name, page)) in enumerate(zip(names, pages))
        name = i == 1 ? "index" : name
        path = joinpath(BUILD_DIR, "$(name).html")
        write(path, page)
    end
end
