# FilePaths.jl

[![Build Status](https://github.com/rofinn/FilePaths.jl/workflows/CI/badge.svg)](https://github.com/rofinn/FilePaths.jl/actions)
[![codecov.io](https://codecov.io/github/rofinn/FilePaths.jl/coverage.svg?branch=master)](https://codecov.io/rofinn/FilePaths.jl?branch=master)

[FilePathsBase.jl](https://github.com/rofinn/FilePathsBase.jl) provides a type based API for working with filesystem paths.
Please review the FilePathsBase [docs](https://rofinn.github.io/FilePathsBase.jl/stable/) for more info on working with the base filepath types.
FilePaths.jl extends FilePathsBase to provide easier interoperability with the rest of the Julia ecosystem.

## Intallation:
FilePaths.jl is registered, so you can to use `Pkg.add` to install it.

```julia
julia> Pkg.add("FilePaths")
```

## Usage:
```julia
julia> using FilePaths; using FilePathsBase: /
```

Globbing files:
```julia
julia> using Glob

julia> glob("*test*.jl", p"test")
2-element Array{PosixPath,1}:
 p"test/runtests.jl"
 p"test/test_uri.jl"
```

URIParsing:
```julia
julia> using URIs

julia> URI(cwd() / p"test/runtests.jl")
URI("file:///Users/rory/repos/FilePaths.jl/test/runtests.jl")
```

Writing `String` and `AbstractPath` compatible code:

```julia
julia> FilePaths.@compat function myrelative(x::AbstractPath, y::AbstractPath)
           return relative(x, y)
       end
myrelative (generic function with 2 methods)

julia> FilePaths.@compat function myjoin(x::P, y::String)::P where P <: AbstractPath
           return x / y
       end
myjoin (generic function with 2 methods)

julia> myrelative(cwd(), home())
p"repos/FilePaths.jl"

julia> myrelative(pwd(), homedir())
p"repos/FilePaths.jl"

julia> myjoin(parent(cwd()), "FilePaths.jl")
p"/Users/rory/repos/FilePaths.jl"

julia> myjoin("/Users/rory/repos", "FilePaths.jl")
"/Users/rory/repos/FilePaths.jl"
```
