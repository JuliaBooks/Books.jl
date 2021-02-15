include_regex = r"```{\.include}([\w\W]*?)```"

"""
    include_filenames(s::AbstractString)::Vector

Returns the filenames mentioned in `{.include}` code blocks.
"""
function include_filenames(s::AbstractString)::Vector
    matches = eachmatch(include_regex, s)
    nested_filenames = [split(m[1]) for m in matches]
    vcat(nested_filenames...) 
end

"""
    generate_dynamic_content(chs=chapters())

Populate the files in `_generated/` by calling the required methods.
These methods are specified by the filename and will output to that filename.
This allows the user to easily link code blocks to code.
"""
function generate_dynamic_content(ins=inputs())
    for path in ins
        1 
    end
end
