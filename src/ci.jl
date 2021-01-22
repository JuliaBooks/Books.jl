is_github_ci() = "CI" in keys(ENV)

function install_via_tar()
    @assert is_github_ci()
    PANDOC_VERSION = "2.10.1"
    CROSSREF_VERSION = "0.3.8.1"

    download("https://github.com/jgm/pandoc/releases/download/$PANDOC_VERSION/pandoc-$PANDOC_VERSION-1-amd64.deb")
    run(`sudo dpkg -i pandoc-$PANDOC_VERSION-1-amd64.deb`)

    download("https://github.com/lierdakil/pandoc-crossref/releases/download/v$CROSSREF_VERSION/pandoc-crossref-Linux.tar.xz")
    run(`tar -xf pandoc-crossref-Linux.tar.xz`)
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

    run(`sudo apt-get -qq update`)
    for package in packages
        run(`sudo apt-get install -y $package`)
    end
end

function install_dependencies()
    install_via_tar()
    install_apt_packages()
end
