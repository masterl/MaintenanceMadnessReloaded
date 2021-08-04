local const = require( 'config-runtime' )

local function initActivityTracking( entity )
    local activityData
    local type = entity.type
    if type == 'mining-drill' then
        activityData = entity.mining_progress
    elseif type == 'lab' then
        activityData = {}
        local inventory = entity.get_inventory( defines.inventory.lab_input )
        for i = 1, #inventory do
            local stack = inventory[i]
            if stack ~= nil and stack.valid_for_read then
                activityData[i] = stack.durability
            else
                activityData[i] = 1
            end
        end
    elseif type == 'generator' then
        if entity.energy_generated_last_tick > 0 then
            activityData = true
        else
            activityData = false
        end
    elseif type == 'boiler' then
        local burner = entity.burner
        if burner then
            activityData = burner.remaining_burning_fuel
        end
    elseif type == 'reactor' then
        local burner = entity.burner
        if burner then
            activityData = burner.remaining_burning_fuel
        end
    end
    return activityData
end

for entityID, data in pairs( global.monitoredEntities ) do
    local machine = data.entity
    if machine and machine.valid then
        if const.alternativeActivityTracking[machine.type] then
            data.activityData = initActivityTracking( machine )
        end
    end
end
