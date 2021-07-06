@memoize function default_metadata()::Dict
    path = joinpath(DEFAULTS_DIR, "metadata.yml")
    data = YAML.load_file(path)
end

"""
    override(d1::Dict, d2::Dict)

Merge `d1` and `d2` by overriding values existing in `d1` by values from `d2`.

# Example
```jldoctest
julia> d1 = Dict(:A => 1, :B => 2);

julia> d2 = Dict(:A => 3, :C => 4);

julia> Books.override(d1, d2)
Dict{Symbol, Int64} with 3 entries:
  :A => 3
  :B => 2
  :C => 4
```
"""
override(d1::Dict, d2::Dict) = Dict(d1..., d2...)

"""
    write_metadata(user_metadata_path)

Write `metadata.yml` for Pandoc to $(Books.GENERATED_DIR).
The file is a combination of Books.jl default settings and the user-defined settings.
"""
function write_metadata(user_metadata_path)
    user_metadata = isfile(user_metadata_path) ? YAML.load_file(user_metadata_path) : error("Couldn't find metadata.yml")
    default = default_metadata()
    combined = override(default, user_metadata)
    mkpath(GENERATED_DIR)
    path = joinpath(GENERATED_DIR, "metadata.yml")
    YAML.write_file(path, combined)
    path
end

"""
    project_info(path::String, project::AbstractString)

Return project info for TOML file at `path` as raw text or `nothing` if `project` is not defined.
"""
function project_info(path::String, project::AbstractString)
    text = read(path, String)
    dic = TOML.parse(text)::Dict{String, Any}
    projects = dic["projects"]::Dict{String, Any}
    if project in keys(projects)
        project = string(project)::String
        projects[project]::Dict{String, Any}
    else
        nothing
    end
end

@memoize function default_config(project::AbstractString)
    path = joinpath(DEFAULTS_DIR, "config.toml")
    project_info(path, project)
end

function user_config(project::AbstractString)
    path = "config.toml"
    isfile(path) ? project_info(path, project) : nothing
end

"""
    config(project::AbstractString)

Read user `config.toml` and `$DEFAULTS_DIR/config.toml` and combine the information.

# Example
```jldoctest
julia> cd(joinpath(pkgdir(Books), "docs"))

julia> c = Books.config("default");

julia> c["port"]
8012
```
"""
function config(project::AbstractString)
    default = default_config(project)
    user = user_config(project)
    combined =
        isnothing(user) && isnothing(default) ? error("Project $project not defined in config.toml") :
        isnothing(user) ? default :
        isnothing(default) ? user :
        override(default, user)::Dict{String, Any}
end

"""
    config(project::AbstractString, key::String)

Extension of `config(project::AbstractString)` which returns an output from the default
project if `key` cannot be found for `project`.

# Example
```jldoctest
julia> cd(joinpath(pkgdir(Books), "docs"))

julia> Books.config("default", "port")
8012

julia> Books.config("notes", "port")
8012
```
"""
function config(project::AbstractString, key::String)
    c = config(project)::Dict{String, Any}
    if key in keys(c)
        return c[key]
    else
        default = config("default")::Dict{String, Any}
        return config("default")[key]
    end
end
