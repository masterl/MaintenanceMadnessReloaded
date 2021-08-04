for entityID, data in pairs( global.monitoredEntities ) do
    local machine = data.entity
    if machine and machine.valid then
        if machine.operable == false then
            machine.operable = true
        end
    end
end
