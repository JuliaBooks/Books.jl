is_ci() = "CI" in keys(ENV)
const IS_CI = is_ci()

"""
    html_suffix()

Return "" when not in CI since GitHub Pages redirects to the HTML file anyway.
"""
html_suffix() = IS_CI ? "" : ".html"
const HTML_SUFFIX = html_suffix()

"""
    is_sudo_env()

Check whether we need sudo.
This differs between GitHub and GitLab CI.
"""
function is_sudo_env()
    try
        run(`sudo echo This text is printed with sudo privileges`)
        return true
    catch
        return false
    end
end
sudo_prefix() = is_sudo_env() ? "sudo" : ""
function nonempty_run(args::Vector)
    filter!(!=(""), args)
    run(`$args`)
end

"""
    install_extra_fonts()

For some reason, this is required since I couldn't get Tectonic to work with `fontconfig` and `Path`.
Installing fonts globally is the most reliable workaround that I can find.
The benefit is that it's easy to verify the installation via `fc-list | grep "Julia"`.
"""
function install_extra_fonts()
    name = "juliamono-$JULIAMONO_VERSION"
    dir = joinpath(Artifacts.artifact"JuliaMono", name)
    # See `fc-cache --force --verbose` for folders that `fc-cache` inspects.
    # Don't try to pass a dir to `fc-cache`, this is ignored on my pc for some reason.
    target_dir = joinpath(homedir(), ".local", "share", "fonts")
    mkpath(target_dir)
    for file in readdir(dir)
        cp(joinpath(dir, file), joinpath(target_dir, file); force=true)
    end
    return

    files = readdir(ttf_dir)
    mkpath(fonts_dir)
    println("Moving files to $fonts_dir")
    for file in files
        from = joinpath(ttf_dir, file)
        to = joinpath(fonts_dir, file)
        mv(from, to; force=true)
    end

    # Update fontconfig cache; not sure if it is necessary.
    run(`fc-cache --force --verbose $fonts_dir`)
end

function install_dependencies()
    install_extra_fonts()
end

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

"""
    patch_tectonic_url()

Workaround for https://github.com/tectonic-typesetting/tectonic/issues/765.
"""
function patch_tectonic_url()
    old_url = "https://archive.org/services/purl/net/pkgwpub/tectonic-default"
    # The new URL has to be shorter than the old URL for patching to work.
    new_url = "https://juliabooks.github.io/TectonicRedirect/"
    tectonic() do bin
        run(`chmod 775 $bin`)
        run(`sed -i 's@$(old_url)@$(new_url)@' $bin`)
    end
    return nothing
end
