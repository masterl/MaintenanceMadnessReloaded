local path_join = require( 'util.path_join' )

local ModInfo = {}

function ModInfo:new( obj )

    if not obj or not obj.name or type( obj.name ) ~= 'string' then
        error(
            'You should provide the mod name. (e.g. ModInfo:new({name = \'maintenance-madness-reloaded\'}))' )
    end

    setmetatable( obj, self )
    self.__index = self

    obj.prefix = obj.name .. '-'
    obj.folder = '__' .. obj.name .. '__'

    obj.gfx_path = path_join( obj.folder, 'graphics' )
    obj.gfx_icons_path = path_join( obj.gfx_path, 'icons' )
    obj.gfx_entities_path = path_join( obj.gfx_path, 'entity' )
    obj.gfx_technologies_path = path_join( obj.gfx_path, 'technology' )
    obj.sounds_path = path_join( obj.folder, 'sound' )

    return obj
end

function ModInfo:get_path_to_graphics( ... )
    return path_join( self.gfx_path, ... )
end

function ModInfo:get_path_to_sounds( ... )
    return path_join( self.sounds_path, ... )
end

return ModInfo
