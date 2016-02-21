@osx_only begin
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
end

@linux_only begin
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
