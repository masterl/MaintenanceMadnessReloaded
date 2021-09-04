local constants = require( 'constants' )
local mod_helpers = require( 'util.mod_helpers' )
local merge_tables = require( 'util.merge_tables' )
local get_ingredient_amount = require( 'util.get_ingredient_amount' )
local get_bounding_box_dimensions =
    require( 'util.get_bounding_box_dimensions' )
local rotate_bounding_box = require( 'util.rotate_bounding_box' )
local get_max_icon_size = require( 'util.get_max_icon_size' )

local this_mod = mod_helpers.this_mod
local base_mod = mod_helpers.base_mod

local recycle_time_multiplier = constants.recycle_time_multiplier
local recondition_time_multiplier = constants.recondition_time_multiplier
local maintenance_units_defaults = constants.maintenance_units_defaults

-- https://wiki.factorio.com/Data.raw
-- ? Can't this be done on data-updates?

---Get maintenance unit prototypes from container prototypes list
---@param container_prototypes table
---@return table
local function get_maintenance_units_prototypes( container_prototypes )
    local units = {}

    for k, _ in pairs( maintenance_units_defaults ) do
        units[k] = container_prototypes[k]
    end

    return units
end

local units_prototypes = get_maintenance_units_prototypes( data.raw.container )

for unit_name, unit_data in pairs( units_prototypes ) do
    local chest_item = data.raw.item[unit_name]
    local unit_defaults = maintenance_units_defaults[unit_name]

    unit_data.localised_description = {
        this_mod:add_prefix( 'style-label-maintenance-unit-description' ),
        { 'entity-description.' .. unit_name },
        { this_mod:add_prefix( 'generic-maintenance-unit' ) },
        { 'tooltip-category.consumes' },
        { 'tooltip-category.electricity' },
        { 'description.energy-consumption' },
        unit_defaults.energy_usage
    }

    local hidden_energy_interface_item = {
        type = 'item',
        name = unit_name .. '-electric-energy-interface',
        icons = { { icon = chest_item.icon } },
        icon_size = chest_item.icon_size,
        flags = { 'hidden' },
        subgroup = 'energy',
        order = 'e[electric-energy-interface]-c',
        place_result = unit_name .. '-electric-energy-interface',
        stack_size = 50
    }

    local hidden_energy_interface = table.deepcopy(
                                        data.raw['electric-energy-interface']['hidden-electric-energy-interface'] )
    hidden_energy_interface.name = hidden_energy_interface_item.name
    hidden_energy_interface.icon = nil
    hidden_energy_interface.icons = hidden_energy_interface_item.icons
    hidden_energy_interface.icon_size = hidden_energy_interface_item.icon_size
    hidden_energy_interface.selection_box = unit_data.selection_box
    hidden_energy_interface.localised_name = { 'entity-name.' .. unit_name }
    hidden_energy_interface.localised_description =
        unit_data.localised_description
    hidden_energy_interface.max_health = unit_data.max_health
    hidden_energy_interface.Healing_per_tick = unit_data.max_health
    hidden_energy_interface.create_ghost_on_death = false
    hidden_energy_interface.allow_copy_paste = false
    hidden_energy_interface.flags = {
        'placeable-neutral',
        'player-creation',
        'placeable-off-grid',
        'not-on-map',
        'not-blueprintable',
        'not-deconstructable',
        'hide-alt-info'
    }

    local energy_source = {
        type = 'electric',
        usage_priority = 'secondary-input',
        buffer_capacity = unit_defaults.energy_buffer,
        input_flow_limit = unit_defaults.energy_usage
        -- drain = unit_defaults.energy_usage
    }
    hidden_energy_interface.energy_source = energy_source
    hidden_energy_interface.energy_production = nil
    hidden_energy_interface.energy_usage = unit_defaults.energy_usage

    local placement_entity_item = {
        type = 'item',
        name = unit_name .. '-placement-entity',
        localised_name = { 'entity-name.' .. unit_name },
        localised_description = { 'item-description.' .. unit_name },
        icons = { { icon = chest_item.icon } },
        icon_size = chest_item.icon_size,
        flags = chest_item.flags,
        subgroup = chest_item.subgroup,
        order = chest_item.order,
        place_result = unit_name .. '-placement-entity',
        stack_size = chest_item.stack_size
    }
    unit_data.minable.result = placement_entity_item.name
    unit_data.create_ghost_on_death = false

    local placement_entity = {
        type = 'beacon',
        name = unit_name .. '-placement-entity',
        localised_name = { 'entity-name.' .. unit_name },
        localised_description = { 'item-description.' .. unit_name },
        icons = { { icon = chest_item.icon } },
        icon_size = chest_item.icon_size,
        flags = unit_data.flags,
        minable = unit_data.minable,
        max_health = unit_data.max_health,
        corpse = unit_data.corpse,
        dying_explosion = 'medium-explosion',
        collision_box = unit_data.collision_box,
        selection_box = unit_data.selection_box,
        allowed_effects = {},
        base_picture = unit_data.picture,
        circuit_wire_connection_point = circuit_connector_definitions['chest']
            .points,
        circuit_connector_sprites = circuit_connector_definitions['chest']
            .sprites,
        circuit_wire_max_distance = default_circuit_wire_max_distance,
        animation = {
            filename = this_mod:get_graphics_path( 'dummy.png' ),
            width = 1,
            height = 1,
            frame_count = 1,
            animation_speed = 1
        },
        animation_shadow = {
            filename = this_mod:get_graphics_path( 'dummy.png' ),
            width = 1,
            height = 1,
            frame_count = 1,
            animation_speed = 1
        },
        radius_visualisation_picture = {
            filename = this_mod:get_graphics_path(
                'entities/maintenance-unit-radius-visualization.png' ),
            priority = 'extra-high-no-scale',
            width = 10,
            height = 10
        },
        supply_area_distance = unit_defaults.radius,
        energy_source = hidden_energy_interface.energy_source,
        vehicle_impact_sound = {
            filename = base_mod:get_sounds_path( 'car-metal-impact.ogg' ),
            volume = 0.65
        },
        energy_usage = hidden_energy_interface.energy_usage,
        distribution_effectivity = 1,
        module_specification = {
            module_slots = 0,
            module_info_icon_shift = { 0, 0.5 },
            module_info_multi_row_initial_height_modifier = -0.3
        }
    }

    local placement_entity_recipe = table.deepcopy( data.raw.recipe[unit_name] )
    placement_entity_recipe.name = unit_name .. '-placement-entity'
    placement_entity_recipe.result = unit_name .. '-placement-entity'
    data.raw.recipe[unit_name] = nil -- delete original recipe

    chest_item.flags = { 'hidden' }

    if data.raw.technology[this_mod:add_prefix( 'repair-and-maintenance' )] then
        -- Add this recipe to the "repair-and-maintenance" tech
        local recipe_effect = {
            type = 'unlock-recipe',
            recipe = placement_entity_recipe.name
        }

        table.insert( data.raw.technology[this_mod:add_prefix(
                          'repair-and-maintenance' )].effects, recipe_effect )
    end

    data:extend( {
        hidden_energy_interface,
        hidden_energy_interface_item,
        placement_entity,
        placement_entity_item,
        placement_entity_recipe
    } )
end

---Checks whether the prototype is of a faulty entity.
---@param prototype_name string
---@return boolean
local function is_faulty( prototype_name )
    return string.sub( prototype_name, 1, 10 ) ==
               this_mod:add_prefix( 'faulty-' )
end

---Process entity prototype generating maintenance options, if applicable.
---@param prototype_group string
---@param entity_prototype table
local function process_entity_prototype( prototype_group,
                                         prototype )
    local prototype_name = prototype.name

    if is_faulty( prototype_name ) or prototype_group == 'beacon' and
        string.find( prototype_name, '-placement%-entity' ) ~= nil then
        -- Ignore faulty versions of solar-panels or accumulators created by this mod
        -- Ignore placement entities for maintenance units
        return
    end

    local recipe = nil

    if data.raw.recipe[prototype_name] then
        recipe = data.raw.recipe[prototype_name]
    else
        -- If no recipe for an entity is found, there is no way to determine repair costs
        -- Skip this entity.
        log( 'Missing recipe for: ' .. prototype_name ..
                 '. Maintenance for this entity will be disabled.' )
        return
    end

    local item = nil

    if data.raw.item[prototype_name] then
        item = data.raw.item[prototype_name]
    else
        -- If no recipe for an entity is found, there is no way to create a scrap item
        -- Skip this entity.
        log( 'Missing item for: ' .. prototype_name ..
                 '. Maintenance for this entity will be disabled.' )
        return
    end

    local default_remnant_icon = {
        icon = base_mod:get_graphics_path( 'icons/remnants.png' ),
        tint = { a = 1, r = 0.8, g = 0.4, b = 0.3 },
        icon_size = 64,
        icon_mipmaps = 4
    }

    local item_icon = nil
    if item.icons then -- Multi layered icons
        item_icon = table.deepcopy( item.icons )

        for _, item_layer in pairs( item_icon ) do
            item_layer.tint = { a = 1, r = 0.8, g = 0.4, b = 0.3 }
            item_layer.scale = (32 /
                                   (item_layer.icon_size or item.icon_size or 64)) *
                                   0.9 -- bigger icon sizes will be resized to fit into 32x32
        end

        table.insert( item_icon, 1, default_remnant_icon )
    else
        local item_icon_scale = (32 / item.icon_size) * 0.9 -- bigger icon sizes will be resized to fit into 32x32

        item_icon = {
            default_remnant_icon,
            {
                icon = item.icon,
                scale = item_icon_scale,
                tint = { a = 1, r = 0.8, g = 0.4, b = 0.3 },
                icon_size = item.icon_size,
                icon_mipmaps = item.icon_mipmaps
            }
        }
    end

    local scrapped_item = {
        -- Basic info
        type = 'item',
        name = this_mod:add_prefix( 'scrapped-' .. prototype_name ),
        localised_name = {
            this_mod:add_prefix( 'item-name-scrap' ),
            { 'entity-name.' .. prototype_name }
        },
        -- icon = item.icon,
        icons = item_icon,
        icon_size = item.icon_size,
        flags = {},
        subgroup = this_mod:add_prefix( 'scrap' ),
        order = item.order,
        stack_size = item.stack_size,
        allow_decomposition = false
    }

    local time_needed = recipe.energy_required or 0.5
    local recycling_icon = table.deepcopy( item_icon )

    table.insert( recycling_icon, {
        icon = this_mod:get_graphics_path( 'icons/recycle-32px.png' ),
        scale = 0.7,
        icon_size = 32
    } )

    local recycling_recipe = {
        type = 'recipe',
        name = this_mod:add_prefix( 'recycle-' .. prototype_name ),
        localised_name = {
            this_mod:add_prefix( 'recipe-name-recycling' ),
            { 'entity-name.' .. prototype_name }
        },
        category = this_mod:add_prefix( 'recycling' ),
        icons = recycling_icon,
        icon_size = item.icon_size,
        subgroup = this_mod:add_prefix( 'recycling' ),
        order = item.order
    }

    local recycling_recipe_specs = {
        enabled = true,
        hidden = true,
        results = {},
        ingredients = {
            { this_mod:add_prefix( 'scrapped-' .. prototype_name ), 1 }
        },
        energy_required = math.max( time_needed * recycle_time_multiplier,
                                    constants.recycle_time_minimum ),
        allow_decomposition = false,
        allow_as_intermediate = false,
        allow_intermediates = false,
        always_show_products = true,
        show_amount_in_title = false,
        main_product = nil
    }

    local recondition_icon = table.deepcopy( item_icon )

    table.insert( recondition_icon, {
        icon = base_mod:get_graphics_path( 'icons/repair-pack.png' ),
        scale = (32 / 64) * 0.7,
        icon_size = 64,
        icon_mipmaps = 4
    } )

    local recondition_recipe = {
        type = 'recipe',
        name = this_mod:add_prefix( 'recondition-' .. prototype_name ),
        localised_name = {
            this_mod:add_prefix( 'recipe-name-recondition' ),
            { 'entity-name.' .. prototype_name }
        },
        -- category = "centrifuging",
        icons = recondition_icon,
        icon_size = item.icon_size,
        subgroup = this_mod:add_prefix( 'recondition' ),
        order = item.order
    }

    local recondition_recipe_specs = {
        enabled = false,
        results = { { type = 'item', name = prototype_name, amount = 1 } },
        ingredients = {
            { this_mod:add_prefix( 'scrapped-' .. prototype_name ), 1 },
            { this_mod:add_prefix( 'toolbox' ), 1 }
        },
        energy_required = math.max( time_needed * recondition_time_multiplier,
                                    constants.recondition_time_minimum ),
        allow_decomposition = false,
        allow_as_intermediate = false,
        allow_intermediates = false,
        always_show_products = true,
        show_amount_in_title = false,
        main_product = nil
    }

    if recipe.normal ~= nil or recipe.expensive ~= nil then
        -- If this is a recipe with "normal" and/or "expensive" cost, create normal/expensive recipe cost for the recycling/recondition items, too
        if recipe.normal then
            recycling_recipe.normal = table.deepcopy( recycling_recipe_specs )
            recondition_recipe.normal =
                table.deepcopy( recondition_recipe_specs )
            for _, ingredient in pairs( recipe.normal.ingredients ) do
                local amount = get_ingredient_amount( ingredient )
                if ingredient.type ~= 'fluid' and amount >= 2 then
                    table.insert( recycling_recipe.normal.results, {
                        type = 'item',
                        name = ingredient.name or ingredient[1],
                        amount_min = math.floor( amount / 5 ),
                        amount_max = math.floor( amount / 2 )
                    } )
                    table.insert( recondition_recipe.normal.ingredients, {
                        type = 'item',
                        name = ingredient.name or ingredient[1],
                        amount = math.floor( amount *
                                                 constants.recondition_spare_parts_factor )
                    } )
                end
            end
        else
            recycling_recipe.normal = recipe.normal -- nil or false
            recondition_recipe.normal = recipe.normal
        end
        if recipe.expensive then
            recycling_recipe.expensive =
                table.deepcopy( recycling_recipe_specs )
            recondition_recipe.expensive = table.deepcopy(
                                               recondition_recipe_specs )
            for _, ingredient in ipairs( recipe.expensive.ingredients ) do
                local amount = get_ingredient_amount( ingredient )
                if ingredient.type ~= 'fluid' and amount >= 2 then
                    table.insert( recycling_recipe.expensive.results, {
                        type = 'item',
                        name = ingredient.name or ingredient[1],
                        amount_min = math.floor( amount / 5 ),
                        amount_max = math.floor( amount / 2 )
                    } )
                    table.insert( recondition_recipe.expensive.ingredients, {
                        type = 'item',
                        name = ingredient.name or ingredient[1],
                        amount = math.floor( amount *
                                                 constants.recondition_spare_parts_factor )
                    } )
                end
            end
        else
            recycling_recipe.expensive = recipe.expensive -- nil or false
            recondition_recipe.expensive = recipe.expensive
        end
    else
        merge_tables( recycling_recipe, table.deepcopy( recycling_recipe_specs ) )
        merge_tables( recondition_recipe,
                      table.deepcopy( recondition_recipe_specs ) )
        for _, ingredient in ipairs( recipe.ingredients ) do
            local amount = get_ingredient_amount( ingredient )
            if ingredient.type ~= 'fluid' and amount >= 2 then
                -- Recondition demands 50% of the initial spent resources. This implies an item amount > 1.
                table.insert( recycling_recipe.results, {
                    type = 'item',
                    name = ingredient.name or ingredient[1],
                    amount_min = math.floor( amount / 5 ),
                    amount_max = math.floor( amount / 2 )
                } )
                -- Recondition demands a certain percentage of the initial spent resources.
                table.insert( recondition_recipe.ingredients, {
                    type = 'item',
                    name = ingredient.name or ingredient[1],
                    amount = math.floor( amount *
                                             constants.recondition_spare_parts_factor )
                } )
            end
        end
    end

    local dummy = {
        filename = this_mod:get_graphics_path( 'dummy.png' ),
        priority = 'high',
        width = 1,
        height = 1,
        frame_count = 1
    }

    local requester_container = {
        -- This chest is required as a target for item request proxies
        type = 'container',
        name = this_mod:add_prefix( 'chest-' .. prototype_name ),
        icon = base_mod:get_graphics_path( 'icons/wooden-chest.png' ),
        icon_size = 64,
        icon_mipmaps = 4,
        flags = {
            'placeable-neutral',
            'player-creation',
            'placeable-off-grid',
            'not-on-map',
            'not-blueprintable',
            'not-deconstructable',
            'not-upgradable',
            'hide-alt-info',
            'no-automated-item-removal',
            'no-automated-item-insertion'
        },
        -- minable = false,
        max_health = 10000, -- invincible, removed only via script
        -- healing_per_tick = 10000,
        corpse = 'small-remnants',
        collision_box = prototype.collision_box,
        selection_box = prototype.selection_box,
        collision_mask = { 'not-colliding-with-itself' },
        order = 'z',
        alert_icon_shift = prototype.alert_icon_shift,
        inventory_size = 8,
        open_sound = {
            filename = base_mod:get_sounds_path( 'wooden-chest-open.ogg' )
        },
        close_sound = {
            filename = base_mod:get_sounds_path( 'wooden-chest-close.ogg' )
        },
        vehicle_impact_sound = {
            filename = base_mod:get_sounds_path( 'car-wood-impact.ogg' ),
            volume = 1.0
        },
        picture = dummy,
        create_ghost_on_death = false,
        allow_copy_paste = false
    }

    local dimensions = get_bounding_box_dimensions(
                           (requester_container.selection_box or
                               requester_container.collision_box) )
    -- If an entity hat a non square base, add a rotated version of the maintenance chest
    -- If an entity does not have a selection box, use collision box instead
    local requester_container_rotated = nil

    if dimensions.width ~= dimensions.height then
        requester_container_rotated = table.deepcopy( requester_container )
        requester_container_rotated.name =
            this_mod:add_prefix( 'chest-rotated-' .. prototype_name )
        requester_container_rotated.collision_box =
            rotate_bounding_box( requester_container.collision_box )
        requester_container_rotated.selection_box =
            rotate_bounding_box( requester_container.selection_box )
    end

    data:extend( {
        scrapped_item,
        recycling_recipe,
        recondition_recipe,
        requester_container
    } )

    if requester_container_rotated then
        data:extend( { requester_container_rotated } )
    end

    local recondition_tech = data.raw.technology[this_mod:add_prefix(
                                 'recondition' )]

    if recondition_tech then
        -- Add this recipe to the "recondition" tech
        local recipe_effect = {
            type = 'unlock-recipe',
            recipe = recondition_recipe.name
        }

        table.insert( recondition_tech.effects, recipe_effect )
    end

    if prototype_group == 'solar-panel' or prototype_group == 'accumulator' then
        -- Solar panels and accumulators need special treatment, because simply setting the "active" property to "false" doesn't do anything.
        -- With this function, we create "faulty" versions of them with much less energy output, simulating the effect of malfunctions.
        -- If a solar panel or an accumulator breaks down, it has to be replaced by a "faulty" one by script.

        local faulty_entity_icon
        local maxIconSize = get_max_icon_size( item, 32 )
        if item.icons then -- Multi layered icons
            faulty_entity_icon = table.deepcopy( item.icons )
            table.insert( faulty_entity_icon, {
                icon = this_mod:get_graphics_path(
                    'icons/machine-malfunction-small.png' ),
                scale = maxIconSize / 32,
                icon_size = 32
            } )
        else
            faulty_entity_icon = {
                {
                    icon = item.icon,
                    scale = maxIconSize / (item.icon_size or 32),
                    icon_size = item.icon_size,
                    icon_mipmaps = item.icon_mipmaps
                },
                {
                    icon = this_mod:get_graphics_path(
                        'icons/machine-malfunction-small.png' ),
                    scale = maxIconSize / 32,
                    icon_size = 32
                }
            }
        end

        local faulty_entity = table.deepcopy( prototype )
        -- local faulty_entity

        faulty_entity.name = this_mod:add_prefix( 'faulty-' .. prototype_name )
        faulty_entity.localised_name = {
            this_mod:add_prefix( 'faulty-entity-name' ),
            { 'entity-name.' .. prototype_name }
        }
        faulty_entity.icons = faulty_entity_icon
        faulty_entity.icon = nil
        faulty_entity.icon_size = item.icon_size
        if prototype.localised_desctription ~= nil then
            faulty_entity.localised_desctription = {
                'entity-description.' .. prototype_name
            }
        end

        if prototype_group == 'solar-panel' then
            faulty_entity.production = '5kW'
        else
            -- accumulator
            faulty_entity.energy_source.input_flow_limit = '25kW'
        end
        -- faultyEntity.order = "z"

        local faulty_entity_item = {
            type = 'item',
            name = faulty_entity.name,
            place_result = faulty_entity.name,
            localised_name = item.localised_name,
            -- icon = item.icon,
            icons = faulty_entity_icon,
            icon_size = item.icon_size,
            flags = { 'hidden' },
            subgroup = this_mod:add_prefix( 'faulty-entity' ),
            order = item.order,
            stack_size = item.stack_size
        }

        data:extend( { faulty_entity, faulty_entity_item } )
    end
end

-- ? should't this get what is actually enabled on settings
-- ?    instead of default enables?
for prototype_group, _ in pairs( constants.enabled_entity_types ) do
    for __, entity_prototype in pairs( data.raw[prototype_group] ) do
        process_entity_prototype( prototype_group, entity_prototype )
    end
end

local proxies = {
    [this_mod:add_prefix( 'maintenance-request-proxy' )] = {
        this_mod:add_prefix( 'generic-manual-spareparts' )
    },
    [this_mod:add_prefix( 'repair-request-proxy' )] = {
        this_mod:add_prefix( 'generic-manual-repair' )
    },
    [this_mod:add_prefix( 'secondary-repair-request-proxy' )] = {
        this_mod:add_prefix( 'generic-manual-spareparts' )
    },
    [this_mod:add_prefix( 'replacement-request-proxy' )] = {
        this_mod:add_prefix( 'generic-manual-replacement' )
    },
    [this_mod:add_prefix( 'forced-replacement-request-proxy' )] = {
        this_mod:add_prefix( 'generic-manual-replacement' )
    }
}

for proxy_name, additional_description in pairs( proxies ) do
    local locale = { 'entity-description.' .. proxy_name }

    data.raw['item-request-proxy'][proxy_name].localised_description = {
        this_mod:add_prefix( 'style-label-entity-description' ),
        locale,
        additional_description
    }
end
