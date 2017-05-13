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
end

immutable Cgroup
    gr_name::Cstring
    gr_passwd::Cstring
    gr_gid::Cint
end

immutable User
    name::String
    uid::UInt64
    gid::UInt64
    dir::String
    shell::String

    function User(passwd::Ptr{Cpasswd})
        ps = unsafe_load(passwd)

        new(
            unsafe_wrap(String, ps.pw_name),
            UInt64(ps.pw_uid),
            UInt64(ps.pw_gid),
            unsafe_wrap(String, ps.pw_dir),
            unsafe_wrap(String, ps.pw_shell)
        )
    end
end

function Base.show(io::IO, user::User)
    print(io, "$(user.uid) ($(user.name))")
end

function User(name::String)
    ps = ccall((:getpwnam, "libc"), Ptr{Cpasswd}, (Ptr{UInt8},), name)
    User(ps)
end

function User(uid::UInt64)
    ps = ccall((:getpwuid, "libc"), Ptr{Cpasswd}, (UInt64,), uid)
    User(ps)
end

function User()
    uid = ccall((:geteuid, "libc"), Cint, ())
    User(UInt64(uid))
end

immutable Group
    name::String
    gid::UInt64

    function Group(group::Ptr{Cgroup})
        gr = unsafe_load(group)

        new(
            unsafe_wrap(String, gr.gr_name),
            UInt64(gr.gr_gid)
        )
    end
end

function Base.show(io::IO, group::Group)
    print(io, "$(group.gid) ($(group.name))")
end

function Group(name::String)
    ps = ccall((:getgrnam, "libc"), Ptr{Cgroup}, (Ptr{UInt8},), name)
    Group(ps)
end

function Group(gid::UInt64)
    gr = ccall((:getgrgid, "libc"), Ptr{Cgroup}, (UInt64,), gid)
    Group(gr)
end

function Group()
    gid = ccall((:getegid, "libc"), Cint, ())
    Group(UInt64(gid))
end
