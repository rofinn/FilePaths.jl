using URIParser
using FilePaths

@testset "URI" begin
    @test string(URI(p"/foo/bar")) == "file:///foo/bar"
end
