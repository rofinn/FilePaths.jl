module TestFileIO

using Test
using FileIO
using ImageCore
using FilePathsBase
using FilePathsBase: /
using FilePaths

@testset "File/Stream" begin
    imgdata = repeat(distinguishable_colors(16), inner=(1, 16)) # (16, 16) RGB image

    mktempdir(SystemPath) do testdir
        savepath = testdir / "data.png"
        @test_nowarn save(savepath, imgdata)
        @test load(savepath) == imgdata

        savepath = testdir / "data_io.png"
        @test_nowarn open(savepath, "w") do io
            save(Stream{format"PNG"}(io, savepath), imgdata)
        end
        @test imgdata == open(savepath, "r") do io
            load(Stream{format"PNG"}(io, savepath))
        end
    end
end

end
