-- https://wiki.factorio.com/Tutorial:Mod_settings
--
-- File loading order:
--  1 - settings.lua
--  2 - settings-updates.lua
--  3 - settings-final-fixes.lua
--
-- Format:
-- {
--     -- Required:
--     name                  = String,
--     type                  = String, -- (bool|int|double|string)-setting
--     setting_type          = String, -- startup|runtime-global|runtime-per-user
--     -- Optional:
--     localised_name        = LocalisedString,
--     localised_description = LocalisedString,
--     order                 = String,
--     hidden                = Optional
-- }
--
local mod_helpers = require( 'util.mod_helpers' )
local order_generators = require( 'util.order_generators' )

local this_mod = mod_helpers.this_mod
local next_simple_order = order_generators.next_simple_order

local last_order = { letter = 'z', number = 8 }

local function add_setting( setting )
    setting.name = this_mod:add_prefix( setting.name )

    if setting.setting_type == nil then
        setting.setting_type = 'runtime-global'
    end

    local new_order = next_simple_order( last_order.letter, last_order.number )

    setting.order = new_order.as_string

    last_order = new_order

    data:extend( { setting } )
end

local function add_bool_setting( setting )
    setting.type = 'bool-setting'

    add_setting( setting )
end

local function add_int_setting( setting )
    setting.type = 'int-setting'

    add_setting( setting )
end

local function add_double_setting( setting )
    setting.type = 'double-setting'

    add_setting( setting )
end

local function add_string_setting( setting )
    setting.type = 'string-setting'

    add_setting( setting )
end

-- LuaFormatter still doesn't chop kv tables right
-- LuaFormatter off
add_bool_setting( {
    name = 'mod-active',
    default_value = true
} )

add_string_setting( {
    name = 'maintenance-cost',
    default_value = 'level-1',
    allowed_values = { 'level-0', 'level-1', 'level-2', 'level-3' }
} )

add_bool_setting( {
    name = 'show-flying-text',
    default_value = true
} )

add_bool_setting( {
    name = 'show-maintenance-in-progress-sign-for-solar',
    default_value = false
} )

add_double_setting( {
    name = 'expected-life-time',
    default_value = 12,
    minimum_value = 2,
    maximum_value = 720
} )

add_double_setting( {
    name = 'mean-time-between-maintenance-events',
    default_value = 12,
    minimum_value = 0.5,
    maximum_value = 720
} )

add_double_setting( {
    name = 'mean-time-to-maintain',
    default_value = 3,
    minimum_value = 0.3,
    maximum_value = 30
} )

add_double_setting( {
    name = 'mean-time-to-repair',
    default_value = 5,
    minimum_value = 0.5,
    maximum_value = 300
} )

add_bool_setting( {
    name = 'include-accumulators',
    default_value = true
} )

add_bool_setting( {
    name = 'include-solar-panels',
    default_value = true
} )

add_bool_setting( {
    name = 'include-reactors',
    default_value = true
} )

add_bool_setting( {
    name = 'include-boiler-and-generators',
    default_value = true
} )

add_bool_setting( {
    name = 'include-miners',
    default_value = false
} )

add_bool_setting( {
    name = 'include-roboports',
    default_value = false
} )

add_bool_setting( {
    name = 'include-beacons',
    default_value = true
} )

add_bool_setting( {
    name = 'include-labs',
    default_value = true
} )

add_int_setting( {
    name = 'solar-factor',
    default_value = 3,
    minimum_value = 1,
    maximum_value = 10
} )

add_int_setting( {
    name = 'replacement-age',
    default_value = 80,
    minimum_value = 10,
    maximum_value = 300
} )

add_int_setting( {
    name = 'wear-reduction-if-idle',
    default_value = 80,
    minimum_value = 0,
    maximum_value = 100
} )

add_double_setting( {
    name = 'missed-maintenance-malus',
    default_value = 200,
    minimum_value = 0,
    maximum_value = 1000
} )

add_bool_setting( {
    name = 'enable-low-tech-bonus',
    default_value = false
} )


add_string_setting( {
    name = 'low-tech-bonus-target-tech',
    default_value = 'rocket-silo'
} )

add_bool_setting( {
    name = 'enable-low-tech-update-notification',
    default_value = true
} )

-- TODO: Check if this will be used
-- ? this was commented on original code
-- add_int_setting( {
--     name = 'max-age',
--     default_value = 100,
--     minimum_value = 10,
--     maximum_value = 1000
-- } )
-- LuaFormatter on
