import URIParser: URI
import Glob: glob

# Generic constructor which will create the appropriate
# implementation based on the host platform.
function Path(str::AbstractString)
    @static if is_unix()
        PosixPath(str)
    else
        WindowsPath(str)
    end
end

# non-standard string literal
macro p_str(path)
    Path(path)
end

cwd() = Path(pwd())
home() = Path(homedir())

#=
Path Modifiers
===============================================
The following are methods for working with and extracting
path components
=#
hasparent(path::AbstractPath) = length(parts(path)) > 1

Base.parent(path::AbstractPath) = parents(path)[end]

function parents{T<:AbstractPath}(path::T)
    if hasparent(path)
        return map(1:length(parts(path))-1) do i
            T(parts(path)[1:i])
        end
    else
        error("$(string(path)) has no parents")
    end
end

function Base.joinpath{T<:AbstractPath}(pieces::T...)
    all_parts = String[]

    for p in pieces
        push!(all_parts, parts(p)...)
    end

    return T(tuple(all_parts...))
end

Base.basename(path::AbstractPath) = parts(path)[end]

function filename(path::AbstractPath)
    name = basename(path)
    return split(name, '.')[1]
end

function extension(path::AbstractPath)
    name = basename(path)

    tokenized = split(name, '.')
    if length(tokenized) > 1
        return tokenized[end]
    else
        return ""
    end
end

function extensions(path::AbstractPath)
    name = basename(path)

    tokenized = split(name, '.')
    if length(tokenized) > 1
        return tokenized[2:end]
    else
        return []
    end
end

exists(path::AbstractPath) = ispath(string(path))
Base.real(path::AbstractPath) = Path(realpath(string(path)))

function Base.norm{T<:AbstractPath}(path::T)
    p = parts(path)
    result = String[]
    rem = length(p)
    count = 0
    del = 0

    while count < length(p)
        str = p[end-count]

        if str == ".."
            del += 1
        elseif str != "."
            if del == 0
                push!(result, str)
            else
                del -= 1
            end
        end

        rem -= 1
        count += 1
    end

    return T(tuple(fill("..", del)..., reverse(result)...))
end

function Base.abs(path::AbstractPath)
    result = expanduser(path)

    if isabs(result)
        return norm(result)
    else
        return norm(joinpath(cwd(), result))
    end
end

function relative{T<:AbstractPath}(path::T, start::T=T("."))
    curdir = "."
    pardir = ".."

    p = parts(abs(path))
    s = parts(abs(start))

    p == s && return curdir

    i = 0
    while i < min(length(p), length(s))
        i += 1
        if p[i] != s[i]
            i -= 1
            break
        end
    end

    pathpart = p[i+1:findlast(x -> !isempty(x), p)]
    #pathpart = join(path_arr[i+1:findlast(x -> !isempty(x), path_arr)], path_separator)
    prefix_num = findlast(x -> !isempty(x), s) - i - 1
    if prefix_num >= 0
        relpath_ = isempty(pathpart) ?
            tuple(fill(pardir, prefix_num + 1)...) :
            tuple(fill(pardir, prefix_num + 1)..., pathpart...)
    else
        relpath_ = pathpart
    end
    return isempty(relpath_) ? T(curdir) : T(relpath_)
end

function glob{T<:AbstractPath}(path::T, pattern::AbstractString)
    matches = glob(pattern, string(path))
    map(T, matches)
end

function uri(path::AbstractPath)
    if isempty(root(path))
        error("$(string(path)) is not an absolute path")
    end

    uri_str = "file://$(string(path))"

    return URI(uri_str)
end

#=
The following a descriptive methods for paths
built around stat
=#
Base.stat(path::AbstractPath) = Status(stat(string(path)))
Base.lstat(path::AbstractPath) = Status(lstat(string(path)))
mode(path::AbstractPath) = stat(path).mode
Base.size(path::AbstractPath) = stat(path).size
modified(path::AbstractPath) = stat(path).mtime
created(path::AbstractPath) = stat(path).ctime
Base.isdir(path::AbstractPath) = isdir(mode(path))
Base.isfile(path::AbstractPath) = isfile(mode(path))
Base.islink(path::AbstractPath) = islink(mode(path))
Base.issocket(path::AbstractPath) = issocket(mode(path))
Base.isfifo(path::AbstractPath) = issocket(mode(path))
Base.ischardev(path::AbstractPath) = ischardev(mode(path))
Base.isblockdev(path::AbstractPath) = isblockdev(mode(path))

function isexecutable(path::AbstractPath)
    s = stat(path)
    usr = User()

    return isexecutable(s.mode, :ALL) || isexecutable(s.mode, :OTHER) ||
        ( usr.uid == s.user.uid && isexecutable(s.mode, :USER) ) ||
        ( usr.gid == s.group.gid && isexecutable(s.mode, :GROUP) )
end

function Base.iswritable(path::AbstractPath)
    s = stat(path)
    usr = User()

    return iswritable(s.mode, :ALL) || iswritable(s.mode, :OTHER) ||
        ( usr.uid == s.user.uid && iswritable(s.mode, :USER) ) ||
        ( usr.gid == s.group.gid && iswritable(s.mode, :GROUP) )
end

function Base.isreadable(path::AbstractPath)
    s = stat(path)
    usr = User()

    return isreadable(s.mode, :ALL) || isreadable(s.mode, :OTHER) ||
        ( usr.uid == s.user.uid && isreadable(s.mode, :USER) ) ||
        ( usr.gid == s.group.gid && isreadable(s.mode, :GROUP) )
end

function Base.ismount(path::AbstractPath)
    isdir(path) || return false
    s1 = lstat(path)
    # Symbolic links cannot be mount points
    islink(s1) && return false
    s2 = lstat(parent(path))
    # If a directory and its parent are on different devices,  then the
    # directory must be a mount point
    (s1.device != s2.device) && return true
    (s1.inode == s2.inode) && return true
    false
end

#=
Path Operations
===============================================
The following are methods for actually manipulating the
filesystem.

NOTE: Currently, we are just wrapping base julia functions,
but in the future we'll likely be handling platform specific
code in the implementation instances.
=#

Base.cd(path::AbstractPath) = cd(string(path))
function Base.cd(fn::Function, dir::AbstractPath)
    old = cwd()
    try
        cd(dir)
        fn()
   finally
        cd(old)
    end
end

function Base.mkdir(path::AbstractPath; mode=0o777, recursive=false, exist_ok=false)
    if exists(path) && !exist_ok
        error("$path already exists.")
    else
        if !hasparent(path) || exists(parent(path))
            mkdir(string(path), mode)
        elseif hasparent(path) && !exists(parent(path)) && recursive
            mkdir(parent(path); mode=mode, recursive=recursive, exist_ok=exist_ok)
        else
            error(
                "The parent of $path does not exist. " *
                "Pass recursive=true to create it."
            )
        end
    end
end

function Base.symlink(src::AbstractPath, dest::AbstractPath; exist_ok=false, overwrite=false)
    if exists(src)
        if exists(dest) && exist_ok && overwrite
            remove(dest, recursive=true)
        end

        if !exists(dest)
            symlink(string(src), string(dest))
        elseif !exist_ok
            error("$dest already exists.")
        end
    else
        error("$src is not a valid path")
    end
end


function Base.copy(src::AbstractPath, dest::AbstractPath; recursive=false, exist_ok=false, overwrite=false, symlinks=false)
    if exists(src)
        if exists(dest) && exist_ok && overwrite
            remove(dest, recursive=true)
        end

        if !exists(dest)
            if hasparent(dest) && recursive
                mkdir(parent(dest); recursive=recursive, exist_ok=true)
            end

            cp(src, dest; follow_symlinks=symlinks)
        elseif !exist_ok
            error("$dest already exists.")
        end
    else
        error("$src is not a valid path")
    end
end

function move(src::AbstractPath, dest::AbstractPath; recursive=false, exist_ok=false, overwrite=false)
    if exists(src)
        if exists(dest) && exist_ok && overwrite
            remove(dest, recursive=true)
        end

        if !exists(dest)
            # If the destination is has missing parents
            # and parents is true then we'll create the necessary parent
            # directories.
            if hasparent(dest) && recursive
                mkdir(parent(dest); recursive=recursive, exist_ok=true)
            end

            mv(string(src), string(dest))
        elseif !exist_ok
            error("$dest already exists.")
        end
    else
        error("$src is not a valid path")
    end
end

function Base.cp(src::AbstractPath, dest::AbstractPath; remove_destination::Bool=false, follow_symlinks::Bool=false)
    cp(string(src), string(dest); remove_destination=remove_destination, follow_symlinks=follow_symlinks)
end

remove(path::AbstractPath; recursive=false) = rm(string(path); recursive=recursive)
Base.touch(path::AbstractPath) = touch(string(path))

tmpname() = Path(tempname())
tmpdir() = Path(tempdir())

function mktmp(parent::AbstractPath=Path(tempdir()))
    path, io = mktemp(string(parent))
    return Path(path), io
end

mktmpdir(parent::AbstractPath=tmpdir()) = Path(mktempdir(string(parent)))

function mktmp(fn::Function, parent=tmpdir())
    (tmp_path, tmp_io) = mktmp(parent)
    try
        fn(tmp_path, tmp_io)
    finally
        close(tmp_io)
        remove(tmp_path)
    end
end

function mktmpdir(fn::Function, parent=tmpdir())
    tmpdir = mktmpdir(parent)
    try
        fn(tmpdir)
    finally
        remove(tmpdir, recursive=true)
    end
end

function Base.chown(path::AbstractPath, user::AbstractString, group::AbstractString; recursive=false)
    @static if is_unix()
        chown_cmd = String["chown"]
        if recursive
            push!(chown_cmd, "-R")
        end
        append!(chown_cmd, String["$(user):$(group)", string(path)])

        run(Cmd(chown_cmd))
    else
        error("chown is currently not supported on windows.")
    end
end

function Base.chmod(path::AbstractPath, mode::Mode; recursive=false)
    chmod_path = string(path)
    chmod_mode = raw(mode)

    if isdir(path) && recursive
        for p in glob(path, "*")
            chmod(chmod_path, chmod_mode; recursive=recursive)
        end
    end

    chmod(string(path), raw(mode))
end

function Base.chmod(path::AbstractPath; user::UInt8=0o0, group::UInt8=0o0, other::UInt8=0o0, recursive=false)
    chmod(path, Mode(user=user, group=group, other=other); recursive=recursive)
end

function Base.chmod(path::AbstractPath, symbolic_mode::AbstractString; recursive=false)
    who_char = ['u', 'g', 'o']
    who_actual = [:USER, :GROUP, :OTHER]
    act_char = ['+', '-', '=']
    perm_char = ['r', 'w', 'x']
    perm_actual = [READ, WRITE, EXEC]
    unsupported_perm_char = ['s', 't', 'X', 'u', 'g', 'o']

    tokenized = split(symbolic_mode, act_char)
    if length(tokenized) != 2
        error("Invalid symbolic string expected format <who><action><perm>.")
    end

    who_raw = tokenized[1]
    perm_raw = tokenized[2]

    who = [:ALL]
    perm = 0o0

    for i in 1:3
        if who_char[i] in who_raw
            push!(who, who_actual[i])
        end
    end

    for i in 1:3
        if perm_char[i] in perm_raw
            perm += perm_actual[i]
        end
    end

    for x in unsupported_perm_char
        if x in perm_raw
            error("$x is currently an unsupported permission char for symbolic modes.")
        end
    end

    m = mode(path)
    new_m = Mode(perm, who...)

    if '+' in symbolic_mode
        chmod(path, m + new_m; recursive=recursive)
    elseif '-' in symbolic_mode
        chmod(path, m - new_m; recursive=recursive)
    elseif '=' in symbolic_mode
        chmod(path, new_m; recursive=recursive)
    else
        error("No valid action found in symbolic mode string.")
    end
end

Base.read(path::AbstractPath) = open(readstring, string(path))

function Base.write(path::AbstractPath, content::AbstractString)
    open(string(path), "w") do f
        write(f, content)
    end
end
