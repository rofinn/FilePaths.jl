using FilePaths
using Test

@testset "FilePaths" begin

include("compat.jl")
include("glob.jl")
include("test_uri.jl")
include("fileio.jl")

end
