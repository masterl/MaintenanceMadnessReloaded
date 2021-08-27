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

    if obj.gfx_folder then
        obj.gfx_path = path_join( obj.folder, obj.gfx_folder )
    else
        obj.gfx_path = path_join( obj.folder, 'graphics' )
    end

    if obj.sounds_folder then
        obj.sounds_path = path_join( obj.folder, obj.sounds_folder )
    else
        obj.sounds_path = path_join( obj.folder, 'sounds' )
    end

    return obj
end

function ModInfo:get_graphics_path( ... )
    return path_join( self.gfx_path, ... )
end

function ModInfo:get_sounds_path( ... )
    return path_join( self.sounds_path, ... )
end

function ModInfo:add_prefix( str )
    return self.prefix .. str
end

return ModInfo
