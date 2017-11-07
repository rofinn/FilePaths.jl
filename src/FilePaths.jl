module FilePaths

using Compat

import Base: ==
export
    # Types
    AbstractPath,
    Path,
    PosixPath,
    WindowsPath,
    Mode,
    Status,

    # Methods
    cwd,
    home,
    parts,
    root,
    hasparent,
    parents,
    filename,
    extension,
    extensions,
    exists,
    isabs,
    mode,
    created,
    modified,
    relative,
    glob,
    uri,
    move,
    remove,
    tmpname,
    tmpdir,
    mktmp,
    mktmpdir,
    chown,
    executable,
    readable,
    writable,
    raw,

    # Macros
    @p_str,

    # Constants
    READ,
    WRITE,
    EXEC

@static if VERSION < v"0.6.0-dev.2514"
    import Base: isexecutable
else
    export isexecutable
end

@compat abstract type AbstractPath end

# The following should be implemented in the concrete types
Base.String(path::AbstractPath) = error("`String not implemented")
parts(path::AbstractPath) = error("`parts` not implemented.")
root(path::AbstractPath) = error("`root` not implemented.")

Base.convert(::Type{AbstractPath}, x::AbstractString) = Path(x)

include("constants.jl")
include("libc.jl")
include("mode.jl")
include("status.jl")
include("posix.jl")
include("windows.jl")
include("path.jl")
include("deprecates.jl")

end # end of module
