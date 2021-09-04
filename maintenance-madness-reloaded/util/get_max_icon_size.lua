local function get_max_icon_size( item, default_size )
    local max_icon_size = default_size or item.icon_size or 0

    if item.icons ~= nil then
        for _, layer in pairs( item.icons ) do
            if layer.icon_size and layer.icon_size > max_icon_size then
                max_icon_size = layer.icon_size
            end
        end
    else
        max_icon_size = item.icon_size
    end

    return max_icon_size
end

return get_max_icon_size
