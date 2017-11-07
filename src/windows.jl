immutable WindowsPath <: AbstractPath
    parts::Tuple{Vararg{String}}
    drive::String
    root::String
end

WindowsPath() = WindowsPath(tuple(), "", "")

WindowsPath(parts::Tuple) = WindowsPath(parts, "", "")

function WindowsPath(str::AbstractString)
    if isempty(str)
        return WindowsPath(tuple("."), "", "")
    end

    if startswith(str, "\\\\?\\")
        error("The \\\\?\\ prefix is currently not supported.")
    end

    str = replace(str, POSIX_PATH_SEPARATOR, WIN_PATH_SEPARATOR)

    if startswith(str, "\\\\")
        error("UNC paths are currently not supported.")
    elseif startswith(str, "\\")
        tokenized = split(str, WIN_PATH_SEPARATOR)

        return WindowsPath(tuple(WIN_PATH_SEPARATOR, String.(tokenized[2:end])...), "", WIN_PATH_SEPARATOR)
    elseif contains(str, ":")
        l_drive, l_path = splitdrive(str)

        tokenized = split(l_path, WIN_PATH_SEPARATOR)

        l_root = isempty(tokenized[1]) ? WIN_PATH_SEPARATOR : ""

        if isempty(tokenized[1])
            tokenized = tokenized[2:end]
        end

        if !isempty(l_drive) || !isempty(l_root)
            tokenized = tuple(string(l_drive, l_root), tokenized...)
        end

        return WindowsPath(tuple(String.(tokenized)...), l_drive, l_root)
    else
        tokenized = split(str, WIN_PATH_SEPARATOR)

        return WindowsPath(tuple(String.(tokenized)...), "", "")
    end
end

==(a::WindowsPath, b::WindowsPath) =
    lowercase.(parts(a)) == lowercase.(parts(b)) &&
    lowercase(drive(a)) == lowercase(drive(b)) &&
    lowercase(root(a)) == lowercase(root(b))
Base.String(path::WindowsPath) = joinpath(parts(path)...)
parts(path::WindowsPath) = path.parts
drive(path::WindowsPath) = path.drive
root(path::WindowsPath) = path.root
anchor(path::WindowsPath) = path.drive * path.root

function Base.show(io::IO, path::WindowsPath)
    print(io, "p\"")
    if isabs(path)
        print(io, replace(anchor(path), "\\", "/"))
        print(io, join(parts(path)[2:end], "/"))
    else
        print(io, join(parts(path), "/"))
    end
    print(io, "\"")
end

function isabs(path::WindowsPath)
    return !isempty(drive(path)) || !isempty(root(path))
end

expanduser(path::WindowsPath) = path
