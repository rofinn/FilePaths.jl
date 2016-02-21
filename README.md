# Paths.jl

[![Build Status](https://travis-ci.org/Rory-Finnegan/Paths.jl.svg?branch=master)](https://travis-ci.org/Rory-Finnegan/Paths.jl)
[![codecov.io](https://codecov.io/github/Rory-Finnegan/Paths.jl/coverage.svg?branch=master)](https://codecov.io/github/Rory-Finnegan/Paths.jl?branch=master)

Paths.jl provides a type based approach to working with filesystem paths in julia.

## Intallation:
Paths.jl isn't registered, so you'll need to use `Pkg.clone` to install it.
```
julia> Pkg.clone("https://github.com/Rory-Finnegan/Paths.jl")
```

## Usage:
```
julia> using Paths
```

The first important difference about working with paths in Paths.jl is that a path is an immutable list (Tuple) of strings, rather than simple a string.

Path creation:
```
julia> Path("~/repos/Paths.jl/")
Paths.PosixPath(("~","repos","Paths.jl",""))
```
or
```
julia> p"~/repos/Paths.jl/"
Paths.PosixPath(("~","repos","Paths.jl",""))
```

Human readable file status info:
```
julia> stat(p"README.md")
Status(
  device = 16777220,
  inode = 48428965,
  mode = -rw-r--r--,
  nlink = 1,
  uid = 501,
  gid = 20,
  rdev = 0,
  size = 1880 (1.8K),
  blksize = 4096 (4.0K),
  blocks = 8,
  mtime = 2016-02-16T00:49:27,
  ctime = 2016-02-16T00:49:27,
)
```

Working with permissions:
```
julia> m = mode(p"README.md")
-rw-r--r--

julia> m - readable(:ALL)
--w-------

julia> m + executable(:ALL)
-rwxr-xr-x

julia> chmod(p"README.md", "+x")

julia> mode(p"README.md")
-rwxr-xr-x

julia> chmod(p"README.md", m)

julia> m = mode(p"README.md")
-rw-r--r--

julia> chmod(p"README.md", user=(READ+WRITE+EXEC), group=(READ+WRITE), other=READ)

julia> mode(p"README.md")
-rwxrw-r--

```


Reading and writing directly to file paths:
```
julia> write(p"testfile", "foobar")
6

julia> read(p"testfile")
"foobar"
```

All the standard methods for working with paths in base julia exist in the Paths.jl. The following describes the rough mapping of method names. Use `?` at the REPL to get the documentation and arguments as they may be different than the base implementations.

Base | Paths.jl
--- | ---
pwd() | cwd()
homedir() | home()
cd() | cd()
joinpath() | joinpath()
basename() | basename()
N/A | filename
N/A | extension
N/A | extensions
ispath | exists
realpath | real
normpath | norm
abspath | abs
relpath | relative
N/A | glob
stat | stat
lstat | lstat
filemode | mode
N/A | modified
N/A | created
isdir | isdir
isfile | isfile
islink | islink
issocket | issocket
isfifo | isfifo
ischardev | ischardev
isblockdev | isblockdev
isexecutable (deprecated) | isexecutable
iswritable (deprecated) | iswritabe
isreadable (deprecated) | isreadable
ismount | ismount
isabspath | isabs
N/A | drive
N/A | root
expanduser | expanduser
mkdir | mkdir
mkpath | N/A (use mkdir)
symlink | symlink
cp | copy
mv | move
rm | remove
touch | touch
tempname | tmpname
tempdir | tmpdir 
mktemp | mktmp 
mktempdir | mktmpdir 
chmod (non-recursive) | chmod (recursive unix-only)
chown (PR) | chown (unix only)
N/A | read
N/A | write

## TODO:
* isexecutable
* iswritable
* isreadable
* ismount
* cross platform chmod and chown


