local floor = math.floor

-- constants
-- ? Do we need to export these?
local SECONDS_PER_HOUR = 3600
local TICKS_PER_SECOND = 60

---Convert time from hours to seconds.
---@param time_in_hours number
---@return number #the result of math.floor on the converted value
local function hours_to_seconds( time_in_hours )
    return floor( time_in_hours * SECONDS_PER_HOUR )
end

---Convert a time in seconds to the corresponding amount of game ticks.
---@param time_in_seconds number
---@return number
local function seconds_to_ticks( time_in_seconds )
    return time_in_seconds * TICKS_PER_SECOND
end

return {
    hours_to_seconds = hours_to_seconds,
    seconds_to_ticks = seconds_to_ticks
}
