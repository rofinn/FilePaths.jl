include_path = joinpath(
    abspath(dirname(dirname(@__FILE__))),
    "src/FilePaths.jl"
)
include(include_path)

using FilePaths

import URIParser: URI

using Base.Test

info("Beginning tests...")

include("mode.jl")
include("path.jl")

info("All tests passed.")
