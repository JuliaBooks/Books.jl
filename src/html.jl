import YAML

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
    fix_png_image(h::AbstractString, url_prefix)

Fix a single html image string.

```jldoctest
julia> h = "\\"$(Books.BUILD_DIR)/im/image.png";

julia> url_prefix = "Foo.jl";

julia> Books.fix_png_image(h, url_prefix)
"\\"Foo.jl/im/image.png"
```
"""
function fix_png_image(h::AbstractString, url_prefix)
    path_prefix = "\"$(BUILD_DIR)/"
    h = replace(h, path_prefix => "\"$(url_prefix)/")
    h = replace(h, ".png\"" => ".svg\"")
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
            text = line_end[nextind(line_end, 0, 2):prevind(line_end, end, 4)]
            tuple = (num = number, id = id, text = lstrip(text))
            push!(tuples, tuple)
        end
        m = match(unnumbered_rx, line)
        if !isnothing(m)
            id = m.captures[1]
            interesting_region = split(line, '>')[end-1]
            text = interesting_region[nextind(interesting_region, 0, 1):prevind(interesting_region, end, 4)]
            tuple = (num = "", id = id, text = lstrip(text))
            push!(tuples, tuple)
        end
    end
    tuples
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
        start = findfirst(':', id) + 1
        id = id[start:end]
    end
    (id=id, text=first(sections).text)
end

html_href(text, link, level) = """<a class="menu-level-$level" href="$link">$text</a>"""
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

"""
    add_menu([splitted])

Menu including numbered sections.
"""
function add_menu(splitted=split_html())
    head, bodies, foot = splitted
    data = pandoc_metadata()
    title = data["title"]
    subtitle = "subtitle" in keys(data) ? data["subtitle"] : ""

    ids_texts = html_page_name.(bodies)
    names = getproperty.(ids_texts, :id)
    menu_items = []
    skip_homepage(z) = Iterators.peel(z)[2]
    for (name, body) in skip_homepage(zip(names, bodies))
        tuples = section_infos(body)
        for section in tuples
            num, id, text = section
            link = "$name.html"
            link_text = "<b>$num</b> $text"
            level = section_level(num)
            if level < 3
                item = html_href(link_text, link, level)
                push!(menu_items, item)
            end
        end
    end
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
    <div class="books-outside">
    $menu
    <div class="books-content">
    $body $foot
    </div>
    </div>
    """
end

function html_pages(chs=chapters(), h=pandoc_html())
    head, menu, bodies, foot = add_menu(split_html(h))
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
            capture = first(m.captures)
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
            capture = first(match(rx, s).captures)
            if startswith(capture, "#sec:")
                page_link = mapping[capture]
                return uncapture("$url_prefix/$page_link.html$capture")
            elseif startswith(capture, "#ref-")
                page_link = "references"
                return uncapture("$url_prefix/$page_link.html$capture")
            else
                capture = lstrip(capture, '/')
                return uncapture("$url_prefix/$capture")
            end
        end
        fixed = replace(page, rx => replace_match)
        return fixed
    end

    fixed_pages = [fix_page(name, page) for (name, page) in zip(names, pages)]
    (names, fixed_pages)
end

function write_html_pages(url_prefix, chs=chapters(), h=pandoc_html())
    h = fix_image_urls(h, url_prefix)
    names, pages = fix_links(html_pages(chs, h)..., url_prefix)
    for (i, (name, page)) in enumerate(zip(names, pages))
        name = i == 1 ? "index" : name
        path = joinpath(BUILD_DIR, "$name.html")
        write(path, page)
    end
end
