local function get_ingredient_amount( ingredient_data )
    if ingredient_data.amount ~= nil then
        return tonumber( ingredient_data.amount )
    end

    for _, element in pairs( ingredient_data ) do
        local amount = tonumber( element )

        if amount ~= nil then
            return amount
        end
    end

end

return get_ingredient_amount
