module Books

if isdefined(Base, :Experimental) && isdefined(Base.Experimental, Symbol("@max_methods"))
    @eval Base.Experimental.@max_methods 1
end

using RelocatableFolders: @path
const PKGDIR = @path string(pkgdir(Books))::String

let
    path = joinpath(PKGDIR, "README.md")
    text = read(path, String)
    @doc text Books
end

import Artifacts
import CodeTracking
import LazyArtifacts
import LiveServer
import TOML
import YAML

using Dates: today
using InteractiveUtils: gen_call_with_extracted_types
using Markdown: MD
using Memoize: @memoize
using ProgressMeter: ProgressMeter
using Revise: entr
using pandoc_crossref_jll: pandoc_crossref_jll
using pandoc_jll: pandoc_jll
using Typst_jll: typst

const GENERATED_DIR = "_gen"
const DEFAULTS_DIR = joinpath(PKGDIR, "defaults")
const BUILD_DIR = "_build"
const JULIAMONO_VERSION = "0.045"
mkpath(BUILD_DIR)

include("defaults.jl")
include("ci.jl")
include("sitemap.jl")
include("html.jl")
include("build.jl")
export html, pdf, build_all
include("serve.jl")
include("output.jl")
export without_caption_label
include(joinpath("outputs", "dataframes.jl"))
include("showcode.jl")
include("generate.jl")
export code, ImageOptions, Options

export code_block, output_block
export @sc, sc, CodeAndFunction, @sco, sco, scob
export gen, entr_gen
export serve

end # module
