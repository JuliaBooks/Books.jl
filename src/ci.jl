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
    dir = joinpath(Artifacts.artifact"juliamono", "juliamono-0.039")
    target_dir = "fonts"
    mkpath(target_dir)
    # println("Copying Julia Mono fonts into $target_dir")
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
    run(`fc-cache --verbose $fonts_dir`)
end

function install_apt_packages()
    @assert is_ci()
    println("Installing apt packages")

    packages = [
        "python3-pip"
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
    args = [sudo, "pip3", "install", "cairosvg"]
    nonempty_run(args)
    validate_installation("cairosvg")
end

function install_dependencies()
    install_apt_packages()
    install_non_apt_packages()
    install_extra_fonts()
end
