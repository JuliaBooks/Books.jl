ignored_folders = [
    BUILD_DIR,
    # This would trigger too often when calling `gen(; M)` on a large project.
    GENERATED_DIR,
    ".git",
    ".github",
]

function ignore(path)::Bool
    path_startswith(folder) = startswith(path, joinpath(".", folder)) || startswith(path, folder)
    any(path_startswith.(ignored_folders)) || endswith(path, "metadata.yml")
end

"""
    rebuild_neccesary(file)::Bool

Avoid rebuilds if possible.
For example, calling Pandoc is not neccesary for svg images.
"""
function rebuild_neccesary(file::AbstractString)::Bool
    _, extension = splitext(file)
    lowercase(extension) != ".svg"
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

function custom_simplewatcher(project, extra_directories)
    # The callback, defined by LiveServer.jl, receives a file.
    cb(file) = custom_callback(file, project)
    sw = LiveServer.SimpleWatcher(cb)

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

function serve(; simplewatcher=nothing, host::String="127.0.0.1",
        project="default", verbose=true, dir=BUILD_DIR)

    if isnothing(simplewatcher)
        extra_directories = config(project, "extra_directories")
        simplewatcher = custom_simplewatcher(project, extra_directories)
    end
    mkpath(dir)
    html(; project)
    port = config(project, "port")::Int
    LiveServer.serve(simplewatcher; verbose, host, port, dir)
end
