local ModInfo = require( 'util.ModInfo' )

local this = ModInfo:new( { name = 'maintenance-madness-reloaded' } )
local base = ModInfo:new( { name = 'base', sounds_folder = 'sound' } )
local core = ModInfo:new( { name = 'core', sounds_folder = 'sound' } )

-- LuaFormatter off
return {
    this_mod = this,
    base_mod = base,
    core_mod = core
}
-- LuaFormatter on
