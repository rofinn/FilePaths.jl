module FilePathsURIParserExt

using URIParser
using FilePaths

function URIParser.URI(p::AbstractPath; query="", fragment="")
    if isempty(p.root)
        throw(ArgumentError("$p is not an absolute path"))
    end

    b = IOBuffer()
    print(b, "file://")

    if !isempty(p.drive)
        print(b, "/")
        print(b, p.drive)
    end

    for s in p.segments
        print(b, "/")
        print(b, URIParser.escape(s))
    end

    return URIParser.URI(URIParser.URI(String(take!(b))); query=query, fragment=fragment)
end

end
