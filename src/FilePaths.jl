__precompile__()

module FilePaths

using Reexport, URIParser
@reexport using FilePathsBase

include("uri.jl")

end # end of module
