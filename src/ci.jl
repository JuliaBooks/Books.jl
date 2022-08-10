is_ci() = "CI" in keys(ENV)

"""
    html_suffix()

Return "" when not in CI since GitHub Pages redirects `foo` to `foo.html` anyway.
"""
html_suffix() = is_ci() ? "" : ".html"
const HTML_SUFFIX = html_suffix()

"""
    write_extra_html_files(project)

Write "robots.txt" and "404.html".
"""
function write_extra_html_files(project)
    metadata_path = combined_metadata_path(project)
    metadata = YAML.load_file(metadata_path)
    title = metadata["title"]
    missing_text = """
        <!DOCTYPE html>
        <html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US">
        <head>
            <title>Page not found - $title</title>
        </head>
        <body>
            <div style="margin-top: 40px; font-size: 40px; text-align: center;">
                <br>
                <br>
                <br>
                <div style="font-weight: bold;">
                    404
                </div>
                <br>
                <div>
                    Page not found
                </div>
                <br>
                <br>
                <div style="margin-bottom: 300px; font-size: 24px">
                    <a href="/">Click here</a> to go back to the $title homepage.
                </div>
            </div>
        </body>
        """
    path = joinpath(BUILD_DIR, "404.html")
    write(path, missing_text)

    loc = html_loc(project, "sitemap"; suffix=".xml")
    robots = """
        Sitemap: $loc

        User-agent: *
        Disallow:
        """
    path = joinpath(BUILD_DIR, "robots.txt")
    write(path, robots)
    return nothing
end
