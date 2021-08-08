local path_join = require( 'util.path_join' )

local base_mod_path = '__base__'
local sounds_path = path_join( base_mod_path, 'sounds' )

local function get_sound_path( filename )
    return path_join( sounds_path, filename )
end

return { get_sound_path = get_sound_path }
