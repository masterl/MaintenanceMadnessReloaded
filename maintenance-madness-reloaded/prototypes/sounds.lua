local mod_helpers = require( 'util.mod_helpers' )

local this_mod = mod_helpers.this_mod
local base_mod = mod_helpers.base_mod

data:extend( {
    {
        type = 'sound',
        name = this_mod:add_prefix( 'machine-failure-sound' ),
        variations = {
            {
                filename = this_mod:get_sounds_path( 'machine-failure-1.ogg' ),
                volume = 0.7
            },
            {
                filename = this_mod:get_sounds_path( 'machine-failure-2.ogg' ),
                volume = 0.5
            },
            {
                filename = this_mod:get_sounds_path( 'machine-failure-3.ogg' ),
                volume = 0.7
            }
        }
    },
    {
        type = 'sound',
        name = this_mod:add_prefix( 'machine-fixed-sound' ),
        variations = {
            {
                filename = base_mod:get_sounds_path(
                    'power-switch-activate-1.ogg' ),
                volume = 0.8
            },
            {
                filename = base_mod:get_sounds_path(
                    'power-switch-activate-2.ogg' ),
                volume = 0.8
            },
            {
                filename = base_mod:get_sounds_path(
                    'power-switch-activate-3.ogg' ),
                volume = 0.8
            }
        }
    }
} )
