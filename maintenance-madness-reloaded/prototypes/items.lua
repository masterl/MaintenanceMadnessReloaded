local add_mod_prefix = require( 'util.add_mod_prefix' )
local mod_folder_path = require( 'util.mod_folder_path' )

data:extend( {
    {
        type = 'repair-tool',
        name = add_mod_prefix( 'toolbox' ),
        icon = mod_folder_path( '/graphics/tools/toolbox.png' ),
        icon_size = 64,
        flags = {},
        subgroup = 'tool',
        order = 'b[repair]-g[repair-pack]',
        speed = 3,
        durability = 2500,
        stack_size = 10
    },
    {
        type = 'repair-tool',
        name = add_mod_prefix( 'machine-oil' ),
        icon = mod_folder_path( '/graphics/tools/machine-oil.png' ),
        icon_size = 64,
        flags = {},
        subgroup = 'tool',
        order = 'b[repair]-e[repair-pack]',
        speed = 0.5,
        durability = 150,
        stack_size = 100
    },
    {
        type = 'repair-tool',
        name = add_mod_prefix( 'detergent' ),
        icon = mod_folder_path( '/graphics/tools/detergent.png' ),
        icon_size = 64,
        flags = {},
        subgroup = 'tool',
        order = 'b[repair]-f[repair-pack]',
        speed = 0.5,
        durability = 150,
        stack_size = 100
    },
    {
        type = 'repair-tool',
        name = add_mod_prefix( 'mechanical-spare-parts' ),
        icon = mod_folder_path( '/graphics/tools/mechanical-spare-parts.png' ),
        icon_size = 64,
        flags = {},
        subgroup = 'tool',
        order = 'b[repair]-c[repair-pack]',
        speed = 0.5,
        durability = 50,
        stack_size = 100
    },
    {
        type = 'repair-tool',
        name = add_mod_prefix( 'electronical-spare-parts' ),
        icon = mod_folder_path( '/graphics/tools/electronical-spare-parts.png' ),
        icon_size = 64,
        flags = {},
        subgroup = 'tool',
        order = 'b[repair]-d[repair-pack]',
        speed = 0.5,
        durability = 50,
        stack_size = 100
    },
    {
        type = 'item',
        name = add_mod_prefix( 'recycler' ),
        icon = mod_folder_path( '/graphics/icons/recycler.png' ),
        icon_size = 32,
        flags = {},
        subgroup = 'production-machine',
        order = 'y2',
        place_result = add_mod_prefix( 'recycler' ),
        stack_size = 20
    },
    {
        type = 'item',
        name = add_mod_prefix( 'simple-maintenance-unit' ),
        icon = mod_folder_path(
            '/graphics/icons/simple-maintenance-unit-icon.png' ),
        icon_size = 64,
        flags = {},
        subgroup = 'production-machine',
        order = 'y1',
        place_result = add_mod_prefix( 'simple-maintenance-unit' ),
        stack_size = 50
    }
} )
