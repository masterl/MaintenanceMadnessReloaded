local const = require("config-runtime")
local mfloor = math.floor
local rand = math.random

local function checkControlTable(forceID, entityName)
	-- check, if the force has already a control table and create one if not	
	if global.maintenanceControl[forceID] == nil then
		global.maintenanceControl[forceID] = {}
		global.maintenanceControl[forceID].byItem = {}
		global.maintenanceControl[forceID].byEntity = {}
		return true
	end
	-- check if the entity is already registered
	local control = global.maintenanceControl[forceID]
	if control.byEntity[entityName] then
		return false
	else
		return true
	end
end

local function addEntityToControlTable(forceID, entityName)
	local element = {}
	element.maintenance = {}
	element.repair = {} 
	element.replacement = {} 
	
	for itemName, data in pairs(global.entitiesWithMROenabled[entityName].maintenance["level-1"]) do		
		element.maintenance[itemName] = {}
		element.maintenance[itemName].enabled = true
	end
	for itemName, data in pairs(global.entitiesWithMROenabled[entityName].repair["level-1"].secondary) do		
		element.repair[itemName] = {}
		element.repair[itemName].enabled = true
	end
	element.replacement.start = const.replacementAge
	element.replacement.limit = const.maxOperationAge -- later used to stop machines that are extremely old and in danger of destruction
	
	global.maintenanceControl[forceID].byEntity[entityName] = element
end

init_global()
for entityID, data in pairs(global.monitoredEntities) do
	local machine = data.entity			
	if machine and machine.valid and data.status == "malfunction" then	
		local machineName = data.surrogatedEntityName or machine.name
		local forceID = machine.force.index
		if checkControlTable(forceID, machineName) then
			addEntityToControlTable(forceID, machineName)
		end			
		local machineSwapped = false
		local chest = data.connectedChest
		local machineName = data.surrogatedEntityName or machine.name -- get name of surrogated machine (in case of solar panel or accumulator) or real machine name
		local machineProperties = global.entitiesWithMROenabled[machineName]
		postItemsAsConsumption(chest)
		chest.destroy()
		data.requestedItems = nil
		data.connectedProxy = nil
		data.connectedChest = nil
		--- solar panels and accumulators have been replaced by broken versions - these entities must be swapped back :
		if data.surrogatedEntityName then 
			machine = swapOldMachine(machine) 
			entityID = machine.unit_number
			machineSwapped = true
		end				
		data.timeToRepair = nil
		data.repairTimeElapsed = nil
		data.repairEffectivity = nil
		data.ageing = data.ageing + machineProperties.timeFactor * const.repairAgeMalus
		data.status = "operating"				
		machine.active = true
		machine.operable = true
		machine.rotatable = true
		
		if machineSwapped then
			eventTick = game.tick + mfloor(machineProperties.timeFactor * rand(mfloor(const.MTBM/2), mfloor(const.MTBM*1.5)))		
		end
		if data.ageing >= const.replacementAge then 
			requestReplacementOfOldMachine(entityID)
		end
	end
end