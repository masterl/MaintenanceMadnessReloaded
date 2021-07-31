local internalSettings = require("config-startup")
local mmUtil = require("util.util")

data:extend({
{
	type = "technology",
	name = "mm-repair-and-maintenance",
	icon = "__maintenance-madness-reloaded__/graphics/tech/repair-and-maintenance-tech.png",
	icon_size = 128,
	prerequisites = {"automation", "steel-processing"},
	unit =
	{
		count = 75,
		ingredients =
		{
			{"automation-science-pack", 1}
		},
	time = 10
	},
	effects =
	{

	},
	order = "c-c-e"
},
{
	type = "technology",
	name = "mm-recycling",
	icon = "__maintenance-madness-reloaded__/graphics/tech/recycling-tech.png",
	icon_size = 128,
	prerequisites = {"engine", "concrete"},
	unit =
	{
		count = 200,
		ingredients =
		{
			{"automation-science-pack", 1},
			{"logistic-science-pack", 1}
		},
	time = 30
	},
	effects =
	{
		{
			type = "unlock-recipe",
			recipe = "mm-recycler"
		}
	},
	order = "c-c-e"
},
{
	type = "technology",
	name = "mm-recondition",
	icon = "__maintenance-madness-reloaded__/graphics/tech/recycling-tech.png",
	icon_size = 128,
	prerequisites = {"mm-recycling", "automation-3"},
	unit =
	{
		count = 450,
		ingredients =
		{
			{"automation-science-pack", 1},
			{"logistic-science-pack", 1},
			{"chemical-science-pack", 1},
			{"production-science-pack", 1}
		},
	time = 60
	},
	effects =
	{
		{
			type = "unlock-recipe",
			recipe = "mm-toolbox"
		}
		-- recondition recipes will be added in data-final-fixes
	},
	order = "c-c-e"
},
{
	type = "technology",
	name = "mm-improved-maintenance-access-1",
	icon = "__maintenance-madness-reloaded__/graphics/tech/maintenance-hatch.png",
	icon_size = 128,
	prerequisites = {"mm-repair-and-maintenance"},
	unit =
	{
		count = 100,
		ingredients =
		{
			{"automation-science-pack", 1}
		},
	time = 15
	},
	effects =
	{
        {
			type = "nothing",
            effect_description  = {"mm-effect-basic-maintenance-bonus", mmUtil.round(internalSettings.techBoni["improvedMaintenanceAccess"][1].basicMaintenanceBonus * 100, 1)}
		}
    },
    upgrade = true,
	order = "c-c-e"
},
{
	type = "technology",
	name = "mm-improved-maintenance-access-2",
	icon = "__maintenance-madness-reloaded__/graphics/tech/maintenance-hatch.png",
	icon_size = 128,
	prerequisites = {"mm-improved-maintenance-access-1", "automation-2"},
	unit =
	{
		count = 200,
		ingredients =
		{
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
		},
	time = 30
	},
	effects =
	{
        {
			type = "nothing",
            effect_description  = {"mm-effect-basic-maintenance-bonus", mmUtil.round(internalSettings.techBoni["improvedMaintenanceAccess"][2].basicMaintenanceBonus * 100, 1)}
        },
        {
			type = "nothing",
            effect_description  = {"mm-effect-basic-repair-speed-bonus", mmUtil.round(internalSettings.techBoni["improvedMaintenanceAccess"][2].basicRepairSpeedBonus * 100, 1)}
		}
    },
    upgrade = true,
	order = "c-c-e"
},
{
	type = "technology",
	name = "mm-improved-maintenance-access-3",
	icon = "__maintenance-madness-reloaded__/graphics/tech/maintenance-hatch.png",
	icon_size = 128,
	prerequisites = {"mm-improved-maintenance-access-2", "advanced-electronics"},
	unit =
	{
		count = 400,
		ingredients =
		{
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
		},
	time = 60
	},
	effects =
	{
        {
			type = "nothing",
            effect_description  = {"mm-effect-basic-maintenance-bonus", mmUtil.round(internalSettings.techBoni["improvedMaintenanceAccess"][3].basicMaintenanceBonus * 100, 1)}
        },
        {
			type = "nothing",
            effect_description  = {"mm-effect-basic-repair-speed-bonus", mmUtil.round(internalSettings.techBoni["improvedMaintenanceAccess"][3].basicRepairSpeedBonus * 100, 1)}
		}
    },
    upgrade = true,
	order = "c-c-e"
},
})
