
cd(abs(parent( Path(string(@__FILE__)) ))) do
    @testset "Simple Path Usage" begin
        reg = "../src/Paths.jl"
        @test ispath(reg)

        p = Path(reg)

        @test p == p"../src/Paths.jl"
        @test string(p) == reg
        @test string(cwd()) == pwd()
        @test string(home()) == homedir()

        @test parts(p) == ("..", "src", "Paths.jl")
        @test hasparent(p)
        @test parent(p) == p"../src"
        @test parents(p) == [p"..", p"../src"]
        @test basename(p) == "Paths.jl"
        @test joinpath(parent(p), Path(basename(p))) == p
        @test filename(p) == "Paths"
        @test extension(p) == "jl"
        @test extensions(p"foo.tar.gz") == ["tar", "gz"]
        @test exists(p)
        @test !isabs(p)
        @test string(norm(p"../src/../src/Paths.jl")) == normpath("../src/../src/Paths.jl")
        @test string(abs(p)) == abspath(string(p))
        @test string(relative(p, home())) == relpath(string(p), homedir())

        s = stat(p)
        @test string(mode(p)) == "-rw-r--r--"
        @test isfile(p)
        @test isdir(parent(p))
    end
end

mktmpdir() do d
    cd(d) do
        @testset "Modifying Path Usage" begin
            new_path = p"foo"

            mkdir(new_path)
            @test_throws ErrorException mkdir(new_path)
            remove(new_path)

            new_path = p"foo/bar"
            @test_throws ErrorException mkdir(new_path)
            mkdir(new_path; recursive=true)
            mkdir(new_path; recursive=true, exist_ok=true)

            other_path = p"car/bar"
            # @test_throws ErrorException copy(new_path, other_path)
            copy(new_path, other_path; recursive=true)
            remove(p"car"; recursive=true)

            # @test_throws ErrorException move(new_path, other_path)
            move(new_path, other_path; recursive=true)
            remove(p"car"; recursive=true)

            mkdir(new_path; recursive=true)

            symlink(new_path, p"mysymlink")
            symlink(new_path, p"mysymlink"; exist_ok=true, overwrite=true)

            touch(p"newfile")

            chmod(p"newfile", user=(READ+WRITE+EXEC), group=(READ+EXEC), other=READ)
            @test string(mode(p"newfile")) == "-rwxr-xr--"
            chmod(p"newfile", "-x")
            @test string(mode(p"newfile")) == "-rw-r--r--"
            write(p"newfile", "foobar")
            @test read(p"newfile") == "foobar"
        end
    end
end
