local mod_helpers = require( 'util.mod_helpers' )

local this_mod = mod_helpers.this_mod

data:extend( {
    {
        type = 'repair-tool',
        name = this_mod:add_prefix( 'toolbox' ),
        icon = this_mod:get_path_to_graphics( 'tools/toolbox.png' ),
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
        name = this_mod:add_prefix( 'machine-oil' ),
        icon = this_mod:get_path_to_graphics( 'tools/machine-oil.png' ),
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
        name = this_mod:add_prefix( 'detergent' ),
        icon = this_mod:get_path_to_graphics( 'tools/detergent.png' ),
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
        name = this_mod:add_prefix( 'mechanical-spare-parts' ),
        icon = this_mod:get_path_to_graphics( 'tools/mechanical-spare-parts.png' ),
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
        name = this_mod:add_prefix( 'electronical-spare-parts' ),
        icon = this_mod:get_path_to_graphics(
            'tools/electronical-spare-parts.png' ),
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
        name = this_mod:add_prefix( 'recycler' ),
        icon = this_mod:get_path_to_graphics( 'icons/recycler.png' ),
        icon_size = 32,
        flags = {},
        subgroup = 'production-machine',
        order = 'y2',
        place_result = this_mod:add_prefix( 'recycler' ),
        stack_size = 20
    },
    {
        type = 'item',
        name = this_mod:add_prefix( 'simple-maintenance-unit' ),
        icon = this_mod:get_path_to_graphics(
            'icons/simple-maintenance-unit-icon.png' ),
        icon_size = 64,
        flags = {},
        subgroup = 'production-machine',
        order = 'y1',
        place_result = this_mod:add_prefix( 'simple-maintenance-unit' ),
        stack_size = 50
    }
} )
