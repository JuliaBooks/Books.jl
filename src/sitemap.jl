@inline ids_texts2links(id_texts) = 

"""
    sitemap(h)

Write a sitemap to "sitemap.xml" for html `h`.
"""
function sitemap(h)
    head, bodies, foot = split_html(h)
    ids_texts = html_page_name.(bodies)

    links = getproperty.(ids_texts, :id)
    path = joinpath(BUILD_DIR, "sitemap.xml")
    text = "1"
    write(path, text)
    return text
end

