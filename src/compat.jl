"""
    FilePaths.@compat fn

Generates a compatibility method for handling paths as strings based on the function
definition passed in.

Wrapper method properties:

- Any arguments that accepted `P <: AbstractPath` will accept `Union{String, P}`
- All string path inputs will be converted to path types
- If a path return type was specified then the path result will be converted back to a string.

# Examples

```
julia> using FilePathsBase; using FilePathsBase: /; using FilePaths

julia> FilePaths.@compat function myrelative(x::AbstractPath, y::AbstractPath)
           return relative(x, y)
       end
myrelative (generic function with 2 methods)

julia> FilePaths.@compat function myjoin(x::P, y::String)::P where P <: AbstractPath
           return x / y
       end
myjoin (generic function with 2 methods)

julia> myrelative(cwd(), home())
p"repos/FilePaths.jl"

julia> myrelative(pwd(), homedir())
p"repos/FilePaths.jl"

julia> myjoin(parent(cwd()), "FilePaths.jl")
p"/Users/rory/repos/FilePaths.jl"

julia> myjoin("/Users/rory/repos", "FilePaths.jl")
"/Users/rory/repos/FilePaths.jl"
```
"""
macro compat(ex)
    mod::Module = QuoteNode(__module__).value
    new_ex = compat_exp(mod, deepcopy(ex))

    return quote
        $ex
        $new_ex
    end |> esc
end

function compat_exp(mod::Module, ex::Expr)
    fdef = splitdef(ex)
    args = Symbol[]
    kwargs = Expr[]
    convert_vars = Symbol[]
    body = Expr[]
    params = Symbol[]

    # A function that identifies args that need to be converted
    function parse_arg(a)
        if a.args[2] in params
            push!(convert_vars, a.args[1])
        elseif _ispath(mod, a.args[2])
            # Modify the arg type declaration from P<:AbstractPath to Union{String, P}
            # NOTE: If the variable is parameterized then we should have already updated the
            # parameterized type in the where clause
            a.args[2] = :(Union{AbstractString, $(a.args[2])})
            push!(convert_vars, a.args[1])
        end
    end

    # Identify any where params that are a subtype of AbstractPath
    if haskey(fdef, :whereparams)
        for (i, p) in enumerate(fdef[:whereparams])
            # If the param is a subtype of AbstracPath
            # then we store the lookup symbol in the params array
            if _ispath(mod, p.args[2])
                # Modify parameterized where clause from P<:AbstractPath to Union{String, P}
                p.args[2] = :(Union{AbstractString, $(p.args[2])})
                push!(params, p.args[1])
            end
        end
    end

    # Identify args that need to be converted
    if haskey(fdef, :args)
        for (i, a) in enumerate(fdef[:args])
            # An arg can be an expression or a symbol (no type information)
            if isa(a, Expr)
                if (a.head) === :kw
                    # Optional arguments show up as `kw` and need to be parsed as such
                    T = a.args[1]
                    parse_arg(T)
                    push!(args, T.args[1])
                else
                    parse_arg(a)
                    push!(args, a.args[1])
                end
            elseif isa(a, Symbol)
                push!(args, a)
            else
                throw(ArgumentError("Uknown argument type $a"))
            end
        end
    end

    # Identify kwargs that need to be converted
    if haskey(fdef, :kwargs)
        for (i, k) in enumerate(fdef[:kwargs])
            T = k.args[1]
            parse_arg(T)
            # Rewrite the kwarg expression to pass them along
            push!(kwargs, :($(T.args[1])=$(T.args[1])))
        end
    end

    # Insert our convert statements for the appropriate variables
    for v in convert_vars
        push!(body, :($v = Path($v)))
    end

    # Push our paths method call into the body
    push!(body, :(result = $(fdef[:name])($(args...); $(kwargs...))))

    # If we have a return type and it's a path then convert the result back to a string
    if haskey(fdef, :rtype) && (fdef[:rtype] in params || _ispath(mod, fdef[:rtype]))
        push!(body, :(result = string(result)))
        # Set the return type to String to avoid an incorrect conversion back to a path
        fdef[:rtype] = :String
    end

    # Finally, insert a return statement
    push!(body, :(return result))

    # Update our definition with the new body
    fdef[:body].args = body

    # Combine the modified definition back into an expression
    return MacroTools.combinedef(fdef)
end

function _ispath(mod::Module, t::Symbol)
    T = getfield(mod, t)
    return T <: AbstractPath
end
