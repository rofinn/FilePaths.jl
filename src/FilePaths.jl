module FilePaths

using MacroTools
using Reexport
using Requires

@reexport using FilePathsBase

include("compat.jl")

function __init__()
    @require Glob="c27321d9-0574-5035-807b-f59d2c89b15c" include("glob.jl")
    @require URIParser="30578b45-9adc-5946-b283-645ec420af67" include("uri.jl")
end

end # end of module
