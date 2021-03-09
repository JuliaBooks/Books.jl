is_ci() = "CI" in keys(ENV)

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

Required for Source Code Pro.
Thanks to https://github.com/AnomalyInnovations/serverless-stack-com.
"""
function install_extra_fonts()
    println("Installing extra fonts")

    font_repo_dir = joinpath(homedir(), "source-code-pro")
    rm(font_repo_dir; recursive=true, force=true)
    run(`git clone --branch=release --depth=1 https://github.com/adobe-fonts/source-code-pro $font_repo_dir`)
    ttf_dir = joinpath(font_repo_dir, "TTF")
    fonts_dir = "/usr/share/fonts"

    files = readdir(ttf_dir)
    println("Moving files to $fonts_dir")
    for file in files
        from = joinpath(ttf_dir, file)
        to = joinpath(fonts_dir, file)
        mv(from, to; force=true)
        chmod(to, 666)
    end
end

function install_apt_packages()
    @assert is_ci()
    println("Installing apt packages")

    packages = [
        "librsvg2-bin", # rsvg-convert
        "make",
        "pdf2svg",
        "python3-pip",
        "texlive-fonts-recommended", 
        "texlive-fonts-extra",
        "texlive-latex-base",
        "texlive-binaries",
        "texlive-xetex",
        "xz-utils" # Required by tar.
    ]

    sudo = sudo_prefix()
    args = [sudo, "apt-get", "-qq", "update"]
    nonempty_run(args)
    for package in packages
        println("Installing $package via apt")
        args = [sudo, "apt-get", "install", "-y", package]
        nonempty_run(args)
    end
end

function validate_installation(name::AbstractString; args="--version")
    try
        run(`$name $args`)
    catch e
        error("Could not run $name with args $args")
    end
end

function install_non_apt_packages()
    @assert is_ci()
    println("Installing non-apt packages")

    sudo = sudo_prefix()
    PANDOC_VERSION = "2.10.1"
    CROSSREF_VERSION = "0.3.8.1"

    filename = "pandoc-$PANDOC_VERSION-1-amd64.deb"
    download("https://github.com/jgm/pandoc/releases/download/$PANDOC_VERSION/$filename", filename)
    args = [sudo, "dpkg", "-i", filename]
    nonempty_run(args)
    validate_installation("pandoc")

    filename = "pandoc-crossref-Linux.tar.xz"
    download("https://github.com/lierdakil/pandoc-crossref/releases/download/v$CROSSREF_VERSION/$filename", filename)
    run(`tar -xf $filename`)
    name = "pandoc-crossref"
    target = joinpath(pwd(), "$name")
    source = "/usr/local/bin/$name"
    try
        run(`ln -s $target $source`)
    catch
        bin_dir = joinpath(homedir(), "bin")
        mkdir(bin_dir)
        mv(name, joinpath(bin_dir, name))
        open(ENV["GITHUB_PATH"], "a") do io
            write(io, bin_dir)
        end
    end
    # validate_installation("pandoc-crossref")

    args = [sudo, "pip3", "install", "cairosvg"]
    nonempty_run(args)
    validate_installation("cairosvg")
end

function install_dependencies()
    install_apt_packages()
    install_non_apt_packages()
    install_extra_fonts()
end
