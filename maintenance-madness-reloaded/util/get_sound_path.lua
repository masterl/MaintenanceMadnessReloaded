local constants = require( 'util.constants' )
local mod_folder = constants.mod_folder

return function( filename )
    return mod_folder .. '/sounds/' .. filename
end
