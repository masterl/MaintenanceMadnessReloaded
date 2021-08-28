-- Check https://wiki.factorio.com/Prototype/CustomInput for updated info
-- Format:
-- {
--     -- Required:
--     name                       = String,
--     type                       = String,
--     key_sequence               = String,     -- Default binding
--     -- Optional:
--     action                     = String,
--     alternative_key_sequence   = String,
--     consuming                  = ConsumingType,
--     enabled                    = Bool,
--     enabled_while_in_cutscene  = Bool,
--     enabled_while_spectating   = Bool,
--     include_selected_prototype = bool,
--     item_to_spawn              = String,
--     linked_game_control        = String,
--     localised_name             = LocalisedString,
--     localised_description      = LocalisedString,
--     order                      = String
-- }
local mod_helpers = require( 'util.mod_helpers' )

local this_mod = mod_helpers.this_mod

local function add_custom_input( input )
    input.type = 'custom-input'

    data:extend( { input } )
end

add_custom_input( {
    name = this_mod:add_prefix( 'event-manual-maintenance' ),
    key_sequence = 'F',
    consuming = 'game-only'
} )
