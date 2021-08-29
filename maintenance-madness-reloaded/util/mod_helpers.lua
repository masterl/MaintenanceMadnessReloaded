local constants = require( 'constants' )
local ModInfo = require( 'util.ModInfo' )

local this = ModInfo:new( { name = constants.mod_name } )
local base = ModInfo:new( { name = 'base', sounds_folder = 'sound' } )
local core = ModInfo:new( { name = 'core', sounds_folder = 'sound' } )

-- LuaFormatter off
return {
    this_mod = this,
    base_mod = base,
    core_mod = core
}
-- LuaFormatter on
