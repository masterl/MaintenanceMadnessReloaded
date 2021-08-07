local constants = require( 'util.constants' )
local gfx_folder_path = constants.mod_folder .. '/graphics'

local icon_folder_path = gfx_folder_path .. '/icons'
local entities_folder_path = gfx_folder_path .. '/entities'
local tech_folder_path = gfx_folder_path .. '/tech'

local function path_join( base, filename )
    return base .. '/' .. filename
end

local function get_icon_path( filename )
    return path_join( icon_folder_path, filename )
end

local function get_entity_path( filename )
    return path_join( entities_folder_path, filename )
end

local function get_tech_path( filename )
    return path_join( tech_folder_path, filename )
end

return {
    get_icon_path = get_icon_path,
    get_entity_path = get_entity_path,
    get_tech_path = get_tech_path
}
