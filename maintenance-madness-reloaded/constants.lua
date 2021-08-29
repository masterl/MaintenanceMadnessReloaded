-- not using an array because this will make it easier to test later
-- e.g. if enabled_entity_types[type] then ...
local enabled_entity_types = {
    ['assembling-machine'] = true,
    ['furnace'] = true,
    ['solar-panel'] = true,
    ['accumulator'] = true,
    ['reactor'] = true,
    ['boiler'] = true,
    ['generator'] = true,
    ['mining-drill'] = true,
    ['roboport'] = true,
    ['beacon'] = true,
    ['lab'] = true
}

local constants = {
    mod_name = 'maintenance-madness-reloaded',
    recycle_time_multiplier = 2,
    recycle_time_minimum = 6,
    recondition_time_multiplier = 4,
    recondition_time_minimum = 12,
    -- Percentage of items needed to recondition a scrapped entity
    recondition_spare_parts_factor = 0.5,
    enabled_entity_types = enabled_entity_types,
    tech_bonuses = {
        improved_maintenance_access = {
            { maintenance_bonus = 0.1 },
            { maintenance_bonus = 0.1, repair_speed_bonus = 0.05 },
            { maintenance_bonus = 0.15, repair_speed_bonus = 0.05 }
        }
    }
}

return constants
