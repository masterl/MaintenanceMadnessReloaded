local add_mod_prefix = require( 'util.add_mod_prefix' )

local function add_recipe_category( name )
    -- LuaFormatter off
    data:extend( {
        {
            type = 'recipe-category',
            name = add_mod_prefix( name )
        }
    } )
    -- LuaFormatter on
end

add_recipe_category( 'recycling' )
