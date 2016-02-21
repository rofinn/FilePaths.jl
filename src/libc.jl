@osx_only immutable Cpasswd
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

@linux_only immutable Cpasswd
   pw_name::Cstring
   pw_passwd::Cstring
   pw_uid::Cint
   pw_gid::Cint
   pw_gecos::Cstring
   pw_dir::Cstring
   pw_shell::Cstring
end

@unix_only immutable Cgroup
    gr_name::Cstring
    gr_passwd::Cstring
    gr_gid::Cint
    gr_mem::Ptr{Cstring}
end

immutable User
    name::ASCIIString
    uid::UInt64
    gid::UInt64
    dir::ASCIIString
    shell::ASCIIString

    function User(passwd::Ptr{Cpasswd})
        ps = unsafe_load(passwd)

        new(
            pointer_to_string(ps.pw_name),
            UInt64(ps.pw_uid),
            UInt64(ps.pw_gid),
            pointer_to_string(ps.pw_dir),
            pointer_to_string(ps.pw_shell)
        )
    end
end

function Base.show(io::IO, user::User)
    print(io, "$(user.uid) ($(user.name))")
end

function User(name::ASCIIString)
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
    name::ASCIIString
    gid::UInt64
    members::Array{ASCIIString}

    function Group(group::Ptr{Cgroup})
        gr = unsafe_load(group)

        new(
            pointer_to_string(gr.gr_name),
            UInt64(gr.gr_gid),
            ASCIIString[
                pointer_to_string(m)
                for m in pointer_to_array(gr.gr_mem, 1)
            ]
        )
    end
end

function Base.show(io::IO, group::Group)
    print(io, "$(group.gid) ($(group.name))")
end

function Group(name::ASCIIString)
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

