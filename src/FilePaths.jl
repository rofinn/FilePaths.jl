module FilePaths

using MacroTools
using Reexport
using Requires

@reexport using FilePathsBase

include("compat.jl")

function __init__()
    @require Glob="c27321d9-0574-5035-807b-f59d2c89b15c" include("glob.jl")
    @require URIParser="30578b45-9adc-5946-b283-645ec420af67" include("uriparser.jl")
    @require URIs="5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4" include("uris.jl")
    @require FileIO="5789e2e9-d7fb-5bc7-8068-2c6fae9b9549" include("fileio.jl")
end

end # end of module
