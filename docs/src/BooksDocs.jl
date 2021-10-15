module BooksDocs

import IOCapture
import Latexify
import MCMCChains
import Statistics
import TOML

using Reexport
@reexport using AlgebraOfGraphics
@reexport using Books
@reexport using CairoMakie
@reexport using CodeTracking
@reexport using DataFrames
@reexport using Dates
@reexport using Plots

plot = Plots.plot

M = BooksDocs
export M

include("includes.jl")

function build()
    fail_on_error = true
    Books.gen(; fail_on_error)
    extra_head = """
        <!-- Google Search Console verification. -->
        <meta name="google-site-verification" content="deJcoJ2nJMQFPa1hJZULlns4yYOCQXsfcsVdafQMgdc" />
        <!-- Privacy-friendly analytics via Fathom. -->
        <script src="https://cdn.usefathom.com/script.js" data-site="WBQVJWZZ" defer></script>
        <!-- Privacy-friendly analytics via Pirsch. -->
        <script defer type="text/javascript" src="https://api.pirsch.io/pirsch.js" id="pirschjs" data-code="0bjwF9vL4Z9Chiae5YEpufSR0rx8b1tL"></script>
        """
    Books.build_all(; extra_head, fail_on_error)
end

end # module
