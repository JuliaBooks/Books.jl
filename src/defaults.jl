default_metadata = Dict{String,Any}[]

function _default_metadata()
    if isempty(default_metadata::Vector)
        path = joinpath(DEFAULTS_DIR, "metadata.yml")
        data = YAML.load_file(path)
        push!(default_metadata, data)
    end
    return only(default_metadata)
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
    combine_metadata(user_metadata_path="metadata.yml")

Write `metadata.yml` for Pandoc to $(Books.GENERATED_DIR).
The file is a combination of Books.jl default settings and the user-defined settings.
"""
function combine_metadata(user_metadata_path="metadata.yml")
    user_metadata = isfile(user_metadata_path) ?
        YAML.load_file(user_metadata_path) :
        error("Couldn't find metadata.yml")
    default = _default_metadata()
    combined = override(default, user_metadata)
    mkpath(GENERATED_DIR)
    path = joinpath(GENERATED_DIR, "metadata.yml")
    YAML.write_file(path, combined)
    path
end

function combined_metadata_path(project)
    metadata_path = config(project, "metadata_path")::String
    combined_path = combine_metadata(metadata_path)
    return combined_path
end

"""
    project_info(path::String, project::AbstractString)

Return project info for TOML file at `path` as raw text or `nothing` if the TOML
doesn't contain an entry for `project`.
"""
function project_info(path::String, project::AbstractString)
    text = read(path, String)
    dic = TOML.parse(text)::Dict{String,Any}
    projects = dic["projects"]::Dict{String,Any}
    if project in keys(projects)
        project = string(project)::String
        return projects[project]::Dict{String,Any}
    else
        return nothing
    end
end

const default_config = Dict{String,Union{Nothing,Dict{String,Any}}}()

function _default_config(project::String)
    if !(project in keys(default_config))
        path = joinpath(DEFAULTS_DIR, "config.toml")
        data = project_info(path, project)
        default_config[project] = data
    end
    return default_config[project]
end
_default_config(project::AbstractString) = _default_config(string(project)::String)

function user_config(project::AbstractString)
    path = "config.toml"
    if isfile(path)
        return project_info(path, project)
    else
        default_config_path = joinpath(Books.DEFAULTS_DIR, "config.toml")
        absolute_config_path = joinpath(pwd(), "config.toml")
        msg = """
            No file found at $absolute_config_path.
            (See $default_config_path for an example configuration.)
            """
        @warn msg
    end
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
    default = _default_config(project)
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
        return default[key]
    end
end
