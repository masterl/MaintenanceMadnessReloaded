-- Maintenance Madness - 2019-2020. Created by Arcitos. License: See mod page.
--- INTERNAL SETTINGS
local internalSettings = {}

internalSettings.recycleTimeMultiplier = 2 -- base recipe energy times this factor is the time/energy needed to recycle a machine

internalSettings.recycleTimeMinimum = 6 -- minimum energy needed to recycle any machine

internalSettings.reconditionTimeMultiplier = 4 -- base recipe energy times this factor is the time/energy needed to recondition a machine

internalSettings.reconditionTimeMinimum = 12 -- minimum energy needed to recondition any machine

internalSettings.reconditionSparePartFactor = 0.5 -- percentage of items needed to complete the recondition of scrapped entities

internalSettings.entityTypesWithMROenabled = {
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

internalSettings.maintenanceUnits = {
    ['mm-simple-maintenance-unit'] = {
        radius = 4,
        energyUsage = '76kW',
        energyBuffer = '76kJ'
    }
}
-- note: radius should be matched to "radius" set in config-runtime

internalSettings.techBoni = {
    improvedMaintenanceAccess = {
        -- each entry represents one level
        { basicMaintenanceBonus = 0.1 },
        { basicMaintenanceBonus = 0.1, basicRepairSpeedBonus = 0.05 },
        { basicMaintenanceBonus = 0.15, basicRepairSpeedBonus = 0.05 }
    }
}

return internalSettings
