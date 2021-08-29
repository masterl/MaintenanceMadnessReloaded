local letters = 'abcdefghijklmnopqrstuvwxyza'

local function next_letter( previous_letter )
    return letters:match( previous_letter .. '(.)' )
end

local function next_simple_order( previous_letter, previous_number )
    local result = {
        letter = previous_letter,
        number = previous_number + 1,
        as_string = ''
    }

    if result.number > 8 then
        result.number = 1
        result.letter = next_letter( previous_letter )
    end

    result.as_string = result.letter .. result.number

    return result
end

return { next_simple_order = next_simple_order }
