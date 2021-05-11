function allowed(c)
    if contains(string(c), r"[_a-zA-Z0-9]") || c === '_' || c === '(' || c === ')'
        return true
    else
        return false
    end

end

function isasymbol()
end

function is_a_string_or_char(chars, isachar, isastring)
    if isachar ≡ nothing && isastring ≢ nothing
        string_or_char = ""
        next = findnext('"', chars, isastring+1)
        if next ≢ nothing
            string_or_char *= chars[isastring:next]
            return [string_or_char, length(string_or_char)]
        else 
            return nothing
        end
    elseif isastring ≡ nothing && isachar ≢ nothing
        string_or_char = ""
        next = findnext('\'', chars, isachar+1)
        if next ≢ nothing
            string_or_char *= chars[isachar:next]
            return [string_or_char, length(string_or_char)]
        else 
            return nothing
        end
    elseif isastring ≢ nothing && isachar ≢ nothing
        if isastring < isachar
            string_or_char = ""
            next = findnext('"', chars, isastring+1)
            if next ≢ nothing
                string_or_char *= chars[isastring:next]
                return [string_or_char, length(string_or_char)]
            else 
                return nothing
            end
        else
            string_or_char = ""
            next = findnext('\'', chars, isachar+1)
            if next ≢ nothing
                string_or_char *= chars[isachar:next]
                return [string_or_char, length(string_or_char)]
            else 
                return nothing
            end
        end
    end
end

function scan_string(delim, chars)

    chars = chars[delim:end]
    isastring = findfirst('"', chars)
    isachar = findfirst('\'', chars)
    return is_a_string_or_char(chars, isachar, isastring)

end

function lex(file::AbstractString)

    index_temp_symbol = 0
    temp_symbol = ""
    lexr = []
    error = false

    open(file, "r") do io
        
        chars = read(io, String)
        nchars = range(1, length=length(chars)) #Number of chars.
        indexchar = 1

        while iterate(chars, indexchar) !== nothing

            if isspace(chars[indexchar])

                if index_temp_symbol >= 1
                    @warn "first temp symbol init"
                    push!(lexr, temp_symbol)
                    index_temp_symbol = 0
                    temp_symbol = ""
                end
                
                indexchar += 1
                continue

            elseif isletter(chars[indexchar]) || chars[indexchar] === '_' || chars[indexchar] === '(' || chars[indexchar] === ')'


                if !isspace(chars[indexchar]) && allowed(chars[indexchar])
                    temp_symbol *= chars[indexchar]
                    index_temp_symbol += 1
                    indexchar += 1  
                    continue
                else
                    println("Space detected")
                    indexchar += 1  
                    continue
                end

            elseif ispunct(chars[indexchar]) && chars[indexchar] ≡ ';' || chars[indexchar] ≡ '.'
                push!(lexr, chars[indexchar])
                indexchar += 1
                continue
            elseif isnumeric(chars[indexchar])
                push!(lexr, chars[indexchar])
                indexchar += 1
                continue
            elseif chars[indexchar] in "(),;=:"
                push!(lexr, chars[indexchar])
                indexchar += 1
                continue
            elseif chars[indexchar] in "+-*/"
                push!(lexr, chars[indexchar])
                indexchar += 1
                continue
            elseif chars[indexchar] in "'" || chars[indexchar] in '"'
                string_or_char = scan_string(indexchar, chars)
                if string_or_char ≢ nothing
                    push!(lexr, string_or_char[1])
                    indexchar += string_or_char[2]
                    continue
                else
                    error = true
                    println("String or char is incomplete.")
                    break
                end

            elseif index_temp_symbol >= 1
                @warn "second temp symbol init"
                push!(lexr, temp_symbol)
                index_temp_symbol = 0
                temp_symbol = ""

            else
                error = true
                println("Unexpected character: '$(chars[indexchar])'.")
                break
            end
        end

        if error
            println("Last index of string scanned was: $indexchar of $(length(chars))")
            println("An error has occurred, check grammar.")
            println("Chars and unfinished lexicon will be returned (Vector) in order to be debugged.")
            return [chars, lexr]
        else
            println("Last index of string scanned was: $indexchar of $(length(chars))")
            return lexr 
        end

    end
end
