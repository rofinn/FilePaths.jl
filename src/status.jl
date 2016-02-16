using Base.Dates
using Humanize

immutable Status
    device::UInt64
    inode::UInt64
    mode::Mode
    nlink::Int64
    uid::UInt64
    gid::UInt64
    rdev::UInt64
    size::Int64
    blksize::Int64
    blocks::Int64
    mtime::DateTime
    ctime::DateTime

    function Status(s::StatStruct)
        new(
            s.device,
            s.inode,
            Mode(s.mode),
            s.nlink,
            s.uid,
            s.gid,
            s.rdev,
            s.size,
            s.blksize,
            s.blocks,
            unix2datetime(s.mtime),
            unix2datetime(s.ctime)
        )
    end
end

function Base.show(io::IO, s::Status)
    output = string("Status(\n",
        "  device = $(s.device),\n",
        "  inode = $(s.inode),\n",
        "  mode = $(s.mode),\n",
        "  nlink = $(s.nlink),\n",
        "  uid = $(s.uid),\n",
        "  gid = $(s.gid),\n",
        "  rdev = $(s.rdev),\n",
        "  size = $(s.size) ($(datasize(s.size, style=:gnu))),\n",
        "  blksize = $(s.blksize) ($(datasize(s.blksize, style=:gnu))),\n",
        "  blocks = $(s.blocks),\n",
        "  mtime = $(s.mtime),\n",
        "  ctime = $(s.ctime),\n)"
    )
    print(io, output)
end
