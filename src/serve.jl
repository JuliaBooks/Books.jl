export
    serve

import LiveServer

ignored_folder = "build"

ignore(path)::Bool = startswith(path, ignored_folder) || startswith(path, "./$ignored_folder")

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
            if !ignore(file)
                file_path = joinpath(root, file)
                println("Watching $file_path")
                LiveServer.watch_file!(sw, file_path)
            end
        end
    end
    sw
end

function serve(simplewatcher=default_simplewatcher(); verbose=true, port=8001, dir="build/html")
    if !isdir(dir)
        mkpath(dir)
    end
    html()
    LiveServer.serve(simplewatcher; verbose, port, dir)
end
