-- https://wiki.factorio.com/Prototype/Technology
--
-- Format:
-- {
--     -- Required:
--     name                        = String,
--     type                        = String, -- technology
--     unit                        = Table
--     icon, icons, icon_size      = IconSpecification
--     -- Optional:
--     localised_name              = LocalisedString,
--     localised_description       = LocalisedString,
--     order                       = String,
--     hidden                      = Optional,
--     effects                     = Table of Types/ModifierPrototype,
--     enabled                     = Bool,
--     expensive                   = Technology data | Bool,
--     ignore_tech_cost_multiplier = Bool,
--     max_level                   = Uint32 | String,
--     normal                      = Technology data | Bool,
--     prerequisites               = Table | String,
--     upgrade                     = Bool,
--     visible_when_disabled       = Bool
-- }
--
-- local internalSettings = require( 'config-startup' )
local constants = require( 'constants' )
local mod_helpers = require( 'util.mod_helpers' )
local round = require( 'util.round' )

local this_mod = mod_helpers.this_mod

local function add_technology( tech )
    tech.type = 'technology'

    tech.name = this_mod:add_prefix( tech.name )
    tech.icon = this_mod:get_graphics_path( tech.icon )

    if tech.effects == nil then
        tech.effects = {}
    end

    if tech.order == nil then
        tech.order = 'c-c-e'
    end

    if tech.icon_size == nil then
        tech.icon_size = 128
    end

    data:extend( { tech } )
end

add_technology( {
    name = 'repair-and-maintenance',
    icon = 'tech/repair-and-maintenance-tech.png',
    prerequisites = { 'automation', 'steel-processing' },
    unit = {
        count = 75,
        ingredients = { { 'automation-science-pack', 1 } },
        time = 10
    }
} )

add_technology( {
    name = 'recycling',
    icon = 'tech/recycling-tech.png',
    prerequisites = { 'engine', 'concrete' },
    unit = {
        count = 200,
        ingredients = {
            { 'automation-science-pack', 1 },
            { 'logistic-science-pack', 1 }
        },
        time = 30
    },
    effects = {
        { type = 'unlock-recipe', recipe = this_mod:add_prefix( 'recycler' ) }
    }
} )

add_technology( {
    name = 'recondition',
    icon = 'tech/recycling-tech.png',
    prerequisites = { this_mod:add_prefix( 'recycling' ), 'automation-3' },
    unit = {
        count = 450,
        ingredients = {
            { 'automation-science-pack', 1 },
            { 'logistic-science-pack', 1 },
            { 'chemical-science-pack', 1 },
            { 'production-science-pack', 1 }
        },
        time = 60
    },
    effects = {
        { type = 'unlock-recipe', recipe = this_mod:add_prefix( 'toolbox' ) }
        -- recondition recipes are added in data-final-fixes
    }
} )

add_technology( {
    name = 'improved-maintenance-access-1',
    icon = 'tech/maintenance-hatch.png',
    prerequisites = { this_mod:add_prefix( 'repair-and-maintenance' ) },
    unit = {
        count = 100,
        ingredients = { { 'automation-science-pack', 1 } },
        time = 15
    },
    effects = {
        {
            type = 'nothing',
            effect_description = {
                this_mod:add_prefix( 'effect-basic-maintenance-bonus' ),
                round( constants.tech_bonuses.improved_maintenance_access[1]
                           .maintenance_bonus * 100, 1 )
            }
        }
    },
    upgrade = true
} )

add_technology( {
    name = 'improved-maintenance-access-2',
    icon = 'tech/maintenance-hatch.png',
    prerequisites = {
        this_mod:add_prefix( 'improved-maintenance-access-1' ),
        'automation-2'
    },
    unit = {
        count = 200,
        ingredients = {
            { 'automation-science-pack', 1 },
            { 'logistic-science-pack', 1 }
        },
        time = 30
    },
    effects = {
        {
            type = 'nothing',
            effect_description = {
                this_mod:add_prefix( 'effect-basic-maintenance-bonus' ),
                round( constants.tech_bonuses.improved_maintenance_access[2]
                           .maintenance_bonus * 100, 1 )
            }
        },
        {
            type = 'nothing',
            effect_description = {
                this_mod:add_prefix( 'effect-basic-repair-speed-bonus' ),
                round( constants.tech_bonuses.improved_maintenance_access[2]
                           .repair_speed_bonus * 100, 1 )
            }
        }
    },
    upgrade = true
} )

add_technology( {
    name = 'improved-maintenance-access-3',
    icon = 'tech/maintenance-hatch.png',
    prerequisites = {
        this_mod:add_prefix( 'improved-maintenance-access-2' ),
        'advanced-electronics'
    },
    unit = {
        count = 400,
        ingredients = {
            { 'automation-science-pack', 1 },
            { 'logistic-science-pack', 1 }
        },
        time = 60
    },
    effects = {
        {
            type = 'nothing',
            effect_description = {
                this_mod:add_prefix( 'effect-basic-maintenance-bonus' ),
                round( constants.tech_bonuses.improved_maintenance_access[3]
                           .maintenance_bonus * 100, 1 )
            }
        },
        {
            type = 'nothing',
            effect_description = {
                this_mod:add_prefix( 'effect-basic-repair-speed-bonus' ),
                round( constants.tech_bonuses.improved_maintenance_access[3]
                           .repair_speed_bonus * 100, 1 )
            }
        }
    },
    upgrade = true
} )
