local constants = require( 'util.constants' )
local mod_folder = constants.mod_folder

return function( str )
    return mod_folder .. str
end
