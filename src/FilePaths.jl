__precompile__()

module FilePaths

using Glob, MacroTools, Reexport, URIParser
using Glob: GlobMatch
@reexport using FilePathsBase

include("compat.jl")
include("glob.jl")
include("uri.jl")

end # end of module
