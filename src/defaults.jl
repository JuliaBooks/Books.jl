@memoize function default_metadata()::Dict
    path = joinpath(PROJECT_ROOT, "defaults", "metadata.yml")
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
    default_meta = default_metadata()
    user_meta = user_metadata()
    combined = isnothing(user_meta) ? default_meta : override(default_meta, user_meta)
    path = joinpath(GENERATED_DIR, "metadata.yml")
    YAML.write_file(path, combined)
end
