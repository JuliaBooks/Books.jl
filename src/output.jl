struct ImageOptions
    caption::String
    label::String
end

function ImageOptions(; caption=nothing, label=nothing)
    ImageOptions(caption, label)
end

"""
    convert_output(path, out)

Fallback method for `out::Any`.
Other methods are defined via Requires.
`path` is the path listed in the Pandoc Markdown file.
"""
convert_output(path, out) = string(out)

