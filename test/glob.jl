using Glob

@test string.(glob("*tests.jl", cwd())) == glob("*tests.jl", pwd())
@test string.(readdir(glob"*tests.jl", cwd())) ==  readdir(glob"*tests.jl", pwd())
