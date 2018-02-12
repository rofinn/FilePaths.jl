@static if is_apple()
    immutable Cpasswd
        pw_name::Cstring
        pw_passwd::Cstring
        pw_uid::Cint
        pw_gid::Cint
        pw_change::Cint
        pw_class::Cstring
        pw_gecos::Cstring
        pw_dir::Cstring
        pw_shell::Cstring
        pw_expire::Cint
        pw_fields::Cint
    end
elseif is_linux()
    immutable Cpasswd
       pw_name::Cstring
       pw_passwd::Cstring
       pw_uid::Cint
       pw_gid::Cint
       pw_gecos::Cstring
       pw_dir::Cstring
       pw_shell::Cstring
    end
else
    immutable Cpasswd
        pw_name::Cstring
        pw_uid::Cint
        pw_gid::Cint
        pw_dir::Cstring
        pw_shell::Cstring
    end

    Cpasswd() = Cpasswd(pointer("NA"), 0, 0, pointer("NA"), pointer("NA"))
end

immutable Cgroup
    gr_name::Cstring
    gr_passwd::Cstring
    gr_gid::Cint
end

Cgroup() = Cgroup(pointer("NA"), pointer("NA"), 0)

immutable User
    name::String
    uid::UInt64
    gid::UInt64
    dir::String
    shell::String

    function User(ps::Cpasswd)
        new(
            unsafe_string(ps.pw_name),
            UInt64(ps.pw_uid),
            UInt64(ps.pw_gid),
            unsafe_string(ps.pw_dir),
            unsafe_string(ps.pw_shell)
        )
    end
end

User(passwd::Ptr{Cpasswd}) = User(unsafe_load(passwd))

function Base.show(io::IO, user::User)
    print(io, "$(user.uid) ($(user.name))")
end

function User(name::String)
    ps = @static if is_unix()
        ccall((:getpwnam, "libc"), Ptr{Cpasswd}, (Ptr{UInt8},), name)
    else
        Cpasswd()
    end

    User(ps)
end

function User(uid::UInt)
    ps = @static if is_unix()
        ccall((:getpwuid, "libc"), Ptr{Cpasswd}, (UInt64,), uid)
    else
        Cpasswd()
    end

    User(ps)
end

function User()
    uid = @static is_unix() ? ccall((:geteuid, "libc"), Cint, ()) : 0
    User(UInt64(uid))
end

immutable Group
    name::String
    gid::UInt64

    Group(gr::Cgroup) = new(unsafe_string(gr.gr_name), UInt64(gr.gr_gid))
end

Group(group::Ptr{Cgroup}) = Group(unsafe_load(group))

function Base.show(io::IO, group::Group)
    print(io, "$(group.gid) ($(group.name))")
end

function Group(name::String)
    ps = @static if is_unix()
        ccall((:getgrnam, "libc"), Ptr{Cgroup}, (Ptr{UInt8},), name)
    else
        Cgroup()
    end

    Group(ps)
end

function Group(gid::UInt64)
    gr = @static if is_unix()
        ccall((:getgrgid, "libc"), Ptr{Cgroup}, (UInt64,), gid)
    else
        Cgroup()
    end

    Group(gr)
end

function Group()
    gid = @static is_unix() ? ccall((:getegid, "libc"), Cint, ()) : 0
    Group(UInt64(gid))
end
