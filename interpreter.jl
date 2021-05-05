hatsymbols = [ :hatprint, :hatint, :hatfloat, :hatstr ]

function run_input()
    open("main.hat", "r") do io
        input_file = read(io, String) |> splitting |> init |> performline |> evalline
    end
end

function splitting(hatStringInit::String) 
    return split(hatStringInit, "\n")
end

function init(hatArrayInit::Array)

    tasks = []

    for line in 1:length(hatArrayInit)
        push!(tasks, [hatArrayInit[line]])
    end

    return tasks
end

function performline(tasks::Array)
    
    analisis = []
    for number_of_task in 1:length(tasks)
        for line in tasks[number_of_task]
            if split(line)[1] == "print" push!(analisis, [:hatprint, split(line)[2:end]])

            elseif isint(line) 
                line = replace(line, "int::"=>"")
                push!(analisis, [:hatint, split(line)[1:end]])
            elseif isfloat(line)
                line = replace(line, "float::"=>"")
                push!(analisis, [:hatfloat, split(line)[1:end]])
            elseif isstr(line)
                line = replace(line, "str::"=>"")
                push!(analisis, [:hatstr, split(line)[1:end]])
            end
        end
    end
    return analisis
end

function evalline(hatArrayDone::Array)
    for each in hatArrayDone
        if each[1] isa Symbol && each[1] in hatsymbols 
            if each[1] === :hatprint hatprint(each) end
            if each[1] === :hatint hatint(each) end
            if each[1] === :hatfloat hatfloat(each) end
            if each[1] === :hatstr hatstr(each) end
        end
    end

end

function hatint(item)
    if item[2][2] == "="
        name_of_variable = item[2][1] 
        value_of_variable = tryparse(Int, item[2][3]); 
        if value_of_variable !== nothing          
            expr =  "$name_of_variable = $value_of_variable"
            eval(Meta.parse(expr))
        else
            @error "$(item[2][3]) is not Float"
        end
    end
end

function hatfloat(item)
    if item[2][2] == "="
        name_of_variable = item[2][1] 
        value_of_variable = tryparse(Float64, item[2][3]); 
        if value_of_variable !== nothing          
            expr =  "$name_of_variable = $value_of_variable"
            eval(Meta.parse(expr))
        end
    end
end

function hatstr(item)
    if item[2][2] == "="
        name_of_variable = item[2][1] 
        value_of_variable = join(item[2][3:end], " ")   
        expr =  "$name_of_variable = $value_of_variable"
        eval(Meta.parse(expr))
    end
end

function hatprint(item)
    item = join(item[2], " "); item = [i for i in item]
    if item[1] == '\"' && item[end] == '\"'
        print(replace(join(item), "\""=>""))
    else
        item = join(item)
        try
            expr = "print($item)"
            eval(Meta.parse(expr))
        catch
            @error "$item has not been declared."
        end
    end

end


#Declaration of variables.
function isint(line)
    if contains(line, "int::")
        return true
    end
    return false
end

function isfloat(line)
    if contains(line, "float::")
        return true
    end
    return false
end

function isstr(line)
    if contains(line, "str::")
        return true
    end
    return false
end

a = run_input()
