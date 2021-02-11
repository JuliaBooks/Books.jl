is_github_ci() = "CI" in keys(ENV)
"""
    is_sudo_env()

Check whether we need sudo.
This differs between GitHub and GitLab CI.
"""
function is_sudo_env()
    try 
        run(`sudo echo foo`)
        return true
    catch
        return false
    end
end
sudo_prefix() = is_sudo_env() ? "sudo" : ""

function install_via_tar()
    @assert is_github_ci()
    sudo = sudo_prefix()
    PANDOC_VERSION = "2.10.1"
    CROSSREF_VERSION = "0.3.8.1"

    filename = "pandoc-$PANDOC_VERSION-1-amd64.deb"
    download("https://github.com/jgm/pandoc/releases/download/$PANDOC_VERSION/$filename", filename)
    args = [sudo, "dpkg", "-i", filename]
    run(`$args`)

    filename = "pandoc-crossref-Linux.tar.xz"
    download("https://github.com/lierdakil/pandoc-crossref/releases/download/v$CROSSREF_VERSION/$filename", filename)
    run(`tar -xf $filename`)
    bin_dir = joinpath(homedir(), "bin")
    mkdir(bin_dir)
    name = "pandoc-crossref"
    mv(name, joinpath(bin_dir, name))
    open(ENV["GITHUB_PATH"], "a") do io
        write(io, bin_dir)
    end
end

function install_apt_packages()
    @assert is_github_ci()
    packages = [
        "make", 
        "pdf2svg", 
        "texlive-fonts-recommended", 
        "texlive-fonts-extra",
        "texlive-latex-base",
        "texlive-binaries",
        "texlive-xetex"
    ]

    sudo = sudo_prefix()
    args = [sudo, "apt-get", "-qq", "update"]
    run(`$args`)
    for package in packages
        println("Installing $package via apt")
        args = [sudo, "apt-get", "install", "-y", package]
        run(`$args`)
    end
end

function install_dependencies()
    install_via_tar()
    install_apt_packages()
end
