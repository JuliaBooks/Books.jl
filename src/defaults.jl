@memoize function default_metadata()::Dict
    path = joinpath(DEFAULTS_DIR, "metadata.yml")
    data = YAML.load_file(path)
end

function user_metadata()
    path = "metadata.yml"
    return isfile(path) ? YAML.load_file(path) : nothing
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
    write_metadata()

Write `metadata.yml` for Pandoc to $(Books.GENERATED_DIR).
The file is a combination of Books.jl default settings and the user-defined settings.
"""
function write_metadata()
    default = default_metadata()
    user = user_metadata()
    combined = isnothing(user) ? default : override(default, user)
    path = joinpath(GENERATED_DIR, "metadata.yml")
    YAML.write_file(path, combined)
end

@memoize function default_config()::Dict
    path = joinpath(DEFAULTS_DIR, "config.toml")
    content = read(path, String)
    TOML.parse(content)
end

function user_config()
    path = "config.toml"
    function toml_parse(path)
        text = read(path, String)
        TOML.parse(text)
    end
    return isfile(path) ? toml_parse(path) : nothing
end

"""
    config()

Read user `config.toml` and `$DEFAULTS_DIR/config.toml` and combine the information.
"""
function config()
    default = default_config()
    user = user_config()
    combined = isnothing(user) ? default : override(default, user)
end

contents() = config()["contents"]
pdf_filename() = config()["pdf_filename"]
