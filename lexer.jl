TEMP_SYMBOL = ""

function allowed(c)
    if contains(string(c), r"[_a-zA-Z0-9]") || c ≡ '_' || c ≡'(' || c ≡ ')'
        return true
    else
        return false
    end
end

function isasymbol(TEMP_SYMBOL, chars, indexchar)
    
    global TEMP_SYMBOL

    for i in 1:length(chars[indexchar:end])
        if !isspace(chars[i]) || chars[i] ≡ '=' && allowed(chars[i])
            TEMP_SYMBOL *= chars[i]
        else
            return [true, TEMP_SYMBOL, i]
            break
        end
    end

    return [false, false, false]

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

    global TEMP_SYMBOL
    lexr = []
    error = false

    open(file, "r") do io
        
        chars = read(io, String)
        indexchar = 1
        temp_symbol = ""

        while iterate(chars, indexchar) !== nothing

            global TEMP_SYMBOL

            if isspace(chars[indexchar])

                indexchar += 1
                continue

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

            else
                simbolo = isasymbol(temp_symbol, chars, indexchar)
                println(simbolo)
                if simbolo[1]
                    push!(lexr, simbolo[2])
                    indexchar += simbolo[3]
                    continue
                else
                    error = true
                    break
                end
            end
        end

        if error
            println("Last index of string scanned was: $indexchar of $(length(chars))")
            println("An error has occurred, check grammar.")
            println("Chars and unfinished lexicon will be returned (Vector) in order to be debugged.")
            return [chars, lexr]
        else
            println("Símbolo temporal: $TEMP_SYMBOL")
            println("Last index of string scanned was: $indexchar of $(length(chars))")
            return lexr 
        end
    end
end
