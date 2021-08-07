local add_mod_prefix = require( 'util.add_mod_prefix' )

local function add_recipe( recipe )
    recipe.type = 'recipe'

    if recipe.enabled == nil then
        recipe.enabled = false
    end

    if recipe.result == nil then
        recipe.result = recipe.name
    end

    data:extend( { recipe } )
end

add_recipe( {
    name = add_mod_prefix( 'toolbox' ),
    energy_required = 16,
    ingredients = {
        { 'repair-pack', 5 },
        { 'electric-engine-unit', 2 },
        { add_mod_prefix( 'machine-oil' ), 2 },
        { add_mod_prefix( 'electronical-spare-parts' ), 5 },
        { add_mod_prefix( 'mechanical-spare-parts' ), 10 }
    }
} )

add_recipe( {
    name = add_mod_prefix( 'machine-oil' ),
    energy_required = 1,
    category = 'crafting-with-fluid',
    ingredients = {
        { type = 'fluid', name = 'lubricant', amount = 3 },
        { type = 'item', name = 'iron-plate', amount = 1 }
    }
} )

add_recipe( {
    name = add_mod_prefix( 'mechanical-spare-parts' ),
    energy_required = 10,
    ingredients = {
        { 'iron-gear-wheel', 2 },
        { 'iron-stick', 2 },
        { 'steel-plate', 1 }
    },
    result_count = 10
} )

add_recipe( {
    name = add_mod_prefix( 'electronical-spare-parts' ),
    energy_required = 10,
    ingredients = {
        { 'copper-cable', 4 },
        { 'electronic-circuit', 3 },
        { 'battery', 1 }
    },
    result_count = 10
} )

add_recipe( {
    name = add_mod_prefix( 'detergent' ),
    energy_required = 2,
    category = 'chemistry',
    ingredients = {
        { type = 'fluid', name = 'water', amount = 15 },
        { type = 'fluid', name = 'petroleum-gas', amount = 4 },
        { type = 'item', name = 'plastic-bar', amount = 1 }
    },
    result_count = 2,
    crafting_machine_tint = {
        primary = { r = 0.90, g = 0.75, b = 0.90, a = 0.000 }, -- #49060000
        secondary = { r = 0.15, g = 0.35, b = 0.56, a = 0.000 }, -- #b8763000
        tertiary = { r = 0.60, g = 0.50, b = 0.60, a = 0.000 } -- #dd5d0000
    }
} )

add_recipe( {
    name = add_mod_prefix( 'recycler' ),
    energy_required = 5,
    ingredients = {
        { 'engine-unit', 3 },
        { 'electronic-circuit', 10 },
        { 'iron-gear-wheel', 10 },
        { 'concrete', 15 },
        { 'steel-plate', 15 }
    }
} )

add_recipe( {
    name = add_mod_prefix( 'simple-maintenance-unit' ),
    energy_required = 2,
    ingredients = {
        { 'electronic-circuit', 5 },
        { 'iron-gear-wheel', 5 },
        { 'steel-chest', 1 },
        { 'inserter', 1 }
    }
} )

local function add_recipe_to_tech( recipe, technology )
    if data.raw.technology[technology] then
        table.insert( data.raw.technology[technology].effects,
                      { type = 'unlock-recipe', recipe = recipe } )
    end
end

add_recipe_to_tech( add_mod_prefix( 'detergent' ), 'plastics' )
add_recipe_to_tech( add_mod_prefix( 'machine-oil' ), 'lubricant' )
add_recipe_to_tech( add_mod_prefix( 'mechanical-spare-parts' ),
                    'steel-processing' )
add_recipe_to_tech( add_mod_prefix( 'electronical-spare-parts' ), 'battery' )
