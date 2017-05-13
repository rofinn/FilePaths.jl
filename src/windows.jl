immutable WindowsPath <: AbstractPath
    parts::Tuple
    drive::String
end

function WindowsPath(str::AbstractString)
    if isempty(str)
        return WindowsPath(tuple("."), "")
    end

    drive, path = splitdir(str)
    tokenized = split(path, WIN_PATH_SEPARATOR)

    if isempty(tokenized[1])
        tokenized[1] = WIN_PATH_SEPARATOR
    end

    return WindowsPath(tuple(tokenized...), drive)
end


# The following should be implemented in the concrete types
==(a::WindowsPath, b::WindowsPath) = parts(a) == parts(b) && drive(a) == drive(b)
Base.string(path::WindowsPath) = joinpath(parts(path)...)
parts(path::WindowsPath) = path.parts
drive(path::WindowsPath) = path.drive

function isabs(path::WindowsPath)
    if parts(path[1]) == WIN_PATH_SEPARATOR && !isempty(drive(path))
        return true
    else
        return false
    end
end

function root(path::WindowsPath)
    if parts(path)[1] == WIN_PATH_SEPARATOR
        return WIN_PATH_SEPARATOR
    else
        return ""
    end
end

expanduser(path::WindowsPath) = path

