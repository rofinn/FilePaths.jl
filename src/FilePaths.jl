module FilePaths

using MacroTools
using Reexport

@reexport using FilePathsBase

include("compat.jl")

end # end of module
