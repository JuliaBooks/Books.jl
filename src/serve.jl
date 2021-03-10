ignored_folders = [
    "build",
    ".git",
    ".github"
]

function ignore(path)::Bool
    path_startswith(folder) = startswith(path, "./$folder") || startswith(path, folder)
    any(path_startswith.(ignored_folders)) || endswith(path, "metadata.yml")
end

"""
    rebuild_neccesary(file)::Bool

Avoid rebuilds if possible.
For example, calling Pandoc is not neccesary for svg images.
"""
function rebuild_neccesary(file::AbstractString)::Bool
    _, extension = splitext(file)
    extension != ".svg"
end

function custom_callback(file::AbstractString, project::AbstractString)
    if !ignore(file)
        if rebuild_neccesary(file)
            println("Running `html()`")
            html(; project)
        end
    end
    LiveServer.file_changed_callback(file)
end

custom_callback_partial(project::AbstractString) = file -> custom_callback(file, project)

function default_simplewatcher(project)
    f = custom_callback_partial(project)
    sw = LiveServer.SimpleWatcher(f)

    for (root, dirs, files) in walkdir(".")
        for file in files
            file_path = joinpath(root, file)
            if !ignore(file_path)
                println("Watching $file_path")
                LiveServer.watch_file!(sw, file_path)
            end
        end
    end
    sw
end

function serve(; simplewatcher=nothing,
        project="default", verbose=true, dir=BUILD_DIR)

    if isnothing(simplewatcher)
        simplewatcher = default_simplewatcher(project)
    end
    if !isdir(dir)
        mkpath(dir)
    end
    html(; project)
    port = config(project)["port"]
    LiveServer.serve(simplewatcher; verbose, port, dir)
end
