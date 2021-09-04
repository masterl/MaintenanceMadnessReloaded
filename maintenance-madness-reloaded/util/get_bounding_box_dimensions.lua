---Get dimensions from bounding box points.
---@param bounding_box table
---@return table
local function get_bounding_box_dimensions( bounding_box )
    local point1 = bounding_box.left_top or bounding_box[1]
    local point2 = bounding_box.right_bottom or bounding_box[2]

    local width = (point2.x or point2[1]) - (point1.x or point1[1])
    local height = (point2.y or point2[2]) - (point1.y or point1[2])

    -- LuaFormatter off
    return {
        width = width,
        height = height
    }
    -- LuaFormatter on
end

return get_bounding_box_dimensions
