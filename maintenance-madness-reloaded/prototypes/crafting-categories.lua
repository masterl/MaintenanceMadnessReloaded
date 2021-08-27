local mod_helpers = require( 'util.mod_helpers' )

local this_mod = mod_helpers.this_mod

local function add_recipe_category( name )
    -- LuaFormatter off
    data:extend( {
        {
            type = 'recipe-category',
            name = this_mod:add_prefix( name )
        }
    } )
    -- LuaFormatter on
end

add_recipe_category( 'recycling' )
