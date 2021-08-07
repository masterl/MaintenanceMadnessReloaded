local add_mod_prefix = require( 'util.add_mod_prefix' )
local mod_folder_path = require( 'util.mod_folder_path' )

local main_group_name = add_mod_prefix( 'main-group' )

data:extend( {
    {
        type = 'item-group',
        name = main_group_name,
        order = 'zz',
        icon = mod_folder_path( '/graphics/icons/item-group.png' ),
        icon_size = 64
    }
} )

local function add_subgroup( name, order )
    data:extend( {
        {
            type = 'item-subgroup',
            name = add_mod_prefix( name ),
            group = main_group_name,
            order = order
        }
    } )
end

add_subgroup( 'scrap', 'a' )
add_subgroup( 'recycling', 'b' )
add_subgroup( 'recondition', 'c' )
add_subgroup( 'faulty-entity', 'd' )
