global.forceBonus = global.forceBonus or {}

for mUnitID, data in pairs(global.maintenanceUnits) do
	local mUnit = data.entity
	if mUnit and mUnit.valid then
		local connectedMachines = getNeighboringMachines(mUnit)
        if connectedMachines ~= nil then
            for k, machineID in pairs(connectedMachines) do
                registerMaintenanceUnit(machineID, mUnitID)
            end
        end
        global.maintenanceUnits[mUnitID].connectedMachines = connectedMachines
	end
end