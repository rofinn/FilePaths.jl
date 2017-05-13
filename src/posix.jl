immutable PosixPath <: AbstractPath
    parts::Tuple
end

function PosixPath(str::AbstractString)
    str = String(str)

    if isempty(str)
        return PosixPath(tuple("."))
    end

    tokenized = split(str, POSIX_PATH_SEPARATOR)
    if isempty(tokenized[1])
        tokenized[1] = POSIX_PATH_SEPARATOR
    end
    return PosixPath(tuple(tokenized...))
end

# The following should be implemented in the concrete types
==(a::PosixPath, b::PosixPath) = parts(a) == parts(b)
Base.string(path::PosixPath) = joinpath(parts(path)...)
parts(path::PosixPath) = path.parts

function isabs(path::PosixPath)
    if parts(path)[1] == POSIX_PATH_SEPARATOR
        return true
    else
        return false
    end
end

drive(path::PosixPath) = ""

function root(path::PosixPath)
    if parts(path)[1] == POSIX_PATH_SEPARATOR
        return POSIX_PATH_SEPARATOR
    else
        return ""
    end
end

function expanduser(path::PosixPath)
    p = parts(path)

    if p[1] == "~"
        if length(p) > 1
            return PosixPath(tuple(homedir(), p[2:end]...))
        else
            return PosixPath(tuple(homedir()))
        end
    end

    return path
end
