local floor = math.floor

-- constants
-- ? Do we need to export these?
local SECONDS_PER_HOUR = 3600
local TICKS_PER_SECOND = 60

local time = {}

---Convert time from hours to seconds.
---@param time_in_hours number
---@return number #the result of math.floor on the converted value
function time.hours_to_seconds( time_in_hours )
    return floor( time_in_hours * SECONDS_PER_HOUR )
end

---Convert a time in seconds to the corresponding amount of game ticks.
---@param time_in_seconds number
---@return number
function time.seconds_to_ticks( time_in_seconds )
    return time_in_seconds * TICKS_PER_SECOND
end

return time
