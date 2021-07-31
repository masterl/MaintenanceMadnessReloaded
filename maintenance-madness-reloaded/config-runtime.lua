-- Maintenance Madness - 2019-2020. Created by Arcitos. License: See mod page.

--- CONSTANTS

local mm_util = require("util.util")
local const = {}

-- setting debug to true will show more information when hovering over machines or maintenance units
const.debug = false 

-- control flag: Is maintenance for this map enabled?
const.maintenanceActivated = settings.global["mm-mod-active"].value

-- cost level, higher levels increase difficulty
const.maintenanceLevel = settings.global["mm-maintenance-cost"].value

-- cost multiplier for repair material demand
const.costFactor = {
	["level-0"] = 0.5,
	["level-1"] = 1.0,
	["level-2"] = 1.5,
	["level-3"] = 2.5}

-- index value, used to normalize other age related variables		
const.maxAge = 100 

-- the older the machine, the longer the repair time. Repair time = MTTR + (Age/MaxAge * repairTimeModifier * MTTR)	
const.repairTimeModifier = 1.50 

-- Repair probability = Age/MaxAge * repairProbabilityModifier
const.repairProbabilityModifier = 0.50 

-- check every 45 sec if requested repair materials have been delivered
const.tickDelayCheckRepairState = 2700 

-- mean amount of construction cost needed per repair event
const.repairAmount = 0.05

-- minimum percentage of elapsed time that is counted towards repair time; default value 0.2 = without repair materials, repair will take 5 times more time. MUST be set to 1.0 > x > 0.0 !
const.baseRepairEffectivity = 0.2

-- damage that is dealt to a malfunctioning machine in percent of its max hitpoints independently from its actual age
const.baseDamageFactor = 0.15

-- damage that is dealt to a malfunctioning machine in percent of its max hitpoints depending on the age of the machine (relative to the maximum age). This is fully applied if the age of machine is 100%
const.maxDamageFactor = 0.85 

-- number of bonus cycles without maintenance granted to every newly placed entity	
const.freeCycles = 6 
	
-- mean time between maintenance events
const.MTBM = math.floor(3600 * settings.global["mm-mean-time-between-maintenance-events"].value) 

-- mean time to maintain
const.MTTM = math.floor(3600 * settings.global["mm-mean-time-to-maintain"].value) 

-- mean time to repair
const.MTTR = math.floor(3600 * settings.global["mm-mean-time-to-repair"].value) 

-- expected life time of a machine, assuming servicing always at 100%
const.expectedLifeTime = math.floor(3600 * 60 * settings.global["mm-expected-life-time"].value)

-- percentage in dependence of max.age. After reaching this age, machines will request replacement
const.replacementAge = settings.global["mm-replacement-age"].value * const.maxAge / 100 

-- percentage in dependence of max.age. After reaching this age, machines will stop until they are replaced (default value)
const.maxOperationAge = 150 * const.maxAge / 100 

-- this is the expected average duration in ticks of each maintenance cycle 
const.expectedCyclesPerLifeTime = mm_util.standardizeCycleTime({
	MTBM = const.MTBM, 
	MTTM = const.MTTM, 
	MTTR = const.MTTR, 	
	maxAge = const.maxAge, 
	lifeTime = const.expectedLifeTime,
	replacementAge = const.replacementAge, 
	repairTimeModifier = const.repairTimeModifier,
	repairProbabilityModifier = const.repairProbabilityModifier})
	
-- ageing per cycle
const.baseAgeing = math.ceil(100 * const.maxAge/const.expectedCyclesPerLifeTime) / 100

-- if a machine is not serviced properly, it's age is increased by a fraction of this value, depending on request completion. The settings value is an integer percentage.
const.maxMissedMaintenanceMalus = (settings.global["mm-missed-maintenance-malus"].value / 100) * const.baseAgeing

-- this is the default ageing of machines with malfunction
const.repairAgeMalus = const.baseAgeing -- + const.maxMissedMaintenanceMalus * 0,5

-- if a crafting machine has not produced anything during a maintenance interval, ageing is reduced by this factor
const.idleWearReductionFactor = settings.global["mm-wear-reduction-if-idle"].value / 100

-- if a crafting machine has not produced anything during a maintenance interval and breaks down, damage is reduced by this factor
const.idleFailureDamageFactor = 0.5

-- this value determines the rate at which scrap is generated depending on the age of the mined object
const.scrapReturnRate = 1

-- if a machine has not yet produced anything and has not yet reached the percentage of maxAge given by this variable, then it will always return a functioning machine if mined
const.maxAgeForFreeReturn = 0.25

-- show or hide the flying texts that appear for certain status changes
const.showText = settings.global["mm-show-flying-text"].value

-- probability to show the "Machine still defect" warning text
const.showDefectRemainderProb = 0.1

const.showMIPsignForSolar = settings.global["mm-show-maintenance-in-progress-sign-for-solar"].value

-- cycle time multiplier, used to reduce ups impact of large solar panel arrays
const.solarCycleTimeMultiplier = settings.global["mm-solar-factor"].value

-- if the lowtech modifier setting is enabled
const.lowTechModifierEnabled = settings.global["mm-enable-low-tech-bonus"].value

-- if a force has not yet researched any technology, this value determines the minimum probability for maintenance events. should be < 1.0
const.lowTechModifierBase = 0.2

-- target tech prototype for the lowtech modifier setting
const.lowTechModifierTarget = settings.global["mm-low-tech-bonus-target-tech"].value

-- default target tech
const.lowTechModifierDefault = "rocket-silo"

const.forcesWithMROdisabled = {
	["neutral"] = true, 
	["enemy"] = true, 
	["enemy-primitive"] = true, 
	["enemy-easy"] = true, 
	["enemy-medium"] = true, 
	["enemy-advanced"] = true}

const.entityTypesWithMROenabled = {
	["assembling-machine"] = true, 
	["furnace"] = true, 
	["solar-panel"] = settings.global["mm-include-solar-panels"].value, 
	["accumulator"] = settings.global["mm-include-accumulators"].value, 
	["reactor"] = settings.global["mm-include-reactors"].value,
	["boiler"] = settings.global["mm-include-boiler-and-generators"].value,
	["generator"] = settings.global["mm-include-boiler-and-generators"].value,
	["mining-drill"] = settings.global["mm-include-miners"].value,
	["roboport"] = settings.global["mm-include-roboports"].value,
	["beacon"] = settings.global["mm-include-beacons"].value,
	["lab"] = settings.global["mm-include-labs"].value}

-- properties of script based maintenance units
const.maintenanceUnits = {
	["mm-simple-maintenance-unit"] = {radius = 4, updateRate = 2, repairRate = 0.04}}

-- this value is used to scan for maintenance units around machines 
-- it should be set to the biggest radius of available maintenance units
const.mUnitMaxRadius = 4

-- which repair item should maintenance units priorize for repair of adjacent machines
const.repairItemPriority = {
	"mm-toolbox",
	"repair-pack"}

-- prio 1
const.entityMaintencanceDemandByName = {}

-- prio 2
const.entityMaintenanceDemandByType = {
	["assembling-machine"] = {
		{name = "mm-mechanical-spare-parts", amount = 1, probability = 0.5},
		{name = "mm-electronical-spare-parts", amount = 1, probability = 0.1},
		{name = "mm-detergent", amount = 1, probability = 0.1},
		{name = "mm-machine-oil", amount = 1, probability = 1}},	
	["furnace"] = {
		{name = "mm-mechanical-spare-parts", amount = 1, probability = 0.5},
		{name = "stone-brick", amount = 1, probability = 1},
		{name = "mm-detergent", amount = 1, probability = 0.1},
		{name = "mm-machine-oil", amount = 1, probability = 0.1}},
	["solar-panel"] = {
		{name = "mm-electronical-spare-parts", amount = 1, probability = 0.25},
		{name = "mm-detergent", amount = 1, probability = 1}},
	["accumulator"] = {
		{name = "mm-electronical-spare-parts", amount = 1, probability = 0.5},
		{name = "mm-detergent", amount = 1, probability = 1}},
	["reactor"] = {
		{name = "mm-mechanical-spare-parts", amount = 12, probability = 0.5},
		{name = "mm-electronical-spare-parts", amount = 18, probability = 0.75},
		{name = "mm-detergent", amount = 15, probability = 0.75},
		{name = "mm-toolbox", amount = 3, probability = 1}},
	["boiler"] = {
		{name = "mm-mechanical-spare-parts", amount = 2, probability = 0.5},
		{name = "stone-brick", amount = 2, probability = 0.75},
		{name = "mm-detergent", amount = 1, probability = 1}},
	["generator"] = {
		{name = "mm-mechanical-spare-parts", amount = 2, probability = 0.75},
		{name = "mm-electronical-spare-parts", amount = 2, probability = 0.25},
		{name = "mm-detergent", amount = 1, probability = 0.75},
		{name = "mm-machine-oil", amount = 4, probability = 1}},
	["mining-drill"] = {
		{name = "mm-mechanical-spare-parts", amount = 2, probability = 1},
		{name = "mm-machine-oil", amount = 1, probability = 0.75}},
	["roboport"] = {
		{name = "mm-mechanical-spare-parts", amount = 2, probability = 0.75},
		{name = "mm-electronical-spare-parts", amount = 2, probability = 0.75},
		{name = "mm-detergent", amount = 4, probability = 1},
		{name = "mm-machine-oil", amount = 4, probability = 0.75},
		{name = "mm-toolbox", amount = 1, probability = 0.25},},
	["beacon"] = {
		{name = "mm-mechanical-spare-parts", amount = 1, probability = 0.25},
		{name = "mm-electronical-spare-parts", amount = 2, probability = 1},
		{name = "mm-detergent", amount = 1, probability = 0.75},
		{name = "mm-machine-oil", amount = 2, probability = 0.75}},
	["lab"] = {
		{name = "mm-electronical-spare-parts", amount = 2, probability = 0.5},
		{name = "mm-detergent", amount = 6, probability = 1}}
}
-- repair materials that will be requested if no other material is chosen
const.entityDefaultRepairDemandByType = {
	["assembling-machine"] = {	
		{name = "mm-mechanical-spare-parts", amount = 1}},		
	["furnace"] = {				
		{name = "mm-mechanical-spare-parts", amount = 1}},
	["solar-panel"] = {
		{name = "mm-electronical-spare-parts", amount = 1}},
	["accumulator"] = {
		{name = "mm-electronical-spare-parts", amount = 1}},
	["reactor"] = {
		{name = "mm-electronical-spare-parts", amount = 8}},
	["boiler"] = {
		{name = "mm-mechanical-spare-parts", amount = 1}},
	["generator"] = {
		{name = "mm-mechanical-spare-parts", amount = 2}},
	["mining-drill"] = {
		{name = "mm-mechanical-spare-parts", amount = 1}},
	["roboport"] = {		
		{name = "mm-electronical-spare-parts", amount = 3}},
	["beacon"] = {
		{name = "mm-electronical-spare-parts", amount = 1}},
	["lab"] = {
		{name = "mm-electronical-spare-parts", amount = 1}}
}

const.alternativeActivityTracking = {
	["lab"] = true,
	["mining-drill"] = true,
	["generator"] = true,
	["boiler"] = true,
	["reactor"] = true
}

const.textColors = {
		maintenance = {
			min = {r=1, g=0.48, b=0.15, a=0.8}, -- a = 0.5
			max = {r=0.7, g=0.7, b=0.7, a=0.8}, -- a = 0.5
			delta = {r=-0.3, g=0.22, b=0.55, a=0.0}
		},
		age_phase1 = {
			min = {r=0.14, g=0.5, b=0.32, a=0.85}, -- age = 0
			max = {r=0.94, g=0.79, b=0.0, a=0.85}, -- age = replacement-age or max-age
			delta = {r=0.8, g=0.11, b=-0.32, a=0.0}
		},
		age_phase2 = {
			min = {r=0.94, g=0.79, b=0.0, a=0.85}, -- age = replacement-age (only used if replacement-age < max-age)
			max = {r=1, g=0.3, b=0.2, a=1}, -- age = max-age
			delta = {r=0.06, g=-0.49, b=0.2, a=0.15}
		},
		age_max = {r=1, g=0.075, b=0.05, a=1}, -- a = 0.9
		failure = {r=1, g=0.3, b=0.2, a=1}, -- a = 0.9
		failure2 = {r=1, g=0.4, b=0.26, a=0.8}, -- a = 0.5
		repair = {r=0.14, g=0.5, b=0.32, a=0.8},
		radiusVisualization = {r=0.43, g=0.38, b=0.11, a=0.5},
		positive = {r=0.7, g=1, b=0.6, a=1},
		negative = {r=1, g=0.7, b=0.6, a=1}
    }

return const