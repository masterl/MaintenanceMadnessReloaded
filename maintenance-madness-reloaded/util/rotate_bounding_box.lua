---Calculates a rotated bounding box.
---@param bounding_box table
---@return table
local function rotate_bounding_box( bounding_box )
    local point1 = bounding_box.left_top or bounding_box[1]
    local point2 = bounding_box.right_bottom or bounding_box[2]

    return {
        { point1.y or point1[2], point1.x or point1[1] },
        { point2.y or point2[2], point2.x or point2[1] }
    }
end

return rotate_bounding_box
