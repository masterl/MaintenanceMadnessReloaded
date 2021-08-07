local constants = require( 'util.constants' )
local mod_prefix = constants.mod_prefix

return function( str )
    return mod_prefix .. str
end
