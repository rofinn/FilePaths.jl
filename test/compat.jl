module TestPkg

using FilePathsBase
using FilePathsBase: /
using FilePaths

# Test for basic definitions taking abstract paths
FilePaths.@compat function typical(x::AbstractPath, y::AbstractPath)
    return relative(x, y)
end

# Test for definition taking parameterized paths
FilePaths.@compat function parameterized(x::P, y::P) where P <: AbstractPath
    return relative(x, y)
end

# Test for definition with a path return type
# (indicating that we should convert it back to a string)
FilePaths.@compat function rtype(x::P, y::P)::P where P <: AbstractPath
    return relative(x, y)
end

# Test for a mixed input definition
# z is an unused variable to make sure untyped variables don't break the macro
FilePaths.@compat function mixed(x::P, y::String, z)::P where P <: AbstractPath
    return x / y
end

# Test kwargs
FilePaths.@compat function kwargs(x::AbstractPath; y::AbstractPath=cwd())::AbstractPath
    return relative(x, y)
end

# Test optional args
FilePaths.@compat function optargs(x::AbstractPath, y::AbstractPath=cwd())::AbstractPath
    return relative(x, y)
end

# Test for inline definitions
FilePaths.@compat inline(x::AbstractPath, y::AbstractPath) = relative(x, y)


# Test for custom path type
struct MyPath <: AbstractPath
    x::String
end

__init__() = FilePathsBase.register(MyPath)
function Base.tryparse(::Type{MyPath}, str::AbstractString)
    startswith(str, "mypath://") ? MyPath(str) : nothing
end

FilePaths.@compat mypath_testem(path::MyPath) = "**"*path.x

end  # TestPkg module

@testset "@compat" begin
    cd(absolute(parent(Path(@__FILE__)))) do
        reg = Sys.iswindows() ? "..\\src\\FilePaths.jl" : "../src/FilePaths.jl"
        @test ispath(reg)
        p = Path(reg)

        @testset "typical" begin
            # Passing paths should should work just like calling relative
            @test TestPkg.typical(p, home()) == relative(p, home())

            # Passing strings should now also work just like calling relative
            @test TestPkg.typical(string(p), string(home())) == relative(p, home())

            # Mixing strings and paths should also work here
            @test TestPkg.typical(string(p), home()) == relative(p, home())
        end

        @testset "parameterized" begin
            # Passing paths should should work just like calling relative
            @test TestPkg.parameterized(p, home()) == relative(p, home())

            # Passing strings should now also work just like calling relative
            @test TestPkg.parameterized(string(p), string(home())) == relative(p, home())

            # Mixing strings and paths should error because x and y need to be the same type
            @test_throws MethodError TestPkg.parameterized(string(p), home())
        end

        @testset "rtype" begin
            # Passing paths should should work just like calling relative
            @test TestPkg.rtype(p, home()) == relative(p, home())

            # Passing strings should also convert the output to a string
            @test TestPkg.rtype(string(p), string(home())) == string(relative(p, home()))

            # Mixing strings and paths should error because x and y need to be the same type
            @test_throws MethodError TestPkg.rtype(string(p), home())
        end

        @testset "mixed" begin
            # Passing in a path as the first argument should return the same output as p / home()
            prefix = parent(p)
            suffix = basename(p)
            @test TestPkg.mixed(prefix, suffix, 2) == p

            # Passing 2 strings should also convert the output to a string
            @test TestPkg.mixed(string(prefix), suffix, 2) == string(p)

            # Passing a path where we explicitly want a string will error
            @test_throws MethodError TestPkg.mixed(prefix, Path(suffix), 2)
        end

        @testset "optargs" begin
            # Passing paths should should work just like calling relative
            @test TestPkg.optargs(p, home()) == relative(p, home())

            # Passing strings should also return the relative path as a string
            @test TestPkg.optargs(string(p), string(home())) == string(relative(p, home()))

            # With optional arguments we should be able to mix strings on either argument
            @test TestPkg.optargs(p, string(home())) == string(relative(p, home()))
            @test TestPkg.optargs(string(p), home()) == string(relative(p, home()))

            # Use default
            @test TestPkg.optargs(p) == relative(p, cwd())
            @test TestPkg.optargs(string(p)) == string(relative(p, cwd()))
        end

        @testset "inline" begin
            # Passing paths should should work just like calling relative
            @test TestPkg.inline(p, home()) == relative(p, home())

            # Passing strings should now also work just like calling relative
            @test TestPkg.inline(string(p), string(home())) == relative(p, home())

            # Mixing strings and paths should also work here
            @test TestPkg.inline(string(p), home()) == relative(p, home())
        end

        @testset "Custom path type" begin
            @test TestPkg.mypath_testem(TestPkg.MyPath("mypath://foo")) == "**mypath://foo"
            @test TestPkg.mypath_testem("mypath://foo") == "**mypath://foo"
        end
    end
end
