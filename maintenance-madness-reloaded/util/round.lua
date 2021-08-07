local floor = math.floor
local ceil = math.ceil

local function sign( value )
    return (value >= 0 and 1) or -1
end

return function( input, precision )
    precision = precision or 1

    local s = sign( input )

    if s == 1 then
        return (floor( input / precision + sign( input ) * 0.5 ) * precision)
    else
        return (ceil( input / precision + sign( input ) * 0.5 ) * precision)
    end
end
