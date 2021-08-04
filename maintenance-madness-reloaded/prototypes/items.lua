data:extend( {
    {
        type = 'item-group',
        name = 'mm-main-group',
        order = 'z-z',
        icon = '__maintenance-madness-reloaded__/graphics/icons/item-group.png',
        icon_size = 64
    },
    {
        type = 'item-subgroup',
        name = 'mm-scrap',
        group = 'mm-main-group',
        order = 'a'
    },
    {
        type = 'item-subgroup',
        name = 'mm-recyling',
        group = 'mm-main-group',
        order = 'b'
    },
    {
        type = 'item-subgroup',
        name = 'mm-recondition',
        group = 'mm-main-group',
        order = 'c'
    },
    {
        type = 'item-subgroup',
        name = 'mm-faulty-entity',
        group = 'mm-main-group',
        order = 'd'
    },
    {
        type = 'repair-tool',
        name = 'mm-toolbox',
        icon = '__maintenance-madness-reloaded__/graphics/tools/toolbox.png',
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
        name = 'mm-machine-oil',
        icon = '__maintenance-madness-reloaded__/graphics/tools/machine-oil.png',
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
        name = 'mm-detergent',
        icon = '__maintenance-madness-reloaded__/graphics/tools/detergent.png',
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
        name = 'mm-mechanical-spare-parts',
        icon = '__maintenance-madness-reloaded__/graphics/tools/mechanical-spare-parts.png',
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
        name = 'mm-electronical-spare-parts',
        icon = '__maintenance-madness-reloaded__/graphics/tools/electronical-spare-parts.png',
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
        name = 'mm-recycler',
        icon = '__maintenance-madness-reloaded__/graphics/icons/recycler.png',
        icon_size = 32,
        flags = {},
        subgroup = 'production-machine',
        order = 'y2',
        place_result = 'mm-recycler',
        stack_size = 20
    },
    {
        type = 'item',
        name = 'mm-simple-maintenance-unit',
        icon = '__maintenance-madness-reloaded__/graphics/icons/simple-maintenance-unit-icon.png',
        icon_size = 64,
        flags = {},
        subgroup = 'production-machine',
        order = 'y1',
        place_result = 'mm-simple-maintenance-unit',
        stack_size = 50
    }
} )
