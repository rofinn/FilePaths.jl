macro compat(ex)
    new_ex = compat_exp(deepcopy(ex))

    return quote
        $ex
        $new_ex
    end |> esc
end

function compat_exp(ex::Expr)
    fdef = splitdef(ex)
    args = Symbol[]
    kwargs = Expr[]
    convert_vars = Symbol[]
    body = Expr[]
    params = Symbol[]

    if haskey(fdef, :whereparams)
        # Identify any where params that are a subtype of AbstractPath
        for (i, p) in enumerate(fdef[:whereparams])
            # If the param is a subtype of AbstracPath
            # then we store the lookup symbol in the params array
            if _ispath(p.args[2])
                p.args[2] = :(Union{AbstractString, $(p.args[2])})
                push!(params, p.args[1])
            end
        end
    end

    if haskey(fdef, :args)
        # Identify any args and kwargs that need to modified
        for (i, a) in enumerate(fdef[:args])
            if isa(a, Expr)
                if (a.head) === :kw
                    T = a.args[1]
                    if T.args[2] in params
                        push!(convert_vars, T.args[1])
                    elseif _ispath(T.args[2])
                        T.args[2] = :(Union{AbstractString, $(T.args[2])})
                        push!(convert_vars, T.args[1])
                    end

                    push!(args, T.args[1])
                else
                    if a.args[2] in params
                        push!(convert_vars, a.args[1])
                    elseif _ispath(a.args[2])
                        a.args[2] = :(Union{AbstractString, $(a.args[2])})
                        push!(convert_vars, a.args[1])
                    end

                    push!(args, a.args[1])
                end
            elseif isa(a, Symbol)
                push!(args, a)
            else
                throw(ArgumentError("Uknown argument type $a"))
            end
        end
    end

    if haskey(fdef, :kwargs)
        for (i, k) in enumerate(fdef[:kwargs])
            T = k.args[1]
            if T.args[2] in params
                push!(convert_vars, T.args[1])
            elseif _ispath(T.args[2])
                T.args[2] = :(Union{AbstractString, $(T.args[2])})
                push!(convert_vars, T.args[1])
            end
            push!(kwargs, :($(T.args[1])=$(T.args[1])))
        end
    end

    for v in convert_vars
        # push!(body, :(println($v)))
        push!(body, :($v = Path($v)))
        # push!(body, :(println($v)))
    end

    push!(body, :(result = $(fdef[:name])($(args...); $(kwargs...))))

    if haskey(fdef, :rtype) && (fdef[:rtype] in params || _ispath(fdef[:rtype]))
        push!(body, :(result = string(result)))
        # push!(body, :(println(typeof(result))))
        fdef[:rtype] = :String
    end

    push!(body, :(return result))

    fdef[:body].args = body

    return MacroTools.combinedef(fdef)
end

function _ispath(t::Symbol)
    T = eval(t)
    return T <: AbstractPath
end
