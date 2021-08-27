local mod_helpers = require( 'util.mod_helpers' )

local this_mod = mod_helpers.this_mod

data:extend( {
    {
        type = 'animation',
        name = this_mod:add_prefix( 'repair-in-progress-icon' ),
        filename = this_mod:get_graphics_path(
            'icons/repair-in-progress-sheet-2.png' ),
        flags = { 'icon', 'no-crop' },
        width = 64,
        height = 64,
        scale = 0.5,
        frame_count = 60,
        line_length = 10,
        animation_speed = 1,
        run_mode = 'forward',
        priority = 'extra-high-no-scale'
    }
} )
