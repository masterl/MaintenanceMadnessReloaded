-- Maintenance Madness - 2019-2020. Created by Arcitos. License: See mod page.

require("util")

local mm_util = require("util.util")
local mmGUI = require("control-gui")
local const = require("config-runtime")
local internalSettings = require("config-startup")

local rand = math.random
local mceil = math.ceil
local mfloor = math.floor
local mmin = math.min
local mmax = math.max

local forcesWithMROdisabled = const.forcesWithMROdisabled

local entityTypesWithMROenabled = const.entityTypesWithMROenabled

local entityMaintencanceDemandByName = const.entityMaintencanceDemandByName

local entityMaintenanceDemandByType = const.entityMaintenanceDemandByType

local entityDefaultRepairDemandByType = const.entityDefaultRepairDemandByType

local textColors = const.textColors

----- MAIN FUNCTIONS      (-> Event handlers: line 1100+)

-- set up aux table for maintenance demands per entity prototype class
local function initMaintenanceDemandsTable(entityName, timeFactor)
	local resultTable = {}
	-- the maintenance demands are defined in this config table:
	local source = entityMaintencanceDemandByName[entityName] or entityMaintenanceDemandByType[game.entity_prototypes[entityName].type] -- entity specification > type specification
	for level, costFactor in pairs(const.costFactor) do
		resultTable[level] = {}
		local probSum = 0 -- sum of probabilities for each item (including default items). This is used to calculate the effect of each item
		for _, ingredient in pairs(source) do
			local itemName = ingredient.name or ingredient[1]
			local amount = mm_util.getIngredientAmount(ingredient)
			if ingredient.type ~= "fluid" then
				-- add the maintenance demands for each class to all entities
				probSum = probSum + ingredient.probability
				resultTable[level][itemName] = {}
				resultTable[level][itemName].probability = ingredient.probability
				resultTable[level][itemName].min_amount = mceil(amount * costFactor * timeFactor / 2) -- min 50% maintenance demand
				resultTable[level][itemName].max_amount = mceil(amount * costFactor * timeFactor * 1,5) -- max 150% maintenance demand
			end
		end
		-- calculate expected demand and effect (used for gui purposes) -- only approximative!
		local ingredientsCount = mm_util.getLength(resultTable[level])
		for _, ingredient in pairs(resultTable[level]) do
			ingredient.expectedEffect = ingredient.probability / probSum
			ingredient.expectedDemand = (ingredient.max_amount + ingredient.min_amount) / 2 * ingredient.probability
		end
	end
	--log(serpent.block(resultTable, {maxlevel= 4}))
	return resultTable
end

-- set up aux table for repair demands per entity prototype
local function initRepairDemandsTable(entityName, timeFactor)
	local resultTable = {}
	local repairAmountMin = const.repairAmount / 2
	local repairAmountMax = const.repairAmount * 1.5
	local ingredients = game.recipe_prototypes[entityName].ingredients
	local defaultIngredients = entityDefaultRepairDemandByType[game.entity_prototypes[entityName].type]
	for level, costFactor in pairs(const.costFactor) do
		resultTable[level] = {}
		resultTable[level].primary = {}
		resultTable[level].secondary = {}
		local invProbProduct = 1 -- probability that no item is chosen at all. This is used to calculate the probabilities for default items
		local probSum = 0 -- sum of probabilities for each item (including default items). This is used to calculate the effect of each item
		for _, ingredient in pairs(ingredients) do
			local itemName = ingredient.name or ingredient[1]
			local amount = mm_util.getIngredientAmount(ingredient)
			if ingredient.type ~= "fluid" then
				-- these additional repair materials reduce the time needed for repair if provided. They are a fraction of the entity's construction cost
				local prob = mmin((amount ^ 2 / 100) * costFactor * timeFactor, 0.5) -- ingredients in small amounts are often expensive, therefore the probability for using them as spare parts is lowered
				invProbProduct = invProbProduct * (1 - prob)
				probSum = probSum + prob
				resultTable[level].secondary[itemName] = {}
				resultTable[level].secondary[itemName].probability = prob
				resultTable[level].secondary[itemName].min_amount = mceil(amount * costFactor * timeFactor * repairAmountMin) -- default: min 2,5% of construction cost
				resultTable[level].secondary[itemName].max_amount = mceil(amount * costFactor * timeFactor * repairAmountMax) -- default: max 7,5% of construction cost
			end
		end
		-- to catch cases in which no secondary item has been chosen (no item has prob = 1), the following default items are added
		for _, ingredient in pairs(defaultIngredients) do
			local itemName = ingredient.name or ingredient[1]
			local amount = mm_util.getIngredientAmount(ingredient)
			if ingredient.type ~= "fluid" then
				resultTable[level].secondary[itemName] = {}
				resultTable[level].secondary[itemName].defaultItem = true
				resultTable[level].secondary[itemName].min_amount = mceil(amount * costFactor * timeFactor * repairAmountMin) -- default: min 2,5% of construction cost
				resultTable[level].secondary[itemName].max_amount = mceil(amount * costFactor * timeFactor * repairAmountMax) -- default: max 7,5% of construction cost
				probSum = probSum + invProbProduct -- add the probability for a default item (the probability that no other item was chosen)
			end
		end
		-- calculate expected demand and effect (used for gui purposes) -- only approximative!
		local ingredientsCount = mm_util.getLength(resultTable[level].secondary)
		local expectedEffectChecksum = 0
		for _, ingredient in pairs(resultTable[level].secondary) do
			if ingredient.defaultItem then
				ingredient.expectedEffect = invProbProduct / probSum
				ingredient.expectedDemand = (ingredient.max_amount + ingredient.min_amount) / 2 * invProbProduct
			else
				ingredient.expectedEffect = ingredient.probability / probSum
				ingredient.expectedDemand = (ingredient.max_amount + ingredient.min_amount) / 2 * ingredient.probability
			end
			expectedEffectChecksum = expectedEffectChecksum + ingredient.expectedEffect
		end
		-- make sure that the sum of all effects is actually 1. If not, correct the effect value of the default item.
		local sumCorrectionItemName = defaultIngredients[#defaultIngredients].name or defaultIngredients[#defaultIngredients][1]
		if const.debug then
			log("Effect sum = "..expectedEffectChecksum)
			log("Adjusted effect sum for "..entityName.." by "..(1 - expectedEffectChecksum))
		end
		resultTable[level].secondary[sumCorrectionItemName].expectedEffect = resultTable[level].secondary[sumCorrectionItemName].expectedEffect - expectedEffectChecksum + 1
		--[[
local n = 3
local prob = {a = 1, b = 0.5, c = 0.25}
local result = {a = 0, b = 0, c = 0}

for i = 1, n do


local n = 2
prob = {a = 1, b = 0.5, c = 0.25}
result = {a = 0, b = 0, c = 0}
for i = 1, n do
  local posNum = {}
  local num = 0
  for k, eProb in pairs(prob) do
    if math.random() < eProb then
      posNum[k] = 1
      num = num + 1
	end
  end
  for k, num in pairs(posNum) do
    result[k] = result[k] + (1 / num)
  end
end
for k, val in pairs(result) do
    print(val/n)
end
]]

		-- the following items are necessary in order to start repair
		local repairPackName = "repair-pack"
		local healthFactor = mceil(game.entity_prototypes[entityName].max_health * costFactor * timeFactor / 100) -- sturdier entities need more repair packs
		local itemTypes = mceil(mm_util.getLength(resultTable[level]) * costFactor * timeFactor / 2) -- every two different items required for construction, one additional repair pack is needed
		resultTable[level].primary[repairPackName] = {}
		resultTable[level].primary[repairPackName].probability = 1
		resultTable[level].primary[repairPackName].min_amount = 1
		resultTable[level].primary[repairPackName].max_amount = mceil((itemTypes + healthFactor))
	end
	--log(serpent.block(resultTable, {maxlevel= 4}))
	--log(entityName)
	return resultTable
end


-- start with building of some aux tables to avoid repeated calculations + allowing for dynamic value modification
local function initAuxTables()
	global.repairItems = {} -- WIP
	for _, item in pairs(game.item_prototypes) do
		if item.type == "repair-tool" then
			table.insert(global.repairItems, item.name)
		end
	end

	local ignore = {}
	for name, _ in pairs(const.maintenanceUnits) do
		ignore[name.."-placement-entity"] = true
	end

	global.entitiesWithMROenabled = {}
	for _, entity in pairs(game.entity_prototypes) do
		-- add all entities of a prototype class, if this class is enabled in mod config
		if entityTypesWithMROenabled[entity.type] ~= nil then
			-- add an entity only if it has an recipe and an item
			if game.item_prototypes[entity.name] and game.recipe_prototypes[entity.name] and not ignore[entity.name] then
				--log("Entity geladen: "..entity.name.." mit Typ "..entity.type)
				local dimensions = mm_util.getBoundingBoxDimensions(entity.selection_box)
				local square = true
				-- if an entity hat a non square base, we'll later need two chests for maintenance / repair / overhaul demands, as chests are not rotatable
				if dimensions.width ~= dimensions.height then
					square = false
				end
				-- some entity types have event cycles with increased length
				local timeFactor = 1
				if entity.type == "solar-panel" or entity.type == "accumulator" then
					timeFactor = const.solarCycleTimeMultiplier
				end

				local newElement = {}
				newElement.active = entityTypesWithMROenabled[entity.type]
				newElement.maintenance = initMaintenanceDemandsTable(entity.name, timeFactor)
				newElement.repair = initRepairDemandsTable(entity.name, timeFactor)
				newElement.scrap = {["mm-scrapped-"..entity.name] = 1}
				newElement.replacement = {[entity.name] = 1}
				newElement.flyingTextShiftY = entity.collision_box.left_top.y/2 -- this will place the flying text more on top of the entity
				newElement.square = square
				newElement.timeFactor = timeFactor
				global.entitiesWithMROenabled[entity.name] = newElement
				--log(serpent.block(global.entitiesWithMROenabled[entity.name], {maxlevel= 4}))
			end
		end
    end
    if const.lowTechModifierEnabled then
        for _, force in pairs(game.forces) do
            initLowTechModifierCalculation(force.index)
            calculateLowTechModifier(force.index, true)
        end
    end
    --log(serpent.block(global.entitiesWithMROenabled, {maxlevel= 4}))
end

-- get or init persistent data tables
function init_global()

	initAuxTables()

    global.eventScheduleMRO = global.eventScheduleMRO or {}
		-- Master schedule table: Tracks all events
		-- Indexed by tick

	global.monitoredEntities = global.monitoredEntities or {}
		-- List of all entities which need to be maintained
        -- Indexed by unit number

	global.maintenanceUnits = global.maintenanceUnits or {}
		-- List of all maintenance units
		-- Indexed by unit number

	global.activeChests = global.activeChests or {}
		-- List of all active chests
		-- Indexed by unit number

    global.lowTechModifier = global.lowTechModifier or {}
        -- Table of researched techs and unit counts to calculate the low tech initLowTechModifierCalculation
        -- Indexed by force number

    global.forceBonus = global.forceBonus or {}
        -- Table of boni gained by researching certain techs for each force.
        -- Indexed by force number

	global.last_selected = global.last_selected or {}
		-- Used to track render objects per player
		-- Indexed by player number

	global.maintenanceControl = global.maintenanceControl or {}
		-- Used to track force specific settings regarding enabled or disabled maintenance/repair materials
		-- Indexed by force number

	global.temporaryMaintenanceControl = global.temporaryMaintenanceControl or {}
		-- Used to track temporary player specific instances of maintenance settings until they confirm their changes
		-- Indexed by player number

	global.changedControlSettings = global.changedControlSettings or {}

	global.userInterface = global.userInterface or {}

	mmGUI.toggleMainButton()
end

-- calculate the demands for an maintenance or repair event for this entity
-- returns two tables:
-- 1: the demand broadcasted to the logistic network, in compliance to the current item use policy of this force
-- 2: the real demand, including items that are currently not allowed for use
-- if no policy is given, all items are allowed
local function calculateDemands(policy, source)
	--log(serpent.block(global.entitiesWithMROenabled[entityName].repair, {maxlevel= 4}))
	local resultTable = {}
	local resultTableReal = {}
	local defaultTable = {}
	local defaultTableReal = {}

	for item, itemData in pairs (source) do
		if itemData.defaultItem then
			if not policy or policy[item].enabled then
				defaultTable[item] = rand(itemData.min_amount, itemData.max_amount)
				defaultTableReal[item] = defaultTable[item]
			else
				defaultTableReal[item] = rand(itemData.min_amount, itemData.max_amount)
			end
		elseif itemData.probability == 1 or rand() < itemData.probability then
			if not policy or policy[item].enabled then
				resultTable[item] = rand(itemData.min_amount, itemData.max_amount)
				resultTableReal[item] = resultTable[item]
			else
				resultTableReal[item] = rand(itemData.min_amount, itemData.max_amount)
			end
		end
	end
	if mm_util.getLength(resultTable) == 0 then
		return defaultTable, defaultTableReal
	else
		return resultTable, resultTableReal
	end
end

-- check, if the item demand for a given entity has been fulfilled
local function checkCompletedDemands(chest, requestedItems)
	local percentage = 0.00
	local p = 0.00
	local deliveredItems = chest.get_inventory(defines.inventory.chest).get_contents()
	--local requestedItems = global.monitoredEntities[entityID].requestedItems
	local distinctItems = 0
	for _, amount in pairs(requestedItems) do
		-- count different items
		distinctItems = distinctItems + 1
	end
	-- calculate the percentage of the demand fulfillment
	for item, amount in pairs(requestedItems) do
		if deliveredItems[item] ~= nil then
			p = (deliveredItems[item] / amount) / distinctItems
		else
			p = 0
		end
		percentage = percentage + p
	end
	return percentage
end

-- all items in the given chest will be counted as "consumption" in the production tab
function postItemsAsConsumption(chest)
	local inventory = chest.get_inventory(defines.inventory.chest)
	local contents = inventory.get_contents()
	for name, amount in pairs(contents) do
		chest.force.item_production_statistics.on_flow(name, -amount)
	end
	inventory.clear()
end

-- set up the next event for a given entity in the event schedule
local function scheduleNextEvent(eventTick, elementData)
	if global.eventScheduleMRO[eventTick] == nil then
		-- insert first element for this tick
		--global.eventScheduleMRO[eventTick] = {}
		--global.eventScheduleMRO[eventTick].elements = {elementData}
		global.eventScheduleMRO[eventTick] = {elementData}
	else
		-- add another element
		--global.eventScheduleMRO[eventTick].elements[#global.eventScheduleMRO[eventTick].elements + 1] = elementData
		global.eventScheduleMRO[eventTick][#global.eventScheduleMRO[eventTick] + 1] = elementData
	end
end

-- replace a surrogate entity (faulty version of an accumulator or a solar panel) with its original entity
function swapOldMachine(entity)
	local machine = entity
	local targetReference = global.monitoredEntities[machine.unit_number]
	local newOperableEntity = machine.surface.create_entity{
		name = targetReference.surrogatedEntityName,
		position = machine.position,
		force = machine.force,
		create_build_effect_smoke = false}
	if newOperableEntity.valid then
		newOperableEntity.energy = machine.energy
		if machine.health > 0 then
			newOperableEntity.health = machine.health
		end
		if machine.to_be_deconstructed(machine.force) then newOperableEntity.order_deconstruction(machine.force) end
		local newtargetReference = targetReference
		newtargetReference.surrogatedEntityName = nil
		newtargetReference.entity = newOperableEntity
		newtargetReference.ageing = targetReference.ageing
		newtargetReference.status = targetReference.status
		global.monitoredEntities[newOperableEntity.unit_number] = newtargetReference
		targetReference = global.monitoredEntities[newOperableEntity.unit_number]
		global.monitoredEntities[machine.unit_number] = nil
		machine.destroy()
		machine = targetReference.entity
	end
	return machine
end

local function collisionTest(rec1, rec2)
	local A1x = rec1.left_top.x or rec1.left_top[1] or rec1[1].x or rec1[1][1]
	local A1y = rec1.left_top.y or rec1.left_top[2] or rec1[1].y or rec1[1][2]
	local A2x = rec1.right_bottom.x or rec1.right_bottom[1] or rec1[2].x or rec1[2][1]
	local A2y = rec1.right_bottom.y or rec1.right_bottom[2] or rec1[2].y or rec1[2][2]

	local B1x = rec2.left_top.x or rec2.left_top[1] or rec2[1].x or rec2[1][1]
	local B1y = rec2.left_top.y or rec2.left_top[2] or rec2[1].y or rec2[1][2]
	local B2x = rec2.right_bottom.x or rec2.right_bottom[1] or rec2[2].x or rec2[2][1]
	local B2y = rec2.right_bottom.y or rec2.right_bottom[2] or rec2[2].y or rec2[2][2]

	if B2x > A1x and B1x < A2x and A2y > B1y and A1y < B2y then
		return true
	else
		return false
	end
end

function getNeighboringMachines(entity, byPlayerIndex, customUnitName, customAoE)
	local areaOfEffect
	local quareRadius
	if byPlayerIndex == nil then
		areaOfEffect = global.maintenanceUnits[entity.unit_number].areaOfEffect
		quareRadius = const.maintenanceUnits[entity.name].radius + 7
	else
		areaOfEffect = customAoE
		quareRadius = const.maintenanceUnits[customUnitName].radius + 7
		entity = game.players[byPlayerIndex]
	end
	local position = entity.position
	local searchArea = {left_top = {position.x - quareRadius, position.y - quareRadius}, right_bottom = {position.x + quareRadius, position.y + quareRadius}}
	local surroundingEntities = entity.surface.find_entities_filtered{area = searchArea, force = entity.force, collision_mask = "object-layer"}
	local machines = {}
	for _, candidate in pairs(surroundingEntities) do
		if candidate.unit_number and global.monitoredEntities[candidate.unit_number] then
			if collisionTest(areaOfEffect, candidate.bounding_box) then
				machines[#machines+1] = candidate.unit_number
			end
		end
	end
	return machines
end

local function getNeighboringMaintenanceUnits(entityID)
	local entity = global.monitoredEntities[entityID].entity
	local boundingBox = entity.bounding_box
	local dimensions = mm_util.getBoundingBoxDimensions(boundingBox)
	local quareRadius = mmax(dimensions.height, dimensions.width) / 2 + const.mUnitMaxRadius
	local position = entity.position
	local searchArea = {left_top = {position.x - quareRadius, position.y - quareRadius}, right_bottom = {position.x + quareRadius, position.y + quareRadius}}
	local surroundingEntities = entity.surface.find_entities_filtered{area = searchArea, force = entity.force, collision_mask = "object-layer"}
	local mUnits = {}
	for _, candidate in pairs(surroundingEntities) do
		if candidate.unit_number and global.maintenanceUnits[candidate.unit_number] then
			local areaOfEffect = global.maintenanceUnits[candidate.unit_number].areaOfEffect
			if collisionTest(areaOfEffect, boundingBox) then
				mUnits[#mUnits+1] = candidate.unit_number
			end
		end
	end
	return mUnits
end

local function checkAndUpdateMaintenanceUnits(entityID)
    local mUnits = getNeighboringMaintenanceUnits(entityID)
	for _, mUnitID in pairs(mUnits) do
		local mUnitReference = global.maintenanceUnits[mUnitID]
		local new = true
		local index = #mUnitReference.connectedMachines + 1
		for i, machineID in pairs(mUnitReference.connectedMachines) do
			if machineID == entityID then
				new = false
				index = i
				break
			end
		end
		if new then
			mUnitReference.connectedMachines[index] = entityID
		else
			table.remove(mUnitReference.connectedMachines, index)
		end
		global.maintenanceUnits[mUnitID] = mUnitReference
    end
    if #mUnits > 0 then
        return mUnits -- will be used by new machines to register wich MUs are connected to them
    else
        return nil
    end
end

local function createHiddenChest(machineData, machineProperties)
	local chestType = "mm-chest-"
	local machine = machineData.entity
	local machineName = machineData.surrogatedEntityName or machine.name
	if not machineProperties.square and (machine.direction == defines.direction.east or machine.direction == defines.direction.west) then
		chestType = "mm-chest-rotated-"
	end
	local chest = machine.surface.create_entity{
		name = chestType..machineName,
		position = machine.position,
		force = machine.force,
		create_build_effect_smoke = false}
	chest.operable = false
	chest.destructible = false
	machine.teleport(machine.position) -- a hacky way to put the machine above the invisible chest (otherwise inserters are able to access the chest), while maintaining the same unit_number
	global.activeChests[chest.unit_number] = machine.unit_number -- register this chest. This allows backtracking form proxy -> chest -> machine
	return chest
end

local function initActivityTracking(entity)
	local activityData
	local type = entity.type
	if type == "mining-drill" then
		activityData = entity.mining_progress
	elseif type == "lab" then
		activityData = {}
		local inventory = entity.get_inventory(defines.inventory.lab_input)
		for i = 1, #inventory do
			local stack = inventory[i]
			if stack ~= nil and stack.valid_for_read then
				--game.print(stack.name)
				activityData[i] = stack.durability
			else
				activityData[i] = 1
			end
		end
	elseif type == "generator" then
		if entity.energy_generated_last_tick > 0 then
			activityData = true
		else
			activityData = false
		end
	elseif type == "boiler" then
		local burner = entity.burner
		if burner then
			activityData = burner.remaining_burning_fuel
		end
	elseif type == "reactor" then
		local burner = entity.burner
		if burner then
			activityData = burner.remaining_burning_fuel
		end
	end
	return activityData
end

local function entityWasActive(entityID)
    -- check if this entity was active during the last maintenance interval
	-- because this information is only trivial to get for type "craftingMachine", this function provides some workarounds for other entity types
	local entityData = global.monitoredEntities[entityID]
    local machine = entityData.entity
	local type = machine.type
	local lastValue = entityData.activityData
	if type == "mining-drill" then
		-- check if the mining progress changed
		local newValue = machine.mining_progress
		if lastValue ~= newValue then
			global.monitoredEntities[entityID].activityData = newValue
			return true
		end
	elseif type == "lab" then
		-- check if the durability of the items changed
		local inventory = machine.get_inventory(defines.inventory.lab_input)
		local difference = false
        if not lastValue then -- hotfix related, temporary safety check. remove after version 0.9.12
            lastValue = initActivityTracking(machine)
        end
		for i = 1, #inventory do
			local stack = inventory[i]
			if stack ~= nil and stack.valid_for_read then
				if lastValue[i] ~= stack.durability then
					difference = true
					--game.print((lastValue[i] or "?").." <-> "..stack.durability)
					break
				end
			else
				if lastValue[i] ~= 1 then
					difference = true
					break
				end
			end
		end
		local newValue = {}
		if difference then
			for i = 1, #inventory do
				local stack = inventory[i]
				if stack ~= nil and stack.valid_for_read then
					newValue[i] = stack.durability
				else
					newValue[i] = 1
				end
			end
			global.monitoredEntities[entityID].activityData = newValue
			return true
		end
	elseif type == "generator" then
		local newValue = false
		if machine.energy_generated_last_tick > 0 then
			newValue = true
			-- if a generator produces energy, this is sufficient to count as "active" for two subsequent intervals
			global.monitoredEntities[entityID].activityData = newValue
			return true
		elseif lastValue then
			-- generator did not produce energy this time, but in its last interval: still counts as "active"
			global.monitoredEntities[entityID].activityData = newValue
			return true
		end
	elseif type == "boiler" then
		local burner = machine.burner
		local temperature = machine.temperature
		if burner then
			if burner.remaining_burning_fuel ~= lastValue then
				global.monitoredEntities[entityID].activityData = burner.remaining_burning_fuel
				return true
			end
		elseif temperature then
			-- heat exchanger : Active whenever their working temperature is above their target temperature (thermal stress)
			if temperature > machine.prototype.target_temperature then
				return true
			end
		end
	elseif type == "reactor" then
		local burner = machine.burner
		if burner then
			if burner.remaining_burning_fuel ~= lastValue then
				global.monitoredEntities[entityID].activityData = burner.remaining_burning_fuel
				return true
			end
		end
	end
	return false
end

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
	local MROdata = global.entitiesWithMROenabled[entityName]
	local element = {}
	element.maintenance = {}
	element.repair = {}
	element.replacement = {}

	for itemName, data in pairs(MROdata.maintenance["level-1"]) do
		element.maintenance[itemName] = {}
		element.maintenance[itemName].enabled = true
	end
	for itemName, data in pairs(MROdata.repair["level-1"].secondary) do
		element.repair[itemName] = {}
		element.repair[itemName].enabled = true
	end
	element.replacement.start = const.replacementAge
	element.replacement.limit = const.maxOperationAge -- later used to stop machines that are extremely old and in danger of destruction

	global.maintenanceControl[forceID].byEntity[entityName] = element
end

local function updateEntityControlEntry(forceID, entityName)
	local MROdata = global.entitiesWithMROenabled[entityName]
	local old = global.maintenanceControl[forceID].byEntity[entityName]
	local new = {}
	new.maintenance = {}
	new.repair = {}
	new.replacement = old.replacement  -- no changes needed

	for itemName, data in pairs(MROdata.maintenance["level-1"]) do
		-- if new items got added, add them to the control table, otherwise use the previous values
		-- if items got removed, they will simply be discarded
		if old.maintenance[itemName] ~= nil then
			new.maintenance[itemName] = old.maintenance[itemName]
		else
			new.maintenance[itemName] = {}
			new.maintenance[itemName].enabled = true
		end
	end
	for itemName, data in pairs(MROdata.repair["level-1"].secondary) do
		-- if new items got added, add them to the control table, otherwise use the previous values
		-- if items got removed, they will simply be discarded
		if old.repair[itemName] ~= nil then
			new.repair[itemName] = old.repair[itemName]
		else
			new.repair[itemName] = {}
			new.repair[itemName].enabled = true
		end
	end
	global.maintenanceControl[forceID].byEntity[entityName] = new
end

local function updateMaintanceControlSettings()
	for _, force in pairs(game.forces) do
		local control = global.maintenanceControl[force.index]
		if control ~= nil then
			for entityName, entity in pairs(control.byEntity) do
				updateEntityControlEntry(force.index, entityName)
			end
		end
	end
end

local function requestGuiUpdate(forceID)
	for _, player in pairs(game.forces[forceID].players) do
		if not global.userInterface[player.index] then
			global.userInterface[player.index] = {}
		end
		global.userInterface[player.index].updateRequest = true
	end
end

-- start the maintenance cycle for a new entity
local function initLifeCycle(entity, startMaintenanceInstantly)
	if entity and entity.valid then
		local entityID = entity.unit_number
		local entityType = entity.type
		local entityProperties = global.entitiesWithMROenabled[entity.name]
		local forceID = entity.force.index
		local nextTick = 0
		local eventTick = 0
		local bonusCycles = const.freeCycles
		--log(bonusCycles)
		if startMaintenanceInstantly then
			-- Start Maintenance instantly for all machines.
			-- The initial amount of machines needing maintenance is low but continuously increasing.
			-- This is to reduce the "nothing happens, does this mod do anything at all"-feeling if this mod is added to a running game.
			nextTick = rand(mfloor(const.MTBM/10), mfloor(const.MTBM * 1,5 * bonusCycles))
			eventTick = game.tick + mfloor(entityProperties.timeFactor * nextTick)
			bonusCycles = 0
		else
			nextTick = rand(mfloor(const.MTBM/2), mfloor(const.MTBM*1,5))
			eventTick = game.tick + mfloor(entityProperties.timeFactor * nextTick)
		end

		if checkControlTable(forceID, entity.name) then
			addEntityToControlTable(forceID, entity.name)
		end
		requestGuiUpdate(forceID)

		scheduleNextEvent(eventTick, {id = entityID, type = "machine"})

		global.monitoredEntities[entityID] = {
			entity = entity,
			ageing = 0,
			status = "operating",
			bonusCyclesRemaining = bonusCycles,
			connectedChest = nil, 			-- Later used to track connected chests
            connectedProxy = nil, 			-- Later used to track item request proxies of connected chests
            connectedMUnits = nil,          -- Later used to track maintenance units that provide items to this machine
			requestedItems = nil, 			-- Later used to track the requested items that the connected item request proxy ordered
			creationTick = game.tick, 		-- Needed to track machine life time (for statistical purposes)
			nextEventTick = eventTick, 		-- Tracks next event tick
			timeToRepair = nil,				-- How many ticks this machine will need to wait until becoming operational again.
			repairTimeElapsed = nil,		-- This is needed to keep track of the time between different events in order to update the repair time
			repairEffectivity = nil,		--
			serviceRequests = 0, 			-- How many times has this machine been serviced in its current life cycle?
			serviceLevel = 0, 				-- How good has this machine been serviced on average in its current life cycle?
			upgrades = { 					-- Well maintaned machines will get bonuses that improve speed and reduce energy consumption as well as pollution
				energyBonusLevel = 0,
				speedBonusLevel = 0,
                pollutionReductionLevel = 0}}

        global.monitoredEntities[entityID].connectedMUnits = checkAndUpdateMaintenanceUnits(entityID)

		-- check if this is a crafting machine: Add the "producedItems" property that is used to determine if a machine was at least once active in a maintenance interval.
		-- If not this entity's age is increased only a bit.
		if entityType == "assembling-machine" or entityType == "furnace" then
			global.monitoredEntities[entityID].producedItems = 0 -- This is only tracked for those entities that support products_finished.
		elseif const.alternativeActivityTracking[entityType] then
			global.monitoredEntities[entityID].activityData = initActivityTracking(entity)
		end


		--game.print("Neues Objekt in Liste. Nächste Aktion in "..(mfloor(nextTick/60)).."s")
	end
end

local function setAreaOfEffect(boundingBox, radius)
	local A1x = boundingBox.left_top.x or boundingBox.left_top[1] or boundingBox[1].x or boundingBox[1][1]
	local A1y = boundingBox.left_top.y or boundingBox.left_top[2] or boundingBox[1].y or boundingBox[1][2]
	local A2x = boundingBox.right_bottom.x or boundingBox.right_bottom[1] or boundingBox[2].x or boundingBox[2][1]
	local A2y = boundingBox.right_bottom.y or boundingBox.right_bottom[2] or boundingBox[2].y or boundingBox[2][2]
	return {left_top = {x = A1x - radius, y = A1y - radius}, right_bottom = {x = A2x + radius, y = A2y + radius}}
end

function registerMaintenanceUnit(entityID, mUnitID)
    if entityID == nil or global.monitoredEntities[entityID] == nil then
		return
	end
	local targetReference = global.monitoredEntities[entityID]
	local machine = targetReference.entity
    if machine and machine.valid then
        local connectedUnits = targetReference.connectedMUnits
        if connectedUnits then
            for k, id in pairs(connectedUnits) do
                if id == mUnitID then
                    return
                end
            end
            connectedUnits[#connectedUnits+1] = mUnitID
        else
            connectedUnits = {mUnitID}
        end
        targetReference.connectedMUnits = connectedUnits
    end
end

-- add a new maintenance unit to the table
local function initMaintenanceUnit(entity)
	if entity and entity.valid then
		local entityID = entity.unit_number
		local properties = const.maintenanceUnits[entity.name]
		local nextTick = rand(mfloor(const.MTTM / (2 * properties.updateRate)), mfloor(const.MTTM * (1.5 / properties.updateRate))) -- update rate is dependent on MTTM
		local eventTick = game.tick + nextTick

        scheduleNextEvent(eventTick, {id = entityID, type = "maintenance-unit"})

		global.maintenanceUnits[entityID] = {
			entity = entity,
			areaOfEffect = setAreaOfEffect(entity.bounding_box, properties.radius),
			connectedMachines = {},	-- All machines that are monitored by this unit, tracked via unit_number
			connectedEEI = entity.surface.create_entity{
				name = entity.name.."-electric-energy-interface",
				position = entity.position,
				force = entity.force,
				create_build_effect_smoke = false},
			nextEventTick = eventTick	-- Tracks next event tick
		}
		local connectedMachines = getNeighboringMachines(entity)

        if connectedMachines ~= nil then
            for k, machineID in pairs(connectedMachines) do
                registerMaintenanceUnit(machineID, entityID)
            end
        end
        global.maintenanceUnits[entityID].connectedMachines = connectedMachines
	end
end

local function startMaintenance(entityID)
	--game.print("Beginne Wartung von Maschine...")
	if entityID == nil or global.monitoredEntities[entityID] == nil then
		return
	end
	local targetReference = global.monitoredEntities[entityID]
	local machine = targetReference.entity
	if machine and machine.valid then
		-- safety catch
		if targetReference.surrogatedEntityName then
			machine = swapOldMachine(machine)
		end
		local machineProperties = global.entitiesWithMROenabled[machine.name]

		targetReference.status = "maintenance"
		targetReference.connectedChest = createHiddenChest(targetReference, machineProperties)
		local targetChest = targetReference.connectedChest

		local requestedItems, actualRequestedItems = calculateDemands(global.maintenanceControl[machine.force.index].byEntity[machine.name].maintenance, machineProperties.maintenance[const.maintenanceLevel])
		if mm_util.getLength(requestedItems) > 0 then
			targetReference.connectedProxy = machine.surface.create_entity{
				name = "mm-maintenance-request-proxy",
				position = targetChest.position,
				target = targetChest,
				force = targetChest.force,
				modules = requestedItems}
		end
		targetReference.requestedItems = actualRequestedItems


		local checkForCompletionTick = game.tick +  (rand(mfloor(const.MTTM/2), mfloor(const.MTTM*1,5))) -- this value is not multiplied with timeFactor!
		targetReference.nextEventTick = checkForCompletionTick

		global.monitoredEntities[entityID] = targetReference
		scheduleNextEvent(checkForCompletionTick, {id = entityID, type = "machine"})
		--game.print("Wartung gestartet. Nächste Aktion in "..(math.floor((checkForCompletionTick - game.tick)/60)).."s")
	end
end

local function finishMaintenance(entityID)
	if entityID == nil or global.monitoredEntities[entityID] == nil then
		return
	end
	local targetReference = global.monitoredEntities[entityID]
	local machine = targetReference.entity
	if machine and machine.valid then
		targetReference.status = "operating"
		local machineProperties = global.entitiesWithMROenabled[machine.name]
		local targetChest = targetReference.connectedChest
		local missedMaintenanceMalus = const.maxMissedMaintenanceMalus
		local maintenanceCompletion = 0
		if targetChest and targetChest.valid then
            maintenanceCompletion = checkCompletedDemands(targetChest, targetReference.requestedItems)
            if targetReference.connectedMUnits ~= nil then
                local forceID = machine.force.index
                local forceBonus = global.forceBonus[forceID] and global.forceBonus[forceID].basicMaintenanceBonus or 0
                -- apply force specific tech bonus
                maintenanceCompletion = forceBonus + maintenanceCompletion * (1 - forceBonus)
            end
			missedMaintenanceMalus = missedMaintenanceMalus * (1 - maintenanceCompletion)
			postItemsAsConsumption(targetChest)
			global.activeChests[targetChest.unit_number] = nil
			targetChest.destroy()
			targetReference.requestedItems = nil
			targetReference.connectedChest = nil
			targetReference.connectedProxy = nil
		end

		targetReference.serviceRequests = targetReference.serviceRequests + 1
		targetReference.serviceLevel = (targetReference.serviceLevel * (targetReference.serviceRequests - 1)) / targetReference.serviceRequests + maintenanceCompletion / targetReference.serviceRequests

		-- increase ageing -> increased probability for failures
		local newAgeing = targetReference.ageing + machineProperties.timeFactor * (const.baseAgeing + missedMaintenanceMalus)
		targetReference.ageing = newAgeing

		if const.showText then
			local color = mm_util.calculateTextColor(textColors.maintenance.min, textColors.maintenance.delta, maintenanceCompletion)
			local textPos = {x = machine.position.x, y = machine.position.y + machineProperties.flyingTextShiftY}
			machine.surface.create_entity{name = "mm-flying-text", position = textPos, text = {"mm-flying-text-maintenance-finished", math.floor(maintenanceCompletion*100)}, color = color, force = machine.force}
		end

		local eventTick = game.tick + mfloor(machineProperties.timeFactor * (rand(mfloor(const.MTBM/2), mfloor(const.MTBM*1.5))))
		targetReference.nextEventTick = eventTick

		global.monitoredEntities[entityID] = targetReference
		scheduleNextEvent(eventTick, {id = entityID, type = "machine"})
	end
end

local function causeFailure(entityID, entityActive)
	if entityID == nil or global.monitoredEntities[entityID] == nil then
		return
	end
	local targetReference = global.monitoredEntities[entityID]
	local machine = targetReference.entity
	local machineSwapped = false -- if the machine has been swapped within this function, tell the calling procedure the new id to update its reference to the new machine
	if machine and machine.valid then
        local damageFactor = rand() * const.maxDamageFactor * (targetReference.ageing / const.maxAge)
        local force = machine.force
		if not entityActive then
			-- idle machines only suffer 50% (default value) of the extra damage
			damageFactor = const.baseDamageFactor + damageFactor * const.idleFailureDamageFactor
		else
			damageFactor = const.baseDamageFactor + damageFactor
		end
		machine.damage(mfloor(machine.prototype.max_health * damageFactor), force)
		if not machine.valid then
			global.monitoredEntities[entityID] = nil
			return -- machine has been killed by damage
		end

		--- solar panels or accumulators wont stop working if set to active = false. They need to be replaced by "broken" versions of themselves
		if machine.type == "solar-panel" or machine.type == "accumulator" and (#machine.circuit_connected_entities.red + #machine.circuit_connected_entities.green) == 0 then
			--log(serpent.block(targetReference, {maxlevel= 4}))
			--log(entityID)
			local newFaultyEntity = machine.surface.create_entity{
				name = "mm-faulty-"..machine.name,
				position = machine.position,
				force = force,
				create_build_effect_smoke = false}
			newFaultyEntity.health = machine.health
			newFaultyEntity.energy = machine.energy
			if machine.to_be_deconstructed(force) then newFaultyEntity.order_deconstruction(machine.force) end
			local newtargetReference = targetReference
			newtargetReference.surrogatedEntityName = machine.name
			newtargetReference.entity = newFaultyEntity
			newtargetReference.ageing = targetReference.ageing
			newtargetReference.status = targetReference.status
			global.monitoredEntities[newFaultyEntity.unit_number] = newtargetReference
			targetReference = global.monitoredEntities[newFaultyEntity.unit_number]
			global.monitoredEntities[entityID] = nil
			machine.destroy()
			machine = targetReference.entity
			entityID = newFaultyEntity.unit_number
			--log(serpent.block(targetReference, {maxlevel= 4}))
			--log(entityID)
			-- TODO: Netzwerk-Verbindungen wiederherstellen > nicht möglich.
			machineSwapped = true
		end
		targetReference.status = "malfunction"
		local machineName = targetReference.surrogatedEntityName or machine.name -- get name of surrogated machine (in case of solar panel or accumulator) or otherwise real machine name
		local machineProperties = global.entitiesWithMROenabled[machineName]

		machine.active = false
		machine.rotatable = false

		targetReference.connectedChest = createHiddenChest(targetReference, machineProperties)
		local targetChest = targetReference.connectedChest

		-- primary items: Necessary to start repair
		local requestedPrimaryItems = calculateDemands(false, machineProperties.repair[const.maintenanceLevel].primary)
		targetReference.connectedProxy = machine.surface.create_entity{name = "mm-repair-request-proxy", position = targetChest.position, target = targetChest, force = targetChest.force, modules = requestedPrimaryItems}
		targetReference.requestedItems = requestedPrimaryItems
		machine.surface.play_sound{path = "mm-machine-failure-sound", position = machine.position, volume_modifier = 0.75}

        local timeToRepair = mfloor(machineProperties.timeFactor * (const.MTTR + (const.MTTR * const.repairTimeModifier * targetReference.ageing / const.maxAge)))
        if const.lowTechModifierEnabled then
            -- early game bonus: reduced repair time
            timeToRepair = mfloor(timeToRepair * global.lowTechModifier[force.index].factor)
        end

		targetReference.timeToRepair = timeToRepair
		targetReference.repairTimeElapsed = 0 -- this is needed to keep track of the time between different events in order to update the time still needed to repair
        targetReference.repairEffectivity = const.baseRepairEffectivity
        if targetReference.connectedMUnits ~= nil then
            -- if connected to a maintenance unit, check if force tech boni have to be applied
            targetReference.repairEffectivity = targetReference.repairEffectivity + (global.forceBonus[force.index] and global.forceBonus[force.index].basicRepairSpeedBonus or 0)
        end

		-- add an icon that is hidden until the requester icon is removed by fulfilling the request
		if machine.type == "solar-panel" or machine.type == "accumulator" then
			if const.showMIPsignForSolar then
				targetReference.renderedIconID = rendering.draw_sprite{
				sprite = "repair-pending-icon",
				render_layer = "entity-info-icon",
				target = targetReference.connectedChest,
				target_offset = machine.prototype.alert_icon_shift or {0, 0},
				surface = machine.surface,
				forces = {machine.force}}
			end
		else
			targetReference.renderedIconID = rendering.draw_sprite{
				sprite = "repair-pending-icon",
				render_layer = "entity-info-icon",
				target = targetReference.connectedChest,
				target_offset = machine.prototype.alert_icon_shift or {0, 0},
				surface = machine.surface,
				forces = {machine.force}}
		end

		if const.showText then
			local textPos = {x = machine.position.x, y = machine.position.y + machineProperties.flyingTextShiftY}
			machine.surface.create_entity{name = "mm-flying-text", position = textPos, text = {"mm-flying-text-failure"}, color = textColors.failure, force = machine.force}
		end

		local tickDelayBetweenRepairChecks = mfloor(machineProperties.timeFactor * const.tickDelayCheckRepairState)
		local nextEventTick = game.tick + tickDelayBetweenRepairChecks

		targetReference.nextEventTick = nextEventTick
		--targetReference.timeUntilNextEvent = tickDelayBetweenRepairChecks -- this is needed to keep track of the time between different events in order to update the time still needed to repair

		global.monitoredEntities[entityID] = targetReference
		scheduleNextEvent(nextEventTick, {id = entityID, type = "machine"})
		--game.print("Maschine hat Fehlfunktion. Nächste Aktion in "..(math.floor(const.MTTR/60)).."s")
		if machineSwapped then
			return entityID
		else
			return false
		end
	end
end

local function startRepair(entityID)
	if entityID == nil or global.monitoredEntities[entityID] == nil then
		return
	end
	local targetReference = global.monitoredEntities[entityID]
	local machine = targetReference.entity
	if machine and machine.valid then
		local nextEventTick = 0
		local machineName = targetReference.surrogatedEntityName or machine.name -- get name of surrogated machine (in case of solar panel or accumulator) or real machine name
		local machineProperties = global.entitiesWithMROenabled[machineName]
		local targetChest = targetReference.connectedChest
		-- check if all necessary repair items have been delivered
		if targetChest and targetChest.valid then
			if checkCompletedDemands(targetChest, targetReference.requestedItems) >= 1 then
			-- when all materials have been delivered, repair starts
				postItemsAsConsumption(targetChest)
				targetReference.connectedProxy = nil

				-- set up request proxy for secondary items: These materials are not needed, but will speed up repair
				----global.maintenanceControl[forceID].byEntity[entityName].repair
				local requestedSecondaryItems, actualRequestedSecondaryItems = calculateDemands(global.maintenanceControl[machine.force.index].byEntity[machineName].repair, machineProperties.repair[const.maintenanceLevel].secondary)
				if mm_util.getLength(requestedSecondaryItems) > 0 then
					targetReference.connectedProxy = machine.surface.create_entity{
						name = "mm-secondary-repair-request-proxy",
						position = targetChest.position,
						target = targetChest,
						force = targetChest.force,
						modules = requestedSecondaryItems}

					-- remove the "repair pending" icon
					local iconID = targetReference.renderedIconID
					if iconID and rendering.is_valid(iconID) then
						rendering.destroy(iconID)
						targetReference.renderedIconID = nil
					end

					-- add an icon that is hidden until the requester icon is removed by fulfilling the request
					if machine.type == "solar-panel" or machine.type == "accumulator" then
						if const.showMIPsignForSolar then
							rendering.draw_animation{
								animation = "repair-in-progress-icon",
								render_layer = "entity-info-icon",
								target = targetReference.connectedChest,
								target_offset = machine.prototype.alert_icon_shift or {0, 0},
								surface = machine.surface,
								forces = {machine.force}}
						end
					else
						rendering.draw_animation{
								animation = "repair-in-progress-icon",
								render_layer = "entity-info-icon",
								target = targetReference.connectedChest,
								target_offset = machine.prototype.alert_icon_shift or {0, 0},
								surface = machine.surface,
								forces = {machine.force}}
					end
				end
				targetReference.requestedItems = actualRequestedSecondaryItems

				targetReference.status = "repair-ongoing"

				timeToRepair = targetReference.timeToRepair
				targetReference.repairTimeElapsed = timeToRepair -- this is evaluated in the next event. It's needed to keep track of the time between different events in order to update the time still needed to repair

				nextEventTick = game.tick + timeToRepair

				--targetReference.timeUntilNextEvent = timeUntilNextEvent
				targetReference.estimatedRepairTick = game.tick + timeToRepair
			else
			-- still waiting for critical items to be delivered
				-- recreate proxy if it got deleted accidentially
				if not targetReference.connectedProxy.valid then
					targetReference.connectedProxy = machine.surface.create_entity{name = "mm-repair-request-proxy", position = targetChest.position, target = targetChest, force = targetChest.force, modules = targetReference.requestedItems}
				end

				if const.showText and rand() < const.showDefectRemainderProb then
					local textPos = {x = machine.position.x, y = machine.position.y + machineProperties.flyingTextShiftY}
					machine.surface.create_entity{name = "mm-flying-text", position = textPos, text = {"mm-flying-text-failure-ongoing"}, color = textColors.failure2, force = machine.force}
				end

				local tickDelayBetweenRepairChecks = mfloor(machineProperties.timeFactor * const.tickDelayCheckRepairState)
				nextEventTick = game.tick + tickDelayBetweenRepairChecks
			end
		end
		targetReference.nextEventTick = nextEventTick

		global.monitoredEntities[entityID] = targetReference
		scheduleNextEvent(nextEventTick, {id = entityID, type = "machine"})
	end
end

local function checkRepairState(entityID)
	if entityID == nil or global.monitoredEntities[entityID] == nil then
		return
	end
	local machineSwapped = false -- if the machine has been swapped within this function, tell the calling procedure the new id to update its reference to the new machine
	local targetReference = global.monitoredEntities[entityID]
	local machine = targetReference.entity
	if machine and machine.valid then
		local eventTick = 0
		local machineName = targetReference.surrogatedEntityName or machine.name -- get name of surrogated machine (in case of solar panel or accumulator) or real machine name
		local machineProperties = global.entitiesWithMROenabled[machineName]
		local targetChest = targetReference.connectedChest
        local baseRepairEffectivity = const.baseRepairEffectivity
        if targetReference.connectedMUnits ~= nil then
            local forceID = machine.force.index
            -- if connected to a maintenance unit, check if force tech boni have to be applied
            baseRepairEffectivity = baseRepairEffectivity + (global.forceBonus[forceID] and global.forceBonus[forceID].basicRepairSpeedBonus or 0)
        end
		if targetChest and targetChest.valid then
			-- check if / how many repair materials have been delivered
			local repairMaterialSupplyRate = checkCompletedDemands(targetChest, targetReference.requestedItems)
			local totalRepairEffectivity = baseRepairEffectivity + (1 - baseRepairEffectivity) * repairMaterialSupplyRate

			local effectiveRepairTime = mfloor(targetReference.repairTimeElapsed * totalRepairEffectivity)
			local remainingRepairTime = targetReference.timeToRepair - effectiveRepairTime
			local estimatedTimeToComplete = mceil(remainingRepairTime / totalRepairEffectivity)

			if remainingRepairTime <= 0 then
			-- repair completed
				postItemsAsConsumption(targetChest)
				global.activeChests[targetChest.unit_number] = nil
				targetChest.destroy()
				targetReference.requestedItems = nil
				targetReference.connectedProxy = nil
				targetReference.connectedChest = nil
				--- solar panels and accumulators have been replaced by broken versions - these entities must be swapped back :
				if targetReference.surrogatedEntityName then
					machine = swapOldMachine(machine)
					entityID = machine.unit_number
					machineSwapped = true
				end
				targetReference.timeToRepair = nil
				targetReference.repairTimeElapsed = nil
				targetReference.repairEffectivity = nil
				targetReference.ageing = targetReference.ageing + machineProperties.timeFactor * const.repairAgeMalus
				targetReference.status = "operating"
				machine.active = true
				machine.rotatable = true

				if const.showText then
					local textPos = {x = machine.position.x, y = machine.position.y + machineProperties.flyingTextShiftY}
					machine.surface.create_entity{name = "mm-flying-text", position = textPos, text = {"mm-flying-text-machine-fixed"}, color = textColors.repair, force = machine.force}
				end
				machine.surface.play_sound{path = "mm-machine-fixed-sound", position = machine.position, volume_modifier = 0.75}

				eventTick = game.tick + mfloor(machineProperties.timeFactor * rand(mfloor(const.MTBM/2), mfloor(const.MTBM*1.5)))
			else
			-- repair not completed
				--[[
				-- recreate proxy if it got deleted accidentially
				if not targetReference.connectedProxy.valid then
					targetReference.connectedProxy = machine.surface.create_entity{name = "mm-secondary-repair-request-proxy", position = targetChest.position, target = targetChest, force = targetChest.force, modules = targetReference.requestedItems}
				end]]
				targetReference.repairEffectivity = totalRepairEffectivity
				targetReference.timeToRepair = remainingRepairTime

				local nextCheck = mceil(mmin(mmax(remainingRepairTime, const.tickDelayCheckRepairState), estimatedTimeToComplete))
				-- check this machine again in remainingRepairTime or after the 45 sec (default) tick delay, whatever is bigger. This is to avoid checking it too many times
				-- if the remaining time is very low, then choose this value for the next event tick to avoid overshooting remainingRepairTime

				eventTick = game.tick + nextCheck

				targetReference.repairTimeElapsed = nextCheck
			end
		end
		targetReference.nextEventTick = eventTick

		global.monitoredEntities[entityID] = targetReference
		scheduleNextEvent(eventTick, {id = entityID, type = "machine"})
		if machineSwapped then
			return entityID
		else
			return false
		end
	end
end

function requestReplacementOfOldMachine(entityID)
	if entityID == nil or global.monitoredEntities[entityID] == nil then
		return
	end
	local targetReference = global.monitoredEntities[entityID]
	local machine = targetReference.entity
	local machineProperties = global.entitiesWithMROenabled[machine.name]
	if machine and machine.valid and targetReference.status == "operating" then

		-- safety catch
		if targetReference.surrogatedEntityName then
			machine = swapOldMachine(machine)
		end
		targetReference.connectedChest = createHiddenChest(targetReference, machineProperties)
		local targetChest = targetReference.connectedChest

		local requestedItems = machineProperties.replacement
		targetReference.connectedProxy = machine.surface.create_entity{name = "mm-replacement-request-proxy", position = targetChest.position, target = targetChest, force = targetChest.force, modules = requestedItems}
		targetReference.requestedItems = requestedItems
		targetReference.status = "awaiting-replacement"

		global.monitoredEntities[entityID] = targetReference
		-- No additional event tick needed, as there is already one scheduled
	end
end

local function checkForScrapReturn(entityID)
-- Depending on the age of the mined machine, the player / robot will either get back the machine item, or its scrap version
	if entityID == nil or global.monitoredEntities[entityID] == nil then
		return nil
	end
	local targetReference = global.monitoredEntities[entityID]
	local machine = targetReference.entity
	local name = targetReference.surrogatedEntityName or machine.name
	if machine and machine.valid then
		if targetReference.producedItems and targetReference.producedItems == 0 then
			if (const.maxAgeForFreeReturn * const.maxAge) > targetReference.ageing then
				return nil
			end
		end
		if rand(0, const.maxAge) < (targetReference.ageing * const.scrapReturnRate) then
			return global.entitiesWithMROenabled[name].scrap
		end
	end
	return nil
end

local function checkReplacementSuccess(entityID)
-- This is to check, if the requested replacement machine item has been delivered or not.
	if entityID == nil or global.monitoredEntities[entityID] == nil then
		return
	end
	local targetReference = global.monitoredEntities[entityID]
	local machine = targetReference.entity
	if machine and machine.valid then
		local targetChest = targetReference.connectedChest
		local replacementSupplied = checkCompletedDemands(targetChest, targetReference.requestedItems)
		if replacementSupplied >= 1 then
			postItemsAsConsumption(targetChest)
			targetReference.ageing = 0
			targetReference.serviceRequests = 0
			targetReference.serviceLevel = 0

			local scrap = global.entitiesWithMROenabled[machine.name].scrap
			local returnedItem = nil
			if scrap ~= nil then
				for item, amount in pairs(scrap) do
					returnedItem = machine.surface.create_entity{name = "item-on-ground", position = machine.position, stack = {name = item, count = amount}, force = machine.force}
					if returnedItem.valid then
						returnedItem.order_deconstruction(machine.force)
						machine.force.item_production_statistics.on_flow(item, amount)
					end
				end
			end
		else
			if targetReference.connectedProxy then
				targetReference.connectedProxy.destroy()
			end
		end
		-- In every case, remove the request proxy. It will be recreated again in a later event
		targetReference.status = "operating"
		global.activeChests[targetChest.unit_number] = nil
		targetChest.destroy()

		targetReference.requestedItems = nil
		targetReference.connectedProxy = nil
		targetReference.connectedChest = nil

		global.monitoredEntities[entityID] = targetReference
		-- No additional event tick needed, as there is already one scheduled
	end
end

function forceReplacementOfOldMachine(entityID)
	if entityID == nil or global.monitoredEntities[entityID] == nil then
		return
	end
	local targetReference = global.monitoredEntities[entityID]
	local machine = targetReference.entity
	local machineProperties = global.entitiesWithMROenabled[machine.name]
	if machine and machine.valid and targetReference.status == "operating" then
		-- safety catch
		if targetReference.surrogatedEntityName then
			machine = swapOldMachine(machine)
		end
		--- solar panels or accumulators wont stop working if set to active = false. They need to be replaced by "broken" versions of themselves
		if machine.type == "solar-panel" or machine.type == "accumulator" and (#machine.circuit_connected_entities.red + #machine.circuit_connected_entities.green) == 0 then
			--log(serpent.block(targetReference, {maxlevel= 4}))
			--log(entityID)
			local newFaultyEntity = machine.surface.create_entity{
				name = "mm-faulty-"..machine.name,
				position = machine.position,
				force = machine.force,
				create_build_effect_smoke = false}
			newFaultyEntity.health = machine.health
			newFaultyEntity.energy = machine.energy
			if machine.to_be_deconstructed(machine.force) then newFaultyEntity.order_deconstruction(machine.force) end
			local newtargetReference = targetReference
			newtargetReference.surrogatedEntityName = machine.name
			newtargetReference.entity = newFaultyEntity
			newtargetReference.ageing = targetReference.ageing
			newtargetReference.status = targetReference.status
			global.monitoredEntities[newFaultyEntity.unit_number] = newtargetReference
			targetReference = global.monitoredEntities[newFaultyEntity.unit_number]
			global.monitoredEntities[entityID] = nil
			machine.destroy()
			machine = targetReference.entity
			entityID = newFaultyEntity.unit_number
			--log(serpent.block(targetReference, {maxlevel= 4}))
			--log(entityID)
			-- TODO: Netzwerk-Verbindungen wiederherstellen > nicht möglich.
		end
		machineName = targetReference.surrogatedEntityName or machine.name
		machine.active = false -- stop machine
		machine.rotatable = false

		targetReference.connectedChest = createHiddenChest(targetReference, machineProperties)
		local targetChest = targetReference.connectedChest

		local requestedItems = machineProperties.replacement
		targetReference.connectedProxy = machine.surface.create_entity{name = "mm-forced-replacement-request-proxy", position = targetChest.position, target = targetChest, force = targetChest.force, modules = requestedItems}
		targetReference.requestedItems = requestedItems
		targetReference.status = "replacement-required"

		-- remove the current nextEventTick
		if global.eventScheduleMRO and global.eventScheduleMRO[targetReference.nextEventTick] ~= nil then
			for index, element in ipairs(global.eventScheduleMRO[targetReference.nextEventTick]) do
				if entityID == element.id then
					global.eventScheduleMRO[targetReference.nextEventTick][index] = nil
				end
			end
		end

		if const.showText then
			local textPos = {x = machine.position.x, y = machine.position.y + machineProperties.flyingTextShiftY - 0.9}
			machine.surface.create_entity{name = "mm-flying-text", position = textPos, text = {"mm-flying-text-replacement-max-operation-time-exceeded"}, color = textColors.failure, force = machine.force}
		end

		local tickDelayBetweenReplacmentChecks = mfloor(machineProperties.timeFactor * const.tickDelayCheckRepairState)
		local nextEventTick = game.tick + tickDelayBetweenReplacmentChecks
		targetReference.nextEventTick = nextEventTick

		global.monitoredEntities[entityID] = targetReference
		scheduleNextEvent(nextEventTick, {id = entityID, type = "machine"})
	end
end

local function checkForcedReplacementSuccess(entityID)
-- This is to check, if the requested replacement machine item has been delivered or not.
-- Forced replacement is continued until the request is satisfied
	if entityID == nil or global.monitoredEntities[entityID] == nil then
		return
	end
	local machineSwapped = false -- if the machine has been swapped within this function, tell the calling procedure the new id to update its reference to the new machine
	local targetReference = global.monitoredEntities[entityID]
	local machine = targetReference.entity
	if machine and machine.valid then
		local machineName = targetReference.surrogatedEntityName or machine.name -- get name of surrogated machine (in case of solar panel or accumulator) or real machine name
		local machineProperties = global.entitiesWithMROenabled[machineName]
		local targetChest = targetReference.connectedChest
		local nextEventTick
		if checkCompletedDemands(targetChest, targetReference.requestedItems) >= 1 then
			-- when all materials have been delivered, repair starts
			postItemsAsConsumption(targetChest)
			global.activeChests[targetChest.unit_number] = nil
			targetChest.destroy()
			targetReference.connectedChest = nil
			targetReference.connectedProxy = nil
			targetReference.requestedItems = nil

			targetReference.ageing = 0
			targetReference.serviceRequests = 0
			targetReference.serviceLevel = 0

			--- solar panels and accumulators have been replaced by broken versions - these entities must be swapped back :
			if targetReference.surrogatedEntityName then
				machine = swapOldMachine(machine)
				entityID = machine.unit_number
				machineSwapped = true
			end

			machine.active = true
			machine.rotatable = true
			targetReference.status = "operating"

			local scrap = global.entitiesWithMROenabled[machine.name].scrap
			local returnedItem = nil
			if scrap ~= nil then
				for item, amount in pairs(scrap) do
					returnedItem = machine.surface.create_entity{name = "item-on-ground", position = machine.position, stack = {name = item, count = amount}, force = machine.force}
					if returnedItem.valid then
						returnedItem.order_deconstruction(machine.force)
						machine.force.item_production_statistics.on_flow(item, amount)
					end
				end
			end

			if const.showText then
				local textPos = {x = machine.position.x, y = machine.position.y + machineProperties.flyingTextShiftY}
				machine.surface.create_entity{name = "mm-flying-text", position = textPos, text = {"mm-flying-text-replacement-done"}, color = textColors.repair, force = machine.force}
			end

			-- return to normal operation
			nextEventTick = game.tick + mfloor(machineProperties.timeFactor * rand(mfloor(const.MTBM/2), mfloor(const.MTBM*1.5)))
		else
			-- still waiting for replacement
			-- recreate proxy if it got deleted accidentially
			if not targetReference.connectedProxy.valid then
				targetReference.connectedProxy = machine.surface.create_entity{name = "mm-forced-replacement-request-proxy", position = targetChest.position, target = targetChest, force = targetChest.force, modules = requestedItems}
			end
			if const.showText and rand() < const.showDefectRemainderProb then
				local textPos = {x = machine.position.x, y = machine.position.y + machineProperties.flyingTextShiftY}
				machine.surface.create_entity{name = "mm-flying-text", position = textPos, text = {"mm-flying-text-replacement-not-yet-delivered"}, color = textColors.failure2, force = machine.force}
			end

			local tickDelayBetweenReplacmentChecks = mfloor(machineProperties.timeFactor * const.tickDelayCheckRepairState)
			nextEventTick = game.tick + tickDelayBetweenReplacmentChecks
		end

		targetReference.nextEventTick = nextEventTick

		global.monitoredEntities[entityID] = targetReference
		scheduleNextEvent(nextEventTick, {id = entityID, type = "machine"})
		if machineSwapped then
			return entityID
		else
			return false
		end
	end
end

local function stopMaintenanceCycle(entityID, showText)
-- This function stops maintenance for the given entity
	if entityID == nil or global.monitoredEntities[entityID] == nil then
		return
	end
	local targetReference = global.monitoredEntities[entityID]
	local machine = targetReference.entity
	if machine and machine.valid then
		local eventTick = 0
		local machineName = targetReference.surrogatedEntityName or machine.name -- get name of surrogated machine (in case of solar panel or accumulator) or real machine name
		local targetChest = targetReference.connectedChest
		-- Remove the chest, if present
		if targetChest ~= nil then
			postItemsAsConsumption(targetChest)
			global.activeChests[targetChest.unit_number] = nil
			targetChest.destroy()
			targetReference.requestedItems = nil
			targetReference.connectedProxy = nil
			targetReference.connectedChest = nil
		end
		-- Swap machine, if this was a surrogate
		if targetReference.surrogatedEntityName then
			machine = swapOldMachine(machine)
			entityID = machine.unit_number
		end

        local status = targetReference.status
		if status == "malfunction" or status == "repair-ongoing" or status == "replacement-required" then
			-- Reactivate the machine if it had had a breakdown, is currently under repair or has been shut down
			machine.active = true
			machine.rotatable = true

			-- Tell the player, that this machine has been reset
			if const.showText and showText ~= false then
				local textPos = {x = machine.position.x, y = machine.position.y + global.entitiesWithMROenabled[machineName].flyingTextShiftY}
                if status == "malfunction" or status == "repair-ongoing" then
                    machine.surface.create_entity{name = "mm-flying-text", position = textPos, text = {"mm-flying-text-machine-fixed"}, color = textColors.repair, force = machine.force}
                else
                    machine.surface.create_entity{name = "mm-flying-text", position = textPos, text = {"mm-flying-text-replacement-done"}, color = textColors.repair, force = machine.force}
                end
            end
		end
		-- Remove the entity from the monitoring list
		global.monitoredEntities[entityID] = nil
	end
	return machine
end

local function processRemovedEntity(entityID)
	if entityID ~= nil and global.monitoredEntities[entityID] ~= nil then
		local mEntity = global.monitoredEntities[entityID]
		-- Remove this machine from adjacent maintenance units
		checkAndUpdateMaintenanceUnits(entityID)
		if mEntity.connectedChest ~= nil then
			postItemsAsConsumption(mEntity.connectedChest)
			global.activeChests[mEntity.connectedChest.unit_number] = nil
			mEntity.connectedChest.destroy()
		end
		requestGuiUpdate(mEntity.entity.force.index)
		global.monitoredEntities[entityID] = nil
	end
end

local function deregisterMaintenanceUnit(entityID, mUnitID)
    if entityID == nil or global.monitoredEntities[entityID] == nil then
		return
	end
	local targetReference = global.monitoredEntities[entityID]
	local machine = targetReference.entity
    if machine and machine.valid then
        local connectedUnits = targetReference.connectedMUnits
        if connectedUnits then
            for k, id in pairs(connectedUnits) do
                if id == mUnitID then
                    table.remove(connectedUnits, k)
                    if #connectedUnits == 0 then
                        connectedUnits = nil
                    end
                    return
                end
            end
        end
    end
end

local function processRemovedMaintenanceUnit(entityID)
	if entityID ~= nil and global.maintenanceUnits[entityID] ~= nil then
        local mEntity = global.maintenanceUnits[entityID]
        if mEntity.connectedMachines ~= nil then
            for k, machineID in pairs(mEntity.connectedMachines) do
                deregisterMaintenanceUnit(machineID, entityID)
            end
        end
		if mEntity.connectedEEI ~= nil then
			mEntity.connectedEEI.destroy()
		end
		global.maintenanceUnits[entityID] = nil
	end
end

local function startMaintenanceCycleForExistingEntities(names)
	for _, surface in pairs(game.surfaces) do
		for _, entity in pairs(surface.find_entities_filtered{name = names}) do
			if forcesWithMROdisabled[entity.force] == nil then
				initLifeCycle(entity, true)
			end
		end
	end
end

local function stopMaintenanceCycleForExistingEntities(names)
	for _, surface in pairs(game.surfaces) do
		for _, entity in pairs(surface.find_entities_filtered{name = names}) do
			if forcesWithMROdisabled[entity.force] == nil then
				local entityID = entity.unit_number
				stopMaintenanceCycle(entityID)
				global.monitoredEntities[entityID] = nil
			end
		end
	end
end

local function transferItemsIfAvailable(targetInventory, sourceInventory, requested, item_request_proxy)
	local sourceContents = sourceInventory.get_contents()
	local proxy = item_request_proxy or false
	local remaining = {}
	local remaining_total = 0
	local items_transferred = false

	for requestedItem, requestedAmount in pairs(requested) do
		--game.print("Requested: "..requestedAmount.."x "..requestedItem)
		if sourceContents[requestedItem] then
			--game.print("Available: "..sourceContents[requestedItem])
			if sourceContents[requestedItem] >= requestedAmount then
				sourceInventory.remove({name = requestedItem, count = requestedAmount})
				targetInventory.insert({name = requestedItem, count = requestedAmount})
			elseif sourceContents[requestedItem] > 0 then
				sourceInventory.remove({name = requestedItem, count = sourceContents[requestedItem]})
				targetInventory.insert({name = requestedItem, count = sourceContents[requestedItem]})
				remaining[requestedItem] = requested[requestedItem] - sourceContents[requestedItem]
				remaining_total = remaining_total + remaining[requestedItem]
			end
			items_transferred = true
		else
			remaining[requestedItem] = requested[requestedItem]
			remaining_total = remaining_total + remaining[requestedItem]
		end

	end
	if proxy then
		proxy.item_requests = nil -- this is necessary prior to updating this value, seems to be a bug
		proxy.item_requests = remaining
	end
	if remaining_total == 0 then
		return "fulfilled"
	elseif items_transferred then
		return "reduced"
	else
		return "unchanged"
	end
end

local function checkRepairCapacity(inventory, repairRequested)
	local contents = inventory.get_contents()
	local repairItemUsed
	local repairItemDrained = 0
	local actualRepairCapacity = 0
	for _, repairItem in pairs(const.repairItemPriority) do
		if contents[repairItem] then
			local stack = inventory.find_item_stack(repairItem)
			local toolSpeed = stack.prototype.speed
			local drainAmount = repairRequested / toolSpeed
			local possibleRepairItemDrain = mmin(stack.durability * stack.count, drainAmount)
			local possibleRepairCapacity = possibleRepairItemDrain * toolSpeed
			if possibleRepairCapacity > actualRepairCapacity then
				repairItemUsed = repairItem
				repairItemDrained = possibleRepairItemDrain
				actualRepairCapacity = possibleRepairCapacity
			end
		end
		if actualRepairCapacity == repairRequested then
			break
		end
	end
	if actualRepairCapacity < repairRequested then
		for itemName, _ in pairs(contents) do
			local stack = inventory.find_item_stack(itemName)
			if stack.type == "repair-tool" and const.repairItemPriority[stack.name] == nil then
				local toolSpeed = stack.prototype.speed
				local drainAmount = repairRequested / toolSpeed
				local possibleRepairItemDrain = mmin(stack.durability * stack.count, drainAmount)
				local possibleRepairCapacity = possibleRepairItemDrain * toolSpeed
				if possibleRepairCapacity > actualRepairCapacity then
					repairItemUsed = itemName
					repairItemDrained = possibleRepairItemDrain
					actualRepairCapacity = possibleRepairCapacity
				end
				if actualRepairCapacity == repairRequested then
					break
				end
			end
		end
	end
	return repairItemUsed, mceil(repairItemDrained), actualRepairCapacity
end

local function processMaintenanceUnit(entityID)
	if entityID ~= nil and global.maintenanceUnits[entityID] ~= nil then
		local mUnitReference = global.maintenanceUnits[entityID]
		local mUnit = mUnitReference.entity
		local storage = mUnit.get_inventory(defines.inventory.chest)
		local properties = const.maintenanceUnits[mUnit.name]
		local updateConnectedMachines = false

		for _, machineID in pairs(mUnitReference.connectedMachines) do
			if global.monitoredEntities[machineID] == nil then
				updateConnectedMachines = true
			end
		end

		if updateConnectedMachines then
			mUnitReference.connectedMachines = getNeighboringMachines(mUnit)
		end

		local mUnitEEI = mUnitReference.connectedEEI
		if mUnitEEI and mUnitEEI.valid then
			if mUnitEEI.energy > 0 then
				for _, machineID in pairs(mUnitReference.connectedMachines) do
					local machineData = global.monitoredEntities[machineID]

					if machineData ~= nil then
						if machineData.connectedProxy ~= nil and machineData.connectedProxy.valid then
							local requested = machineData.connectedProxy.item_requests
							local target = machineData.connectedChest.get_inventory(defines.inventory.chest)
							if transferItemsIfAvailable(target, storage, requested, machineData.connectedProxy) == "fulfilled" then
								machineData.connectedProxy.destroy()
							end
						end
						if machineData.entity ~= nil and machineData.entity.valid then
							local health = machineData.entity.health
							local maxHealth = machineData.entity.prototype.max_health
							if health < maxHealth then
								local avgRepairRate = properties.repairRate * maxHealth
								local repairNeeded = mceil(mmin(maxHealth - health, rand(mfloor(avgRepairRate * 0.5), mceil(avgRepairRate * 1.5))))
								local repairItemUsed, repairItemDrained, actualRepairCapacity = checkRepairCapacity(storage, repairNeeded)
								if repairItemUsed ~= nil then
									storage.find_item_stack(repairItemUsed).drain_durability(repairItemDrained)
									health = health + actualRepairCapacity
									machineData.entity.health = health
								end
							end
						end
					end
				end
			end
		else
			-- this shouldn't happen, but if it does then we need a new electric energy interface
			mUnitEEI = mUnit.surface.create_entity{
				name = mUnit.name.."-electric-energy-interface",
				position = mUnit.position,
				force = mUnit.force,
				create_build_effect_smoke = false}
			global.maintenanceUnits[entityID].connectedEEI = mUnitEEI
		end


		local nextTick = rand(mfloor(const.MTTM / (2 * properties.updateRate)), mfloor(const.MTTM * (1.5 / properties.updateRate))) -- update rate is dependent on MTBM
		local eventTick = game.tick + nextTick

		mUnitReference.nextEventTick = eventTick
		global.maintenanceUnits[entityID] = mUnitReference

		scheduleNextEvent(eventTick, {id = entityID, type = "maintenance-unit"})

	end
end

local function processManualMaintenance(playerID)
	if playerID ~= nil and game.players[playerID] ~= nil then
		local player = game.players[playerID]
		local selected = player.selected
		local missing_items_type = false
		local missing_items_msg = {
			["maintenance"] = {"mm-flying-text-manual-maintenance-no-spareparts"},
			["malfunction"] = {"mm-flying-text-manual-maintenance-no-repair"},
			["repair-ongoing"] = {"mm-flying-text-manual-maintenance-no-spareparts"},
			["awaiting-replacement"] = {"mm-flying-text-manual-maintenance-no-replacement"},
			["replacement-required"] = {"mm-flying-text-manual-maintenance-no-replacement"}}
        if selected ~= nil then
            local uID = selected.unit_number
            local machineData
            if uID ~= nil and global.monitoredEntities[uID] then
                machineData = global.monitoredEntities[uID]
            elseif selected.prototype.type == "item-request-proxy" and selected.proxy_target ~= nil and selected.proxy_target.unit_number ~= nil then
                uID = selected.proxy_target.unit_number
                if uID ~= nil and global.activeChests[uID] ~= nil then
                    machineData = global.monitoredEntities[global.activeChests[uID]]
                end
            end
            if machineData ~= nil then
                if machineData.connectedProxy ~= nil and machineData.connectedProxy.valid then
                    if player.can_reach_entity(selected) then
                        local requested = machineData.connectedProxy.item_requests
                        local target = machineData.connectedChest.get_inventory(defines.inventory.chest)
                        local demand = transferItemsIfAvailable(target, player.get_main_inventory(), requested, machineData.connectedProxy)
                        if demand == "fulfilled" then
                            machineData.connectedProxy.destroy()
                            player.play_sound{path = "utility/inventory_move"}
                        elseif demand == "reduced" then
                            player.play_sound{path = "utility/inventory_move"}
                        elseif demand == "unchanged" then
                            missing_items_type = machineData.status
                        end
                        if missing_items_type ~= false then
                            player.create_local_flying_text{text = missing_items_msg[missing_items_type], position = selected.position}
                            player.play_sound{path = "utility/cannot_build"}
                        end
                    else
                        player.create_local_flying_text{text = {"cant-reach"}, position = selected.position}
                        player.play_sound{path = "utility/cannot_build"}
                    end
                end
            end
        end
	end
end

function initLowTechModifierCalculation(force_index)
    local techList = {}
    local checkedTechs = {}
    local force = game.forces[force_index]
    local totalUnitCount = 0
    --- Build a list out of all techs needed to research the target tech (e.g. rocket silo)
    local function traverseTechTree(technology)
        local tech = game.technology_prototypes[technology]
        if tech ~= nil then
            checkedTechs[tech.name] = true
            techList[tech.name] = tech.research_unit_count
            totalUnitCount = totalUnitCount + tech.research_unit_count
            for t, data in pairs(tech.prerequisites) do
                if not checkedTechs[t] then
                    traverseTechTree(t)
                end
            end
        end
    end
    traverseTechTree(const.lowTechModifierTarget)
    global.lowTechModifier = global.lowTechModifier or {}
    global.lowTechModifier[force_index] = {}
    global.lowTechModifier[force_index].techs = techList
    global.lowTechModifier[force_index].totalUnits = totalUnitCount
    global.lowTechModifier[force_index].researchedUnits = 0
    global.lowTechModifier[force_index].factor = const.lowTechModifierBase
end

function calculateLowTechModifier(force_index, update)
    local force = game.forces[force_index]
    local techList = global.lowTechModifier[force_index].techs
    local totalUnitCount = global.lowTechModifier[force_index].totalUnits
    local researchedUnitCount = global.lowTechModifier[force_index].researchedUnits


    if techList == nil then
        initLowTechModifierCalculation(force_index)
    end
    --- check for all techs in this list whether this force has researched them or not
    if update then
        researchedUnitCount = 0
        for tech, units in pairs(techList) do
            if force.technologies[tech].researched then
                researchedUnitCount = researchedUnitCount + units
            end
        end
        global.lowTechModifier[force_index].researchedUnits = researchedUnitCount
    end

    global.lowTechModifier[force_index].factor = (researchedUnitCount / totalUnitCount) * (1 - const.lowTechModifierBase) + const.lowTechModifierBase
end

function initMaintenanceForExistingSave()
-- get all enabled prototypes in this existing save that now have to be maintained
	local initMaintenancePrototypes = {}
	initMaintenancePrototypes["assembling-machine"] = true
	initMaintenancePrototypes["furnace"] = true
	initMaintenancePrototypes["accumulator"] = settings.global["mm-include-accumulators"].value
	initMaintenancePrototypes["solar-panel"] = settings.global["mm-include-solar-panels"].value
	initMaintenancePrototypes["reactor"] = settings.global["mm-include-reactors"].value
	initMaintenancePrototypes["boiler"] = settings.global["mm-include-boiler-and-generators"].value
	initMaintenancePrototypes["generator"] = settings.global["mm-include-boiler-and-generators"].value
	initMaintenancePrototypes["mining-drill"] = settings.global["mm-include-miners"].value
	initMaintenancePrototypes["roboport"] = settings.global["mm-include-roboports"].value
	initMaintenancePrototypes["beacon"] = settings.global["mm-include-beacons"].value
	initMaintenancePrototypes["lab"] = settings.global["mm-include-labs"].value
	if const.maintenanceActivated and mm_util.getLength(initMaintenancePrototypes) > 0 then
		local initEntity = {}
		for _, entity in pairs(game.entity_prototypes) do
			-- if a certain entity prototype is a valid entity type for which maintenance is enabled, add it to the "initEntity" list
			-- this excludes placement entities for maintenance units
			if initMaintenancePrototypes[entity.type] then
				if game.item_prototypes[entity.name] and game.recipe_prototypes[entity.name] and string.find(entity.name, "-placement%-entity") == nil then
					if not global.entitiesWithMROenabled[entity.name] then
						global.entitiesWithMROenabled[entity.name] = {}
					end
					global.entitiesWithMROenabled[entity.name].active = true
					initEntity[#initEntity+1] = entity.name
				end
			end
		end
		if initEntity ~= nil then
			-- search for entities on map and enable maintenance mode for them
			startMaintenanceCycleForExistingEntities(initEntity)
		end
	end
end

commands.add_command("maintenance-mod-reload", {"mm-cmd-reload-help"}, function(param)
	forcesWithMROdisabled = const.forcesWithMROdisabled
	entityTypesWithMROenabled = const.entityTypesWithMROenabled
	entityMaintencanceDemandByName = const.entityMaintencanceDemandByName
	entityMaintenanceDemandByType = const.entityMaintenanceDemandByType
	entityDefaultRepairDemandByType = const.entityDefaultRepairDemandByType
	textColors = const.textColors

	init_global()
	local player = game.players[param.player_index]
	mm_util.notification({"mm-notification-cmd-issued", {"mm-prefix"}, {"mm-cmd-reload-completed"}})
end)

commands.add_command("maintenance-mod-print-debug", {"mm-cmd-log-debug"}, function(param)
	log(serpent.block(const, {maxlevel= 4}))
	local player = game.players[param.player_index]
	mm_util.notification({"mm-notification-cmd-issued", {"mm-prefix"}, {"mm-cmd-log-debug-completed"}})
end)

----- EVENT HANDLERS :

local function getEnabledMaintenanceTypes()
	local types = {}
		types["assembling-machine"] = true
		types["furnace"] = true
		if settings.global["mm-include-accumulators"].value then
			types["accumulator"] = true end
		if settings.global["mm-include-solar-panels"].value then
			types["solar-panel"] = true end
		if settings.global["mm-include-reactors"].value then
			types["reactor"] = true end
		if settings.global["mm-include-boiler-and-generators"].value then
			types["boiler"] = true
			types["generator"] = true end
		if settings.global["mm-include-miners"].value then
			types["mining-drill"] = true end
		if settings.global["mm-include-roboports"].value then
			types["roboport"] = true end
		if settings.global["mm-include-beacons"].value then
			types["beacon"] = true end
		if settings.global["mm-include-labs"].value then
			types["lab"] = true end
	return types
end

-- check mod changes
script.on_configuration_changed(
function(data)
    -- midgame installation
    if data.mod_changes ~= nil and data.mod_changes["MaintenanceMadness"] ~= nil and data.mod_changes["MaintenanceMadness"].old_version == nil then
        -- anounce installation
        mm_util.notification({"mm-notification-midgame-update", {"mm-prefix"}, data.mod_changes["MaintenanceMadness"].new_version})
		initMaintenanceForExistingSave()
    -- midgame update
    elseif data.mod_changes ~= nil and data.mod_changes["MaintenanceMadness"] ~= nil and data.mod_changes["MaintenanceMadness"].old_version ~= nil then
        local oldver = data.mod_changes["MaintenanceMadness"].old_version
        local newver = data.mod_changes["MaintenanceMadness"].new_version
		init_global()
		updateMaintanceControlSettings()
        mm_util.notification({"mm-notification-new-version", {"mm-prefix"}, oldver, newver})

    -- if other mods changed, e.g. added new entities OR mod startup settings changed (possibly removing or adding entites)
    elseif data.mod_changes ~= nil or data.mod_startup_settings_changed then
        for index, force in pairs(game.forces) do
			force.reset_recipes()
			force.reset_technologies()
			force.reset_technology_effects()
        end
		init_global()
		updateMaintanceControlSettings()
	end
end)

script.on_init(
function()
	init_global()
end)

script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity, defines.events.script_raised_built, defines.events.script_raised_revive, defines.events.on_entity_cloned},
function(event)
	entity = event.created_entity or event.entity or event.destination
	if entity ~= nil and entity.valid then
		local name = entity.name
		--local s1, s2 = string.find(entity.name, "-maintenance%-unit")
		if forcesWithMROdisabled[entity.force.name] ~= true then
			if global.entitiesWithMROenabled[name] ~= nil and global.entitiesWithMROenabled[name].active then
				initLifeCycle(entity)
			elseif const.maintenanceUnits[name] ~= nil then
				initMaintenanceUnit(entity)
			elseif entity.type == "beacon" then
				-- check if this is a placement entity for a maintenance unit
				local s1, s2 = string.find(name, "-placement%-entity")
				if s2 ~= nil then
					local surface = entity.surface
					local position = entity.position
					local force = entity.force
					local last_user = entity.last_user
					entity.destroy()
					surface.create_entity{
						name = string.sub(name, 1, s1-1),
						position = position,
						force = force,
						player = last_user,
						create_build_effect_smoke = false,
						raise_built = true}
				end
			end
		end
	end
end)

script.on_event({defines.events.on_robot_mined_entity, defines.events.on_player_mined_entity, defines.events.script_raised_destroy},
function(event)
	local eid = event.entity.unit_number
	if eid ~= nil then
		if global.monitoredEntities[eid] ~= nil then
			if event.buffer then
			-- if the entity has been removed by another mod's script, the buffer wont be available, thus we need to skip the following lines
				local scrap = checkForScrapReturn(eid)
				if scrap ~= nil then
					event.buffer.clear()
					for item, amount in pairs(scrap) do
						event.buffer.insert({name = item, count = amount})
					end
				end
			end
			processRemovedEntity(eid) -- remove this entity from the monitoring list

		elseif global.maintenanceUnits[eid] ~= nil then -- if this is a maintenance unit
			processRemovedMaintenanceUnit(eid)
		end
	end
end)

script.on_event(defines.events.on_entity_died,
function(event)
	local entity = event.entity
	local eid = entity.unit_number
	if eid ~= nil then
		if global.monitoredEntities[eid] ~= nil then
			requestGuiUpdate(entity.force.index)
			if global.monitoredEntities[eid].surrogatedEntityName ~= nil then
				-- replace the machine and then destroy the replacement: This way, the ghost of the surrogated entity will be created
				entity = stopMaintenanceCycle(eid, false)

				if event.cause ~= nil then
					entity.die(event.force, event.cause)
				else
					entity.die(event.force)
				end
			else
				stopMaintenanceCycle(eid, false)
			end
		elseif global.maintenanceUnits[eid] ~= nil then -- if this is a maintenance unit
			processRemovedMaintenanceUnit(eid)
			local placementEntity = entity.surface.create_entity{
						name = entity.name.."-placement-entity",
						position = entity.position,
						force = entity.force,
						create_build_effect_smoke = false}
			entity = placementEntity
			if event.cause ~= nil then
				entity.die(event.force, event.cause)
			else
				entity.die(event.force)
			end
		end
	end
end)

script.on_event({defines.events.on_player_setup_blueprint, defines.events.on_player_configured_blueprint},
function(event)
	-- If a player selects faulty versions of solar panels or accumulators for a blueprint, they need to be replaced by normal versions of themselves
	local player = game.players[event.player_index]
	if not player.valid then
		return
	end
	local bp = player.blueprint_to_setup
		if not bp.valid or not bp.valid_for_read then
			bp = player.cursor_stack
			if not bp.valid or not bp.valid_for_read then
				return
			end
	end
	if bp.name ~= "blueprint" then
		return
	end
	local entities = bp.get_blueprint_entities()
	if not entities then
		return
	end




	local modified = false
	local circuit_connection = false
	for _, entity in pairs (entities) do

		if string.sub(entity.name, 1, 10) == "mm-faulty-" then
			entity.name = string.gsub(entity.name, "mm%-faulty%-", "")

			modified = true
		elseif const.maintenanceUnits[entity.name] ~= nil then
			-- remove all circuit connections of all connected entities in this blueprint - in both directions
			-- problem: placement entity is of type beacon, which does not support circuit connections
			if entity.connections ~= nil then
				for _, connector in pairs(entity.connections) do
					for wireType, wires in pairs(connector) do
						for _, connectedEntity in pairs(wires) do
							-- check the entities that are connected with this maintenance unit
							for connectorID, targetConnectors in pairs(entities[connectedEntity.entity_id]["connections"]) do
								if targetConnectors[wireType] ~= nil then
									for targetIndex, targetConnectedEntity in pairs(targetConnectors[wireType]) do
										if targetConnectedEntity.entity_id == entity.entity_number then
											-- remove this unit from the connections table of this entity and deconstruct table afterwards if necessary
											targetConnectors[wireType][targetIndex] = nil
											circuit_connection = true
											if mm_util.getLength(targetConnectors[wireType]) == 0 then
												targetConnectors[wireType] = nil
												if mm_util.getLength(entities[connectedEntity.entity_id]["connections"][connectorID]) == 0 then
													entities[connectedEntity.entity_id]["connections"][connectorID] = nil
													if mm_util.getLength(entities[connectedEntity.entity_id]["connections"]) == 0 then
														entities[connectedEntity.entity_id]["connections"] = nil
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
				entity.connections = nil
			end

			entity.name = entity.name.."-placement-entity"
			modified = true
		end
	end
	if modified then
		if bp.blueprint_icons then
		-- Also swap the blueprint icons
			local icons = bp.blueprint_icons
			for _, icon in pairs (icons) do
				if string.sub(icon.signal.name, 1, 10) == "mm-faulty-" then
					icon.signal.name = string.gsub(icon.signal.name, "mm%-faulty%-", "")
				elseif const.maintenanceUnits[icon.signal.name] ~= nil then
					icon.signal.name = icon.signal.name.."-placement-entity"
				end
			end
			bp.blueprint_icons = icons
		end
		bp.set_blueprint_entities(entities)

	end
	if circuit_connection then
		player.print({"mm-notification-tried-to-blueprint-circuit-connected-maintenance-unit", {"mm-prefix"}})
	end
end)

script.on_event(defines.events.on_player_pipette,
function(event)
	local player = game.players[event.player_index]
	local item = event.item
	local modified = false
	-- if the player pipettes faulty entities (e.g. solar panels), the items placed in the player's cursor need to be exchanged
	if player and player.valid and item then
		if string.sub(item.name, 1, 10) == "mm-faulty-" then
			item = game.item_prototypes[string.gsub(item.name, "mm%-faulty%-", "")]
			modified = true
		elseif const.maintenanceUnits[item.name] ~= nil then
			item = game.item_prototypes[item.name.."-placement-entity"]
			modified = true
		end
		if modified then
			local inventory = player.get_main_inventory().get_contents()
			local item_amount = inventory[item.name] or 0
			if item_amount > 0 and player.cursor_stack.can_set_stack then
				-- Remove stack from inventory and put it into cursor
				player.cursor_stack.set_stack({name = item.name, count = item_amount})
				player.get_main_inventory().remove({name = item.name, count = item_amount})
			else
				if event.used_cheat_mode and player.cursor_stack.can_set_stack then
					-- In cheat mode, create a new stack
					player.cursor_stack.set_stack({name = item.name, count = item.stack_size})
				else
					-- Ghost cursor
					player.cursor_ghost = item
				end
			end
		end
	end
end)

script.on_event(defines.events.on_research_finished,
function(event)
    local force = event.research.force
    local name = event.research.name
    local fi = force.index
    if const.lowTechModifierEnabled and global.lowTechModifier[fi].techs[name] ~= nil then
        local old_value = global.lowTechModifier[fi].factor * 1
        calculateLowTechModifier(fi, true)
        if settings.global["mm-enable-low-tech-update-notification"].value then
            mm_util.notification({"mm-notification-with-prefix", {"mm-prefix"}, {"mm-notification-lowtech-bonus-update-1"}}, force)
            mm_util.notification({"mm-notification-with-prefix", {"mm-prefix"}, {"mm-notification-lowtech-bonus-update-2", mm_util.round(global.lowTechModifier[fi].factor * 100, 0.1), mm_util.round((old_value) * 100, 0.1)}}, force)
        end
    end
    local _, s2 = string.find(name, "improved%-maintenance%-access")
    if s2 ~= nil then
        local forceBonus = global.forceBonus[fi]
        if forceBonus == nil then forceBonus = {} end
        forceBonus.basicMaintenanceBonus = (forceBonus.basicMaintenanceBonus or 0) + (internalSettings.techBoni["improvedMaintenanceAccess"][event.research.level].basicMaintenanceBonus or 0)
        forceBonus.basicRepairSpeedBonus = (forceBonus.basicRepairSpeedBonus or 0) + (internalSettings.techBoni["improvedMaintenanceAccess"][event.research.level].basicRepairSpeedBonus or 0)
        global.forceBonus[fi] = forceBonus
    end
end)

script.on_event(defines.events.on_force_reset,
function(event)
    global.forceBonus[event.force.index] = nil
end)

local function format_tick_to_time(tick)
	local ret
	local s = mfloor(tick/60)
	local m = mfloor(s/60)
	local h = mfloor(m/60)
	local seconds = string.format("%02d", s%60)
	local minutes = string.format("%02d", m%60)
	ret = minutes..":"..seconds
	if h > 0 then
		ret = h..":"..ret
	end
	return ret
end


local function buildCursorBox(playerID, target_entity)
    local offsetVector = {{x = -1, y = -1}, {x = 1, y = -1}, {x = 1, y = 1}, {x = -1, y = 1}}
	local dimensions = mm_util.getBoundingBoxDimensions(target_entity.selection_box)
	local size = "small"
	local shortestSide = mmin(dimensions.width, dimensions.height)
	if shortestSide > 3 then
		size = "large"
	elseif shortestSide > 1 then
		size = "medium"
	end
	for i = 1, 4 do
	global.last_selected[playerID][#global.last_selected[playerID]+1] = rendering.draw_sprite{
		sprite = "selection-box-"..size,
		orientation = (i - 1) * 0.25,
		render_layer = "selection-box",
		target = target_entity,
		target_offset = {offsetVector[i].x * (dimensions.width/2), offsetVector[i].y * (dimensions.height/2)},
		surface = target_entity.surface,
		players = {playerID}}
	end
end

script.on_event("mm-event-manual-maintenance", function(event)
	processManualMaintenance(event.player_index)
end)


local function update_information_overlay(player_index)
	local debug = const.debug
	local playerID = player_index
	if global.last_selected[playerID] then
		for _, render_object in pairs(global.last_selected[playerID]) do
			if rendering.is_valid(render_object) then
				rendering.destroy(render_object)
			end
		end
		global.last_selected[playerID] = nil
	end
	local player = game.players[playerID]
	local entity = player.selected
	if entity and entity.valid then
		local entityID = entity.unit_number
		if entity.prototype.type == "item-request-proxy" and entity.proxy_target ~= nil and entity.proxy_target.valid then
			chestID = entity.proxy_target.unit_number
			if chestID ~= nil and global.activeChests[chestID] ~= nil then
				entityID = global.activeChests[chestID]
			end
		end
        if global.monitoredEntities[entityID] then
			local targetReference = global.monitoredEntities[entityID]
            entity = targetReference.entity
            if not entity.valid then return end -- safety catch

            global.last_selected[playerID] = {}

            if targetReference.connectedMUnits ~= nil then
                for _, mUnitID in pairs(targetReference.connectedMUnits) do
                    if global.maintenanceUnits[mUnitID] ~= nil then
                        local mUnit = global.maintenanceUnits[mUnitID].entity
                        if mUnit and mUnit.valid then
                            buildCursorBox(playerID, mUnit)
                        end
                    end
                end
            end
			local age = targetReference.ageing
			local color
			if age < const.replacementAge then
				local percentage = age / const.replacementAge
				color = mm_util.calculateTextColor(textColors.age_phase1.min, textColors.age_phase1.delta, percentage)
			elseif age < const.maxAge then
				local percentage = (age - const.replacementAge) / (const.maxAge - const.replacementAge)
				color = mm_util.calculateTextColor(textColors.age_phase2.min, textColors.age_phase2.delta, percentage)
			elseif age > const.maxOperationAge then
				color = textColors.age_max
			else
				color = textColors.age_phase2.max
			end
			local dimensions = mm_util.getBoundingBoxDimensions(entity.selection_box)
			if not debug then
				if targetReference.status == "malfunction" and not targetReference.connectedProxy.valid then
				-- if malfunction and initial repair requests have been fulfilled, display the timer to show the remaining time until the machine is repaired
					local estimatedRepairTime = mceil(targetReference.nextEventTick - game.tick)

					global.last_selected[playerID][#global.last_selected[playerID]+1] = rendering.draw_text{
						text = {"mm-status-overlay-repair-pending", format_tick_to_time(estimatedRepairTime)},
						surface = player.surface,
						scale = 1,
						target = entity,
						target_offset = {0, (dimensions.height/2) + 0.7},
						color = textColors.age_phase2.min,
						players = {playerID},
						draw_on_ground = false,
						alignment = "center",
						scale_with_zoom = true,
						only_in_alt_mode = true}
				elseif targetReference.status == "repair-ongoing" then
				-- if repair onging, display the timer to show the estimated remaining time until the machine is repaired
					local currentTick = game.tick
					local nextEventTick = targetReference.nextEventTick
					local timeSpanLastToNextEvent = targetReference.repairTimeElapsed
					local remainingTimeSpan = nextEventTick - currentTick
					local usedTimeSpan = timeSpanLastToNextEvent - remainingTimeSpan
                    local repairEffectivity = targetReference.repairEffectivity
                    local baseRepairEffectivity = const.baseRepairEffectivity
                    local forceID = player.force.index
                    if targetReference.connectedMUnits ~= nil then
                        -- if connected to a maintenance unit, check if force tech boni have to be applied
                        baseRepairEffectivity = baseRepairEffectivity + (global.forceBonus[forceID] and global.forceBonus[forceID].basicRepairSpeedBonus or 0)
                    end
					local targetChest = targetReference.connectedChest
					if targetChest and targetChest.valid then
						-- check if / how many repair materials have been delivered
						local repairMaterialSupplyRate = checkCompletedDemands(targetChest, targetReference.requestedItems)
						repairEffectivity = baseRepairEffectivity + (1 - baseRepairEffectivity) * repairMaterialSupplyRate
					end
					local timeToRepair = targetReference.timeToRepair - mfloor(usedTimeSpan * repairEffectivity)
					local remainingRepairTime = mceil(timeToRepair / repairEffectivity)
					local estimatedRepairTime = mmax(remainingTimeSpan, remainingRepairTime)
					global.last_selected[playerID][#global.last_selected[playerID]+1] = rendering.draw_text{
						text = {"mm-status-overlay-repair-time", format_tick_to_time(estimatedRepairTime)},
						surface = player.surface,
						scale = 1,
						target = entity,
						target_offset = {0, (dimensions.height/2) + 0.7},
						color = textColors.age_phase2.min,
						players = {playerID},
						draw_on_ground = false,
						alignment = "center",
						scale_with_zoom = true,
						only_in_alt_mode = true}
					global.last_selected[playerID][#global.last_selected[playerID]+1] = rendering.draw_text{
						text = {"mm-status-overlay-repair-effectivity", mfloor(repairEffectivity * 100)},
						surface = player.surface,
						scale = 1,
						target = entity,
						target_offset = {0, (dimensions.height/2) + 1.3},
						color = mm_util.calculateTextColor(textColors.maintenance.min, textColors.maintenance.delta, repairEffectivity),
						players = {playerID},
						draw_on_ground = false,
						alignment = "center",
						scale_with_zoom = true,
						only_in_alt_mode = true}
				elseif targetReference.serviceRequests > 0 then
					global.last_selected[playerID][#global.last_selected[playerID]+1] = rendering.draw_text{
						text = {"mm-status-overlay-service-level", mfloor(targetReference.serviceLevel * 100)},
						surface = player.surface,
						scale = 1,
						target = entity,
						target_offset = {0, (dimensions.height/2) + 0.7},
						color = mm_util.calculateTextColor(textColors.maintenance.min, textColors.maintenance.delta, targetReference.serviceLevel),
						players = {playerID},
						draw_on_ground = false,
						alignment = "center",
						scale_with_zoom = true,
                        only_in_alt_mode = true}
                    if targetReference.status == "awaiting-replacement" or targetReference.status == "replacement-required" then
                        local targetChest = targetReference.connectedChest
					    if targetChest and targetChest.valid then
                            local replacementSupplied = checkCompletedDemands(targetChest, targetReference.requestedItems)
                            if replacementSupplied >= 1 then
                                global.last_selected[playerID][#global.last_selected[playerID]+1] = rendering.draw_text{
                                    text = {"mm-status-overlay-replacement-pending"},
                                    surface = player.surface,
                                    scale = 1,
                                    target = entity,
                                    target_offset = {0, (dimensions.height/2) + 1.1},
                                    color = textColors.age_phase2.min,
                                    players = {playerID},
                                    draw_on_ground = false,
                                    alignment = "center",
                                    scale_with_zoom = true,
                                    only_in_alt_mode = true}
                                end
                        end
                    end
				end
			else
				global.last_selected[playerID][#global.last_selected[playerID]+1] = rendering.draw_text{
					text = "Status: '"..targetReference.status.."'",
					surface = player.surface,
					scale = 1,
					target = entity,
					target_offset = {0, (dimensions.height/2) + 0.7},
					color = textColors.maintenance.max,
					players = {playerID},
					draw_on_ground = false,
					alignment = "center",
					scale_with_zoom = true,
					only_in_alt_mode = true}
				global.last_selected[playerID][#global.last_selected[playerID]+1] = rendering.draw_text{
					text = "Total maintenance requests: "..tostring(targetReference.serviceRequests),
					surface = player.surface,
					scale = 1,
					target = entity,
					target_offset = {0, (dimensions.height/2) + 1.3},
					color = textColors.maintenance.max,
					players = {playerID},
					draw_on_ground = false,
					alignment = "center",
					scale_with_zoom = true,
					only_in_alt_mode = true}
				global.last_selected[playerID][#global.last_selected[playerID]+1] = rendering.draw_text{
					text = "Average service level: "..tostring(targetReference.serviceLevel),
					surface = player.surface,
					scale = 1,
					target = entity,
					target_offset = {0, (dimensions.height/2) + 1.9},
					color = textColors.maintenance.max,
					players = {playerID},
					draw_on_ground = false,
					alignment = "center",
					scale_with_zoom = true,
					only_in_alt_mode = true}

				global.last_selected[playerID][#global.last_selected[playerID]+1] = rendering.draw_text{
					text = "Next event in "..format_tick_to_time(targetReference.nextEventTick - game.tick),
					surface = player.surface,
					scale = 1,
					target = entity,
					target_offset = {0, (dimensions.height/2) + 2.5},
					color = textColors.maintenance.max,
					players = {playerID},
					draw_on_ground = false,
					alignment = "center",
					scale_with_zoom = true,
					only_in_alt_mode = true}
			end
			-- render this above all other data
			global.last_selected[playerID][#global.last_selected[playerID]+1] = rendering.draw_text{
				text = {"mm-status-overlay-age", mceil(age)},
				surface = player.surface,
				scale = 1,
				target = entity,
				target_offset = {0, (dimensions.height/2) + 0.25},
				color = color,
				players = {playerID},
				draw_on_ground = false,
				alignment = "center",
				scale_with_zoom = true,
				only_in_alt_mode = true}
		elseif global.maintenanceUnits[entityID] then
			local mUnitReference = global.maintenanceUnits[entityID]
			local areaOfEffect = mUnitReference.areaOfEffect

			global.last_selected[playerID] = {}

			for _, machineID in pairs(mUnitReference.connectedMachines) do
				if global.monitoredEntities[machineID] ~= nil then
					local machine = global.monitoredEntities[machineID].entity
					if machine and machine.valid then
						buildCursorBox(playerID, machine)
					end
				end
			end

			global.last_selected[playerID][#global.last_selected[playerID]+1] = rendering.draw_rectangle{
				color = textColors.radiusVisualization,
				filled = true,
				left_top = areaOfEffect.left_top,
				right_bottom = areaOfEffect.right_bottom,
				surface = player.surface,
				players = {playerID},
				draw_on_ground = true}

			local dimensions = mm_util.getBoundingBoxDimensions(entity.selection_box)
			local mUnitEEI = mUnitReference.connectedEEI
			if mUnitEEI and mUnitEEI.valid and mUnitEEI.energy == 0 then
				global.last_selected[playerID][#global.last_selected[playerID]+1] = rendering.draw_text{
					text = {"mm-status-overlay-no-energy"},
					surface = player.surface,
					scale = 1,
					target = entity,
					target_offset = {0, (dimensions.height/2) + 0.7},
					color = textColors.failure,
					players = {playerID},
					draw_on_ground = false,
					alignment = "center",
					scale_with_zoom = true,
					only_in_alt_mode = true}
			else
				local numColor = textColors.maintenance.max
				if #mUnitReference.connectedMachines == 0 then
					numColor = textColors.maintenance.min
				end
				global.last_selected[playerID][#global.last_selected[playerID]+1] = rendering.draw_text{
					text = {"mm-status-overlay-inspected-machines", #mUnitReference.connectedMachines},
					surface = player.surface,
					scale = 1,
					target = entity,
					target_offset = {0, (dimensions.height/2) + 0.7},
					color = numColor,
					players = {playerID},
					draw_on_ground = false,
					alignment = "center",
					scale_with_zoom = true,
					only_in_alt_mode = true}
				global.last_selected[playerID][#global.last_selected[playerID]+1] = rendering.draw_text{
					text = {"mm-status-overlay-next-inspection", format_tick_to_time(mUnitReference.nextEventTick - game.tick)},
					surface = player.surface,
					scale = 1,
					target = entity,
					target_offset = {0, (dimensions.height/2) + 1.3},
					color = textColors.age_phase2.min,
					players = {playerID},
					draw_on_ground = false,
					alignment = "center",
					scale_with_zoom = true,
					only_in_alt_mode = true}
			end
		end
	end
end

-- information overlay
-- additional debug info will be displayed if local debug variable is set to "true"
script.on_event(defines.events.on_selected_entity_changed, function(event)
	update_information_overlay(event.player_index)
end)

script.on_event(defines.events.on_player_joined_game, function(event)
	mmGUI.toggleMainButton(event.player_index)
end)

script.on_event(defines.events.on_gui_click, function (event)
	mmGUI.processClickedElement(event)
end)

script.on_event(defines.events.on_gui_selected_tab_changed, function (event)
	mmGUI.processChangedTab(event)
end)

script.on_event(defines.events.on_gui_value_changed, function (event)
	mmGUI.processChangedSlider(event)
end)

script.on_event(defines.events.on_gui_closed, function (event)
	mmGUI.processClosedElement(event)
end)


local function updateReplacementAgeSettings(oldDefault, newDefault)
	for _, force in pairs(game.forces) do
		local forceID = force.index
		if global.maintenanceControl[forceID] then
			if global.maintenanceControl[forceID].byEntity then
				for _, entity in pairs (global.maintenanceControl[forceID].byEntity) do
					if entity.replacement.start == oldDefault then
						entity.replacement.start = newDefault
					end
				end
			end
		end
	end
end

script.on_event(defines.events.on_runtime_mod_setting_changed,
function(event)
	local s = event.setting
	if event.setting_type == "runtime-global" then
		local initMaintenancePrototypes = {}
		local stopMaintenancePrototypes = {}
		local recalculateMainParameters = false
		if s == "mm-mod-active" then
		-- This
			const.maintenanceActivated = settings.global["mm-mod-active"].value
			if const.maintenanceActivated then
			-- Initiate maintenance for all enabled prototypes
				initMaintenancePrototypes = getEnabledMaintenanceTypes()
			else
			-- stop maintenance for all prototypes
				stopMaintenancePrototypes["assembling-machine"] = true
				stopMaintenancePrototypes["furnace"] = true
				stopMaintenancePrototypes["accumulator"] = true
				stopMaintenancePrototypes["solar-panel"] = true
				stopMaintenancePrototypes["reactor"] = true
				stopMaintenancePrototypes["boiler"]  = true
				stopMaintenancePrototypes["generator"] = true
				stopMaintenancePrototypes["mining-drill"] = true
				stopMaintenancePrototypes["roboport"] = true
				stopMaintenancePrototypes["beacon"] = true
				stopMaintenancePrototypes["lab"] = true
			end
		elseif s == "mm-maintenance-cost" then
			const.maintenanceLevel = settings.global["mm-maintenance-cost"].value
		elseif s == "mm-show-flying-text" then
			const.showText = settings.global["mm-show-flying-text"].value
		elseif s == "mm-show-maintenance-in-progress-sign-for-solar" then
			const.showMIPsignForSolar = settings.global["mm-show-maintenance-in-progress-sign-for-solar"].value
		elseif s == "mm-expected-life-time" then
			const.expectedLifeTime = mfloor(3600 * 60 * settings.global["mm-expected-life-time"].value) -- 3600 ticks = 1 min
			recalculateMainParameters = true
		elseif s == "mm-mean-time-between-maintenance-events" then
			const.MTBM = mfloor(3600 * settings.global["mm-mean-time-between-maintenance-events"].value)
			recalculateMainParameters = true
		elseif s == "mm-mean-time-to-maintain" then
			const.MTTM = mfloor(3600 * settings.global["mm-mean-time-to-maintain"].value)
			recalculateMainParameters = true
		elseif s == "mm-mean-time-to-repair" then
			const.MTTR = mfloor(3600 * settings.global["mm-mean-time-to-repair"].value)
			recalculateMainParameters = true
		elseif s == "mm-include-accumulators" then
			if settings.global["mm-include-accumulators"].value then initMaintenancePrototypes["accumulator"] = true
			else stopMaintenancePrototypes["accumulator"] = true end
		elseif s == "mm-include-solar-panels" then
			if settings.global["mm-include-solar-panels"].value then initMaintenancePrototypes["solar-panel"] = true
			else stopMaintenancePrototypes["solar-panel"] = true end
		elseif s == "mm-include-reactors" then
			if settings.global["mm-include-reactors"].value then initMaintenancePrototypes["reactor"] = true
			else stopMaintenancePrototypes["reactor"] = true end
		elseif s == "mm-include-boiler-and-generators" then
			if settings.global["mm-include-boiler-and-generators"].value then initMaintenancePrototypes["boiler"]  = true
			else stopMaintenancePrototypes["boiler"] = true end
			if settings.global["mm-include-boiler-and-generators"].value then initMaintenancePrototypes["generator"] = true
			else stopMaintenancePrototypes["generator"] = true end
		elseif s == "mm-include-miners" then
			if settings.global["mm-include-miners"].value then initMaintenancePrototypes["mining-drill"] = true
			else stopMaintenancePrototypes["mining-drill"] = true end
		elseif s == "mm-include-roboports" then
			if settings.global["mm-include-roboports"].value then initMaintenancePrototypes["roboport"] = true
			else stopMaintenancePrototypes["roboport"] = true end
		elseif s == "mm-include-beacons" then
			if settings.global["mm-include-beacons"].value then initMaintenancePrototypes["beacon"] = true
			else stopMaintenancePrototypes["beacon"] = true end
		elseif s == "mm-include-labs" then
			if settings.global["mm-include-labs"].value then initMaintenancePrototypes["lab"] = true
			else stopMaintenancePrototypes["lab"] = true end
		elseif s == "mm-solar-factor" then
			const.solarCycleTimeMultiplier = settings.global["mm-solar-factor"].value
		--[[elseif s == "mm-max-age" then
			const.maxAge = settings.global["mm-max-age"].value]]
		elseif s == "mm-replacement-age" then
			local oldDefault = const.replacementAge
			const.replacementAge = settings.global["mm-replacement-age"].value * (const.maxAge / 100)
			updateReplacementAgeSettings(oldDefault, const.replacementAge) -- update default replacement settings for all forces
		elseif s == "mm-wear-reduction-if-idle" then
			const.idleWearReductionFactor = settings.global["mm-wear-reduction-if-idle"].value / 100
		elseif s == "mm-missed-maintenance-malus" then
			const.maxMissedMaintenanceMalus = (settings.global["mm-missed-maintenance-malus"].value / 100) * const.baseAgeing
            const.repairAgeMalus = const.baseAgeing --const.maxMissedMaintenanceMalus * 0,5
        elseif s == "mm-enable-low-tech-bonus" then
            const.lowTechModifierEnabled = settings.global["mm-enable-low-tech-bonus"].value
            for _, force in pairs(game.forces) do
                local fi = force.index
                if const.lowTechModifierEnabled == true then
                    initLowTechModifierCalculation(fi)
                    calculateLowTechModifier(fi, true)
                    mm_util.notification({"mm-notification-with-prefix", {"mm-prefix"}, {"mm-notification-lowtech-bonus-enabled", {"technology-name."..const.lowTechModifierTarget}}}, force)
                else
                    mm_util.notification({"mm-notification-with-prefix", {"mm-prefix"}, {"mm-notification-lowtech-bonus-disabled"}}, force)
                    global.lowTechModifier[fi] = {}
                end
            end
        elseif s == "mm-low-tech-bonus-target-tech" then
            if game.technology_prototypes[settings.global["mm-low-tech-bonus-target-tech"].value] == nil then
                mm_util.notification({"mm-notification-with-prefix", {"mm-prefix"}, {"mm-notification-lowtech-bonus-changed-target-tech-failure", settings.global["mm-low-tech-bonus-target-tech"].value, {"technology-name."..const.lowTechModifierDefault}}})
                const.lowTechModifierTarget = const.lowTechModifierDefault
                settings.global["mm-low-tech-bonus-target-tech"].value = const.lowTechModifierDefault
            else
                const.lowTechModifierTarget = settings.global["mm-low-tech-bonus-target-tech"].value
                if const.lowTechModifierEnabled then
                    for _, force in pairs(game.forces) do
                        local fi = force.index
                        initLowTechModifierCalculation(fi)
                        calculateLowTechModifier(fi, true)
                        mm_util.notification({"mm-notification-with-prefix", {"mm-prefix"}, {"mm-notification-lowtech-bonus-changed-target-tech-success", {"technology-name."..const.lowTechModifierTarget}}}, force)
                    end
                end
            end
		end  --TODO
		--log(serpent.block(initMaintenancePrototypes, {maxlevel= 4}))
		--log(serpent.block(stopMaintenancePrototypes, {maxlevel= 4}))
		if const.maintenanceActivated and mm_util.getLength(initMaintenancePrototypes) > 0 then
			local initEntity = {}
			for _, entity in pairs(game.entity_prototypes) do
				--log("Liste Entity: "..entity.name.." // "..entity.type)
				if initMaintenancePrototypes[entity.type] then
					if game.item_prototypes[entity.name] and game.recipe_prototypes[entity.name] then
						if not global.entitiesWithMROenabled[entity.name] then
							global.entitiesWithMROenabled[entity.name] = {}
						end
						global.entitiesWithMROenabled[entity.name].active = true
						initEntity[#initEntity+1] = entity.name
					end
				end
			end
			if initEntity ~= nil then
				--log(serpent.block(initEntity, {maxlevel= 4}))
				startMaintenanceCycleForExistingEntities(initEntity)  -- search for entities on map that now need to be maintained
				--log(serpent.block(global.entitiesWithMROenabled, {maxlevel= 4}))
			end
		end
		if mm_util.getLength(stopMaintenancePrototypes) > 0 then
			if not const.maintenanceActivated then -- mod disabled, initiate instant stop. This may lag the game
				local stopEntities = {}
				for _, entity in pairs(game.entity_prototypes) do
					--log("Liste Entity: "..entity.name.." // "..entity.type)
					if stopMaintenancePrototypes[entity.type] then
						if game.item_prototypes[entity.name] and game.recipe_prototypes[entity.name] and global.entitiesWithMROenabled[entity.name] then
							global.entitiesWithMROenabled[entity.name].active = false
							stopEntities[#stopEntities+1] = entity.name
						-- this covers faulty versions of accus or solar panels
						elseif string.sub(entity.name, 1, 10) == "mm-faulty-" then
							stopEntities[#stopEntities+1] = entity.name
						end
					end
				end
				if stopEntities ~= nil then
					--log(serpent.block(stopEntities, {maxlevel= 4}))
					stopMaintenanceCycleForExistingEntities(stopEntities)  -- search for entities on map that no longer need to be maintained
					--log(serpent.block(global.entitiesWithMROenabled, {maxlevel= 4}))
				end
				-- RESET EVENT SCHEDULE
				global.eventScheduleMRO = {}
			else -- slow fade out of existing maintenance requests for all entities with maintenance disabled
				for entityName, entityData in pairs(global.entitiesWithMROenabled) do
					if stopMaintenancePrototypes[game.entity_prototypes[entityName].type] then
						entityData.active = false
					end
				end
			end
		end
		if recalculateMainParameters then
		-- if one of the variables needed to calculate the expected cycles per life time changes, all main parameters have to be recalculated
			const.expectedCyclesPerLifeTime = mm_util.standardizeCycleTime({
				MTBM = const.MTBM,
				MTTM = const.MTTM,
				MTTR = const.MTTR,
				maxAge = const.maxAge,
				lifeTime = const.expectedLifeTime,
				--replacementAge = const.replacementAge,
				repairTimeModifier = const.repairTimeModifier,
				repairProbabilityModifier = const.repairProbabilityModifier})

			const.baseAgeing = math.ceil(100 * const.maxAge / const.expectedCyclesPerLifeTime) / 100
			const.maxMissedMaintenanceMalus = (settings.global["mm-missed-maintenance-malus"].value / 100) * const.baseAgeing
			const.repairAgeMalus = const.baseAgeing -- + const.maxMissedMaintenanceMalus * 0,5
		end
	end
end)

--- MAIN ---
script.on_event(defines.events.on_tick,
function(event)

	if event.tick%(60) == 0 then
		for playerID, data in pairs(global.last_selected) do
			update_information_overlay(playerID)
		end
		for _, player in pairs(game.players) do
			if global.userInterface[player.index] and global.userInterface[player.index].updateRequest and global.userInterface[player.index].root ~= nil then
				mmGUI.toggleMasterPanel(player.index, true)
				global.userInterface[player.index].updateRequest = false
			end
		end
	end
	--[[
		log("---")
		log("DEBUG: #global.monitoredEntities ="..mm_util.getLength(global.monitoredEntities))
		log("DEBUG: #global.eventScheduleMRO ="..mm_util.getLength(global.eventScheduleMRO))
		]]

	if global.eventScheduleMRO and global.eventScheduleMRO[event.tick] ~= nil then
		for _, element in ipairs(global.eventScheduleMRO[event.tick]) do
			local entityID = element.id
			local entityData = global.monitoredEntities[entityID] or global.maintenanceUnits[entityID]
			-- retrieve the entity data from either the list of machines or the list of maintenance units. The unit id is unique, therefore only one source is given at a time
			--log(serpent.block(element, {maxlevel= 2}))
			--log(serpent.block(entityData, {maxlevel= 3}))
			if element.type == "machine" and entityData ~= nil and entityData.entity and entityData.entity.valid then
				local realEntity = entityData.entity
				local entityName = entityData.surrogatedEntityName or realEntity.name
				local status = entityData.status
				local activity

				if not global.entitiesWithMROenabled[entityName].active then
					-- Stop maintenance for this entity if the prototype is no longer activated for maintenance
					stopMaintenanceCycle(entityID)
					goto continue_with_next_element
				end

				local entityAge = entityData.ageing

				if entityData.producedItems then
					if entityData.producedItems < realEntity.products_finished then
						activity = true
						entityData.producedItems = realEntity.products_finished
					else
						activity = false
					end
				elseif const.alternativeActivityTracking[realEntity.type] then
					activity = entityWasActive(entityID)
				end


				-- Handle bonus cycles. This has two purposes: First, the player has to deal with maintenance only after a certain amount of time (this is circa one hour, assuming default configuration)
				-- Second, the length of one bonus cycle is also randomised. This dampens the overall demand for maintenance materials and avoids huge initial demand spikes which would easily overwhelm your logistics capabilities
				if entityData.bonusCyclesRemaining ~= nil and entityData.bonusCyclesRemaining > 0 then
					local reduceCounter = false
					if not activity then
						-- The entity was inactive. Now roll a dice and determine if this machine loses one of its bonus cycles. If not, skip this entity for this event
						if rand() <= const.idleWearReductionFactor then
							-- Skip this cycle
						else
							reduceCounter = true
						end
					else
						-- reduce remaining bonus cycles by one
						reduceCounter = true
					end
					local entityProperties = global.entitiesWithMROenabled[entityName]
					if reduceCounter then
						entityData.bonusCyclesRemaining = entityData.bonusCyclesRemaining - 1
						local newAgeing = global.monitoredEntities[entityID].ageing + entityProperties.timeFactor * const.baseAgeing
						global.monitoredEntities[entityID].ageing = newAgeing
					end
					local nextTick = rand(mfloor(const.MTBM/2), mfloor(const.MTBM*1,5))
					local eventTick = game.tick + mfloor(entityProperties.timeFactor * nextTick)
					global.monitoredEntities[entityID].nextEventTick = eventTick

					scheduleNextEvent(eventTick, {id = entityID, type = "machine"})
					goto continue_with_next_element
				end

				if status == "awaiting-replacement" then
					checkReplacementSuccess(entityID)
					status = entityData.status -- update status
					entityAge = entityData.ageing	-- update age
				end

                -- Check if this operating machine will be skipped this turn
                if status == "operating" then
                    if not const.lowTechModifierEnabled or rand() <= global.lowTechModifier[realEntity.force.index].factor then
                    -- Low tech bonus: Check if this maintenance event is skipped
                    -- The farther away the force this machine belongs to is from finishing the rocket silo tech, the greater is the probability that no event will take place
                        if (entityData.producedItems ~= nil or const.alternativeActivityTracking[realEntity.type]) then
                            -- Handle idle crafting machines.
                            -- Check if this machine has finished at least one product since the last maintenance event.
                            if not activity then
                                -- The entity was inactive. Now roll a dice and determine if this machine ages at all. If not, skip this entity for this event
                                if rand() <= const.idleWearReductionFactor then
                                    --log("Cycle skipped")
                                    -- Skip this cycle
                                    local entityProperties = global.entitiesWithMROenabled[entityName]
                                    local nextTick = rand(mfloor(const.MTBM/2), mfloor(const.MTBM*1,5))
                                    local eventTick = game.tick + mfloor(entityProperties.timeFactor * nextTick)
                                    global.monitoredEntities[entityID].nextEventTick = eventTick

                                    scheduleNextEvent(eventTick, {id = entityID, type = "machine"})
                                    goto continue_with_idle_machine
                                else
                                    --log("Cycle not skipped")
                                    -- Proceed as normal
                                end
                            end
                        end
                    else
                    -- skip this event
                        local entityProperties = global.entitiesWithMROenabled[entityName]
                        local nextTick = rand(mfloor(const.MTBM/2), mfloor(const.MTBM*1,5))
                        local eventTick = game.tick + mfloor(entityProperties.timeFactor * nextTick)
                        global.monitoredEntities[entityID].nextEventTick = eventTick

                        scheduleNextEvent(eventTick, {id = entityID, type = "machine"})
                        goto continue_with_idle_machine
                    end
				end

				if status == "maintenance" then
					--game.print("Objekt-ID: "..entityID.." / Alter: "..element.age.." / Status: "..entityData.status)
					finishMaintenance(entityID)
					status = entityData.status -- update status
					entityAge = entityData.ageing -- update age
				elseif status == "operating" then
					if rand(0, const.maxAge) < entityAge * const.repairProbabilityModifier then
						--game.print("Objekt-ID: "..entityID.." / Alter: "..element.age.." / Status: "..entityData.status)
						local newEntityID = causeFailure(entityID, activity)
						if tonumber(newEntityID) ~= nil then
							entityID = newEntityID
							entityData = global.monitoredEntities[newEntityID]
							realEntity = entityData.entity
							-- id changed, update entityData reference
						end
						if global.monitoredEntities[entityID] == nil then
							goto continue_with_next_element
							-- the entity was destroyed by a critical failure
						end
					else
						--game.print("Objekt-ID: "..entityID.." / Alter: "..element.age.." / Status: "..entityData.status)
						startMaintenance(entityID)
					end
				elseif status == "malfunction" then
					startRepair(entityID)
					status = entityData.status -- update status
					entityAge = entityData.ageing -- update age
				elseif status == "repair-ongoing" then
					local newEntityID = checkRepairState(entityID)
					if tonumber(newEntityID) ~= nil then
						entityID = newEntityID
						entityData = global.monitoredEntities[newEntityID]
						realEntity = entityData.entity
						-- id changed, update entityData reference
					end
					status = entityData.status -- update status
					entityAge = entityData.ageing -- update age
				elseif status == "replacement-required" then
					local newEntityID = checkForcedReplacementSuccess(entityID)
					if tonumber(newEntityID) ~= nil then
						entityID = newEntityID
						entityData = global.monitoredEntities[newEntityID]
						realEntity = entityData.entity
						-- id changed, update entityData reference
					end
					status = entityData.status -- update status
					entityAge = entityData.ageing -- update age
				end

				::continue_with_idle_machine::

				local forceSpecificControlSettings = global.maintenanceControl[realEntity.force.index].byEntity[entityName].replacement
				if status == "operating" and forceSpecificControlSettings.start > 0 and entityAge >= forceSpecificControlSettings.start then
					if forceSpecificControlSettings.limit > 0 then
						if entityAge < forceSpecificControlSettings.limit then
							requestReplacementOfOldMachine(entityID)
						else
							-- safety shutdown
							forceReplacementOfOldMachine(entityID)
						end
					else
						requestReplacementOfOldMachine(entityID)
					end
				end
			elseif element.type == "maintenance-unit" and entityData ~= nil and entityData.entity and entityData.entity.valid then
				processMaintenanceUnit(entityID)
			else
				-- If entity no longer valid - remove this element
				if element.type == "machine" then
					stopMaintenanceCycle(entityID)
				elseif element.type == "maintenance-unit" then
					processRemovedMaintenanceUnit(entityID)
				end
			end
			::continue_with_next_element::
		end
		global.eventScheduleMRO[event.tick] = nil
	end
end)
