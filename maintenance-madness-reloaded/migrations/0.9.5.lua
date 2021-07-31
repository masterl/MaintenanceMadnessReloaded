global.maintenanceUnits = global.maintenanceUnits or {}
for entityID, data in pairs(global.monitoredEntities) do
	if data.entity and data.entity.valid then	
		global.monitoredEntities[entityID].nextEventTick = 0
		global.monitoredEntities[entityID].serviceRequests = 0
		global.monitoredEntities[entityID].serviceLevel = 0
		global.monitoredEntities[entityID].upgrades = { 				
				energyBonusLevel = 0,
				speedBonusLevel = 0,
				pollutionReductionLevel = 0} 
	else
		global.monitoredEntities[entityID].producedItems = nil
	end
end
for tick, elements in pairs(global.eventScheduleMRO) do
	for index, data in pairs(elements.elements) do
		local updatedElement = data
		if updatedElement.age ~= nil then 
			updatedElement.age = nil
		end
		updatedElement.type = "machine"
		global.eventScheduleMRO[tick][index] = updatedElement
	end
end
