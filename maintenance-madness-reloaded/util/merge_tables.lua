---Merges two tables together.
---@param first table
---@param second table
---@return nil #No return, the first table is directly altered
local function merge_tables( first, second )
    for k, v in pairs( second ) do
        first[k] = v
    end
end

return merge_tables
