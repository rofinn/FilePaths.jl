__precompile__()

module FilePaths

using Reexport, URIParser, MacroTools
@reexport using FilePathsBase

include("uri.jl")
include("compat.jl")

end # end of module
