local add_mod_prefix = require( 'util.add_mod_prefix' )
local get_sound_path = require( 'util.get_sound_path' )
local base_mod = require( 'util.base_mod' )

local get_base_sound_path = base_mod.get_sound_path

data:extend( {
    {
        type = 'sound',
        name = add_mod_prefix( 'machine-failure-sound' ),
        variations = {
            { filename = get_sound_path( 'machine-failure-1.ogg' ), volume = 0.7 },
            { filename = get_sound_path( 'machine-failure-2.ogg' ), volume = 0.5 },
            { filename = get_sound_path( 'machine-failure-3.ogg' ), volume = 0.7 }
        }
    },
    {
        type = 'sound',
        name = add_mod_prefix( 'machine-fixed-sound' ),
        variations = {
            {
                filename = get_base_sound_path( 'power-switch-activate-1.ogg' ),
                volume = 0.8
            },
            {
                filename = get_base_sound_path( 'power-switch-activate-2.ogg' ),
                volume = 0.8
            },
            {
                filename = get_base_sound_path( 'power-switch-activate-3.ogg' ),
                volume = 0.8
            }
        }
    }
} )
