module Paths

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

abstract AbstractPath

# The following should be implemented in the concrete types
Base.string(path::AbstractPath) = error("`string not implemented")
parts(path::AbstractPath) = error("`parts` not implemented.")
root(path::AbstractPath) = error("`root` not implemented.")

include("constants.jl")
include("mode.jl")
include("status.jl")
include("posix.jl")
include("windows.jl")
include("path.jl")

end # end of module
