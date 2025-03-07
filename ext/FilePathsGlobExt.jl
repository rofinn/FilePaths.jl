module FilePathsGlobExt

using Glob
using Glob: GlobMatch
using FilePaths

Base.readdir(pattern::GlobMatch, prefix::AbstractPath) = glob(pattern, prefix)

function Glob.glob(pattern, prefix::T) where T<:AbstractPath
    return [parse(T, m) for m in glob(pattern, string(prefix))]
end

end
