module Books

import CodeTracking
import LiveServer
import Markdown
import Tectonic
import TOML
import YAML

using Memoize
using Requires
using pandoc_jll
using pandoc_crossref_jll

const PROJECT_ROOT = pkgdir(Books)
const GENERATED_DIR = "_gen"
const DEFAULTS_DIR = joinpath(PROJECT_ROOT, "defaults")
const BUILD_DIR = "_build"
mkpath(BUILD_DIR)

include("html.jl")
include("defaults.jl")
include("ci.jl")
include("build.jl")
include("serve.jl")
include("output.jl")
include("outputs/dataframes.jl")
include("showcode.jl")
include("generate.jl")

export html, pdf, docx, build_all
export code, ImageOptions, Options
export code_block
export @sc, CodeAndFunction, @sco
export gen
export serve

function __init__()
    @require AlgebraOfGraphics="cbdf2221-f076-402e-a563-3d30da359d67" include("outputs/aog.jl")
end

end # module
