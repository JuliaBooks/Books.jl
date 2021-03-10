module Books

import LiveServer
import Markdown
import YAML

using Memoize
using Requires

const PROJECT_ROOT = pkgdir(Books)
const GENERATED_DIR = "_generated"
const DEFAULTS_DIR = joinpath(PROJECT_ROOT, "defaults")
const BUILD_DIR = "build"
mkpath(BUILD_DIR)

include("html.jl")
include("defaults.jl")
include("build.jl")
include("serve.jl")
include("ci.jl")
include("output.jl")
include("generate.jl")

export html, pdf, docx
export code, outputs
export code_block
export generate_content
export serve

function __init__()
    @require DataFrames="a93c6f00-e57d-5684-b7b6-d8193f3e46c0" include("outputs/dataframes.jl")
    @require Gadfly="c91e804a-d5a3-530f-b6f0-dfbca275c004" include("outputs/gadfly.jl")
end

end # module
