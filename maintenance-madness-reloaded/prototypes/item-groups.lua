local mod_helpers = require( 'util.mod_helpers' )

local this_mod = mod_helpers.this_mod

local main_group_name = this_mod:add_prefix( 'main-group' )

data:extend( {
    {
        type = 'item-group',
        name = main_group_name,
        order = 'zz',
        icon = this_mod:get_graphics_path( 'icons/item-group.png' ),
        icon_size = 64
    }
} )

local function add_subgroup( name, order )
    data:extend( {
        {
            type = 'item-subgroup',
            name = this_mod:add_prefix( name ),
            group = main_group_name,
            order = order
        }
    } )
end

add_subgroup( 'scrap', 'a' )
add_subgroup( 'recycling', 'b' )
add_subgroup( 'recondition', 'c' )
add_subgroup( 'faulty-entity', 'd' )
