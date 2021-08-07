local constants = require( 'util.constants' )
local gfx_folder_path = constants.mod_folder .. '/graphics'

local icon_folder_path = gfx_folder_path .. '/icons'

local function path_join( base, filename )
    return base .. '/' .. filename
end

local function get_icon_path( filename )
    return path_join( icon_folder_path, filename )
end

return {
    get_icon_path = get_icon_path,
}
