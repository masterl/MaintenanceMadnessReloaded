global.last_selected = global.last_selected or {}
for entityID, data in pairs(global.monitoredEntities) do
	if data.entity and data.entity.valid then
		entityType = data.entity.type
		if entityType == "assembling-machine" or entityType == "furnace" then
			global.monitoredEntities[entityID].producedItems = 0 -- This is only tracked for those entities that support products_finished. 
		else
			global.monitoredEntities[entityID].producedItems = nil
		end
	else
		global.monitoredEntities[entityID].producedItems = nil
	end
end