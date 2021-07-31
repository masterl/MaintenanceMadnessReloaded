local mm_util = require("util.util")

data:extend({
	{
		type = "recipe",
		name = "mm-toolbox",
		enabled = false,
		energy_required = 16,
		ingredients =
		{
			{"repair-pack", 5},
			{"electric-engine-unit", 2},
			{"mm-machine-oil", 2},
			{"mm-electronical-spare-parts", 5},
			{"mm-mechanical-spare-parts", 10}
		},
		result = "mm-toolbox"
	},
	{
		type = "recipe",
		name = "mm-machine-oil",
		enabled = false,
		energy_required = 1,
		category = "crafting-with-fluid",
		ingredients =
		{
			{type = "fluid", name="lubricant", amount = 3},
			{type = "item", name="iron-plate", amount = 1}
		},
		result = "mm-machine-oil"
	},
	{
		type = "recipe",
		name = "mm-mechanical-spare-parts",
		enabled = false,
		energy_required = 10,
		ingredients =
		{
			{"iron-gear-wheel", 2},
			{"iron-stick", 2},
			{"steel-plate", 1}
		},
		result = "mm-mechanical-spare-parts",
		result_count = 10
	},
	{
		type = "recipe",
		name = "mm-electronical-spare-parts",
		enabled = false,
		energy_required = 10,
		ingredients =
		{
			{"copper-cable", 4},
			{"electronic-circuit", 3},
			{"battery", 1}
		},
		result = "mm-electronical-spare-parts",
		result_count = 10
	},
	{
		type = "recipe",
		name = "mm-detergent",
		enabled = false,
		energy_required = 2,
		category = "chemistry",
		ingredients =
		{
			{type = "fluid", name="water", amount = 15},
			{type = "fluid", name="petroleum-gas", amount = 4},
			{type = "item", name="plastic-bar", amount = 1}
		},
		result = "mm-detergent",
		result_count = 2,
		crafting_machine_tint =
		{
			primary = {r = 0.90, g = 0.75, b = 0.90, a = 0.000}, -- #49060000
			secondary = {r = 0.15, g = 0.35, b = 0.56, a = 0.000}, -- #b8763000
			tertiary = {r = 0.60, g = 0.50, b = 0.60, a = 0.000}, -- #dd5d0000
		}
	},
	{
		type = "recipe",
		name = "mm-recycler",
		enabled = false,
		energy_required = 5,
		ingredients =
		{
			{"engine-unit", 3},
			{"electronic-circuit", 10},
			{"iron-gear-wheel", 10},
			{"concrete", 15},
			{"steel-plate", 15}
		},
		result = "mm-recycler"
	},
	{
		type = "recipe",
		name = "mm-simple-maintenance-unit",
		enabled = false,
		energy_required = 2,
		ingredients =
		{
			{"electronic-circuit", 5},
			{"iron-gear-wheel", 5},
			{"steel-chest", 1},
			{"inserter", 1}
		},
		result = "mm-simple-maintenance-unit"
	}

})
mm_util.add_recipe_to_tech("mm-detergent", "plastics")
mm_util.add_recipe_to_tech("mm-machine-oil", "lubricant")
mm_util.add_recipe_to_tech("mm-mechanical-spare-parts", "steel-processing")
mm_util.add_recipe_to_tech("mm-electronical-spare-parts", "battery")
