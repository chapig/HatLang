function scan_string(delim, chars)

    chars = chars[delim:end]
    isastring = findfirst('"', chars)
    isachar = findfirst('\'', chars)

    if isastring ≢ nothing
        string_or_char = ""
        next = findnext('"', chars, isastring+1)
        if next ≢ nothing
            string_or_char *= chars[isastring:next]
            return [string_or_char, (isastring, next)]
        else 
            return nothing
        end
    end

    if isachar ≢ nothing
        string_or_char = ""
        next = findnext('\'', chars, isachar+1)
        if next ≢ nothing
            string_or_char *= chars[isachar:next]
            return [string_or_char, (isachar, next)]
        else 
            return nothing
        end
    end
    
end

function lex(file::AbstractString)

    lexr = []
    error = false

    open(file, "r") do io
        
        chars = read(io, String)
        nchars = range(1, length=length(chars)) #Number of chars.
        indexchar = 1

        while iterate(chars, indexchar) !== nothing
            if isspace(chars[indexchar])
                indexchar += 1
                continue
            elseif isletter(chars[indexchar])
                push!(lexr, chars[indexchar])
                indexchar += 1
                continue
            elseif ispunct(chars[indexchar]) && chars[indexchar] === ';' || chars[indexchar] === '.'
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
                    indexchar += length(string_or_char[2][1]:string_or_char[2][2])
                    continue
                else
                    error = true
                    println("String or char is incomplete.")
                    break
                end

            else
                error = true
                println("Unexpected character: '$(chars[indexchar])'.")
                break
            end
        end

        if error println("An error has occurred, check grammar.") 
        else 
            println("Last index of string scanned was: $indexchar of $(length(chars))")
            return lexr 
        end

    end

end
