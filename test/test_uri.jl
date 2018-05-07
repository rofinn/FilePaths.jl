using URIParser
using FilePaths

@testset "URI" begin
    @test string(URI(p"/foo/bar")) == "file:///foo/bar"
    @test string(URI(p"/foo foo/bar")) == "file:///foo%20foo/bar"
end
