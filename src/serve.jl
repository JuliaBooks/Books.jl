export
    serve

import LiveServer

ignored_folders = [
    "build",
    ".git",
    ".github"
]

function ignore(path)::Bool 
    path_startswith(folder) = startswith(path, "./$folder") || startswith(path, folder)
    any(path_startswith.(ignored_folders))
end

function custom_callback(file::AbstractString) 
    if !ignore(file)
        println("Running `html()`")
        html()
    end
    LiveServer.file_changed_callback(file)
end

function default_simplewatcher()
    sw = LiveServer.SimpleWatcher(custom_callback)

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

function serve(simplewatcher=default_simplewatcher(); verbose=true, port=8001, dir=build_dir)
    if !isdir(dir)
        mkpath(dir)
    end
    html()
    LiveServer.serve(simplewatcher; verbose, port, dir)
end
