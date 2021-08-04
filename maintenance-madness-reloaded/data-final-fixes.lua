-- Maintenance Madness - 2019. Created by Arcitos. License: See mod page.
local mm_util = require( 'util.util' )
local internalSettings = require( 'config-startup' )

local recycleTimeMultiplier = internalSettings.recycleTimeMultiplier
local reconditionTimeMultiplier = internalSettings.reconditionTimeMultiplier

for _, chest in pairs( data.raw.container ) do
    if internalSettings.maintenanceUnits[chest.name] then
        local chestItem = data.raw.item[chest.name]

        data.raw['container'][chest.name].localised_description = {
            'mm-style-label-maintenance-unit-description',
            { 'entity-description.' .. chest.name },
            { 'mm-generic-maintenance-unit' },
            { 'tooltip-category.consumes' },
            { 'tooltip-category.electricity' },
            { 'description.energy-consumption' },
            internalSettings.maintenanceUnits[chest.name].energyUsage
        }

        local hiddenEnergyInterfaceItem = {
            type = 'item',
            name = chest.name .. '-electric-energy-interface',
            icons = { { icon = chestItem.icon } },
            icon_size = chestItem.icon_size,
            flags = { 'hidden' },
            subgroup = 'energy',
            order = 'e[electric-energy-interface]-c',
            place_result = chest.name .. '-electric-energy-interface',
            stack_size = 50
        }

        local hiddenEnergyInterface = table.deepcopy(
                                          data.raw['electric-energy-interface']['hidden-electric-energy-interface'] )
        hiddenEnergyInterface.name = hiddenEnergyInterfaceItem.name
        hiddenEnergyInterface.icon = nil
        hiddenEnergyInterface.icons = hiddenEnergyInterfaceItem.icons
        hiddenEnergyInterface.icon_size = hiddenEnergyInterfaceItem.icon_size
        hiddenEnergyInterface.selection_box = chest.selection_box
        hiddenEnergyInterface.localised_name = { 'entity-name.' .. chest.name }
        hiddenEnergyInterface.localised_description =
            data.raw['container'][chest.name].localised_description
        hiddenEnergyInterface.max_health = chest.max_health
        hiddenEnergyInterface.Healing_per_tick = chest.max_health
        hiddenEnergyInterface.create_ghost_on_death = false
        hiddenEnergyInterface.allow_copy_paste = false
        hiddenEnergyInterface.flags = {
            'placeable-neutral',
            'player-creation',
            'placeable-off-grid',
            'not-on-map',
            'not-blueprintable',
            'not-deconstructable',
            'hide-alt-info'
        }
        local energySource = {
            type = 'electric',
            usage_priority = 'secondary-input',
            buffer_capacity = internalSettings.maintenanceUnits[chest.name]
                .energyBuffer,
            input_flow_limit = internalSettings.maintenanceUnits[chest.name]
                .energyUsage
            -- drain = internalSettings.maintenanceUnits[chest.name].energyUsage
        }
        hiddenEnergyInterface.energy_source = energySource
        hiddenEnergyInterface.energy_production = nil
        hiddenEnergyInterface.energy_usage =
            internalSettings.maintenanceUnits[chest.name].energyUsage
        local placementEntityItem = {
            type = 'item',
            name = chest.name .. '-placement-entity',
            localised_name = { 'entity-name.' .. chest.name },
            localised_description = { 'item-description.' .. chest.name },
            icons = { { icon = chestItem.icon } },
            icon_size = chestItem.icon_size,
            flags = chestItem.flags,
            subgroup = chestItem.subgroup,
            order = chestItem.order,
            place_result = chest.name .. '-placement-entity',
            stack_size = chestItem.stack_size
        }
        chest.minable.result = placementEntityItem.name
        chest.create_ghost_on_death = false

        local placementEntity = {
            type = 'beacon',
            name = chest.name .. '-placement-entity',
            localised_name = { 'entity-name.' .. chest.name },
            localised_description = { 'item-description.' .. chest.name },
            icons = { { icon = chestItem.icon } },
            icon_size = chestItem.icon_size,
            flags = chest.flags,
            minable = chest.minable,
            max_health = chest.max_health,
            corpse = chest.corpse,
            dying_explosion = 'medium-explosion',
            collision_box = chest.collision_box,
            selection_box = chest.selection_box,
            allowed_effects = {},
            base_picture = chest.picture,
            circuit_wire_connection_point = circuit_connector_definitions['chest']
                .points,
            circuit_connector_sprites = circuit_connector_definitions['chest']
                .sprites,
            circuit_wire_max_distance = default_circuit_wire_max_distance,
            --[[{
			  filename = "__base__/graphics/entity/beacon/beacon-base.png",
			  width = 116,
			  height = 93,
			  shift = { 0.34375, 0.046875}
			},]]
            animation = {
                filename = '__maintenance-madness-reloaded__/graphics/dummy.png',
                width = 1,
                height = 1,
                frame_count = 1,
                animation_speed = 1
            },
            animation_shadow = {
                filename = '__maintenance-madness-reloaded__/graphics/dummy.png',
                width = 1,
                height = 1,
                frame_count = 1,
                animation_speed = 1
            },
            radius_visualisation_picture = {
                filename = '__maintenance-madness-reloaded__/graphics/entities/maintenance-unit-radius-visualization.png',
                priority = 'extra-high-no-scale',
                width = 10,
                height = 10
            },
            supply_area_distance = internalSettings.maintenanceUnits[chest.name]
                .radius,
            energy_source = hiddenEnergyInterface.energy_source,
            vehicle_impact_sound = {
                filename = '__base__/sound/car-metal-impact.ogg',
                volume = 0.65
            },
            energy_usage = hiddenEnergyInterface.energy_usage,
            distribution_effectivity = 1,
            module_specification = {
                module_slots = 0,
                module_info_icon_shift = { 0, 0.5 },
                module_info_multi_row_initial_height_modifier = -0.3
            }
        }

        local placementEntityRecipe = table.deepcopy(
                                          data.raw.recipe[chest.name] )
        placementEntityRecipe.name = chest.name .. '-placement-entity'
        placementEntityRecipe.result = chest.name .. '-placement-entity'
        data.raw.recipe[chest.name] = nil -- delete original recipe

        chestItem.flags = { 'hidden' }

        if data.raw.technology['mm-repair-and-maintenance'] then
            -- Add this recipe to the "repair-and-maintenance" tech
            local recipeEffect = {
                type = 'unlock-recipe',
                recipe = placementEntityRecipe.name
            }

            table.insert( data.raw.technology['mm-repair-and-maintenance']
                              .effects, recipeEffect )
        end

        data:extend( {
            hiddenEnergyInterface,
            hiddenEnergyInterfaceItem,
            placementEntity,
            placementEntityItem,
            placementEntityRecipe
        } )
    end
end

for prototypeGroup, _ in pairs( internalSettings.entityTypesWithMROenabled ) do
    -- log("Processed group: "..prototypeGroup)
    for __, entityPrototype in pairs( data.raw[prototypeGroup] ) do

        local protName = entityPrototype.name
        -- log("Processed: "..protName)
        local recipe = nil
        local item = nil
        local useRotatedRequesterContainer = false
        if string.sub( protName, 1, 10 ) == 'mm-faulty-' or prototypeGroup ==
            'beacon' and string.find( protName, '-placement%-entity' ) ~= nil then
            goto continue
            -- Ignore faulty versions of solar-panels or accumulators created by this mod
            -- Ignore placement entities for maintenance units
        end
        if data.raw.recipe[protName] then
            recipe = data.raw.recipe[protName]
        else
            -- If no recipe for an entity is found, there is no way to determine repair costs - skip this entity.
            log( 'Missing recipe for: ' .. protName ..
                     '. Maintenance for this entity will be disabled.' )
            goto continue
        end
        if data.raw.item[protName] then
            item = data.raw.item[protName]
        else
            -- If no recipe for an entity is found, there is no way to create an scrap item - skip this entity.
            log( 'Missing item for: ' .. protName ..
                     '. Maintenance for this entity will be disabled.' )
            goto continue
        end

        local itemIcon
        if item.icons then -- Multi layered icons
            itemIcon = table.deepcopy( item.icons )
            for _, itemLayer in pairs( itemIcon ) do
                itemLayer.tint = { a = 1, r = 0.8, g = 0.4, b = 0.3 }
                itemLayer.scale = (32 /
                                      (itemLayer.icon_size or item.icon_size or
                                          64)) * 0.9 -- bigger icon sizes will be resized to fit into 32x32
            end
            table.insert( itemIcon, 1, {
                icon = '__base__/graphics/icons/remnants.png',
                tint = { a = 1, r = 0.8, g = 0.4, b = 0.3 },
                icon_size = 64,
                icon_mipmaps = 4
            } )
        else
            local itemIconScale = (32 / item.icon_size) * 0.9 -- bigger icon sizes will be resized to fit into 32x32
            itemIcon = {
                {
                    icon = '__base__/graphics/icons/remnants.png',
                    tint = { a = 1, r = 0.8, g = 0.4, b = 0.3 },
                    icon_size = 64,
                    icon_mipmaps = 4
                },
                {
                    icon = item.icon,
                    scale = itemIconScale,
                    tint = { a = 1, r = 0.8, g = 0.4, b = 0.3 },
                    icon_size = item.icon_size,
                    icon_mipmaps = item.icon_mipmaps
                }
            }
        end

        local scrappedItem = {
            -- Basic info
            type = 'item',
            name = 'mm-scrapped-' .. protName,
            localised_name = {
                'mm-item-name-scrap',
                { 'entity-name.' .. protName }
            },
            -- icon = item.icon,
            icons = itemIcon,
            icon_size = item.icon_size,
            flags = {},
            subgroup = 'mm-scrap',
            order = item.order,
            stack_size = item.stack_size,
            allow_decomposition = false
        }

        local timeNeeded = recipe.energy_required or 0.5
        local recyclingIcon = table.deepcopy( itemIcon )
        table.insert( recyclingIcon, {
            icon = '__maintenance-madness-reloaded__/graphics/icons/recycle-32px.png',
            scale = 0.7,
            icon_size = 32
        } )

        local recyclingRecipe = {
            type = 'recipe',
            name = 'mm-recycle-' .. protName,
            localised_name = {
                'mm-recipe-name-recyling',
                { 'entity-name.' .. protName }
            },
            category = 'mm-recycling',
            icons = recyclingIcon,
            icon_size = item.icon_size,
            subgroup = 'mm-recyling',
            order = item.order
        }
        local recyclingRecipeSpecs = {
            enabled = true,
            hidden = true,
            results = {},
            ingredients = { { 'mm-scrapped-' .. protName, 1 } },
            energy_required = math.max( timeNeeded * recycleTimeMultiplier,
                                        internalSettings.recycleTimeMinimum ),
            allow_decomposition = false,
            allow_as_intermediate = false,
            allow_intermediates = false,
            always_show_products = true,
            show_amount_in_title = false,
            main_product = nil
        }

        local reconditionIcon = table.deepcopy( itemIcon )
        table.insert( reconditionIcon, {
            icon = '__base__/graphics/icons/repair-pack.png',
            scale = (32 / 64) * 0.7,
            icon_size = 64,
            icon_mipmaps = 4
        } )

        local reconditionRecipe = {
            type = 'recipe',
            name = 'mm-recondition-' .. protName,
            localised_name = {
                'mm-recipe-name-recondition',
                { 'entity-name.' .. protName }
            },
            -- category = "centrifuging",
            icons = reconditionIcon,
            icon_size = item.icon_size,
            subgroup = 'mm-recondition',
            order = item.order
        }
        local reconditionRecipeSpecs = {
            enabled = false,
            results = { { type = 'item', name = protName, amount = 1 } },
            ingredients = {
                { 'mm-scrapped-' .. protName, 1 },
                { 'mm-toolbox', 1 }
            },
            energy_required = math.max( timeNeeded * reconditionTimeMultiplier,
                                        internalSettings.reconditionTimeMinimum ),
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
                recyclingRecipe.normal = table.deepcopy( recyclingRecipeSpecs )
                reconditionRecipe.normal = table.deepcopy(
                                               reconditionRecipeSpecs )
                for _, ingredient in pairs( recipe.normal.ingredients ) do
                    local amount = mm_util.getIngredientAmount( ingredient )
                    if ingredient.type ~= 'fluid' and amount >= 2 then
                        table.insert( recyclingRecipe.normal.results, {
                            type = 'item',
                            name = ingredient.name or ingredient[1],
                            amount_min = math.floor( amount / 5 ),
                            amount_max = math.floor( amount / 2 )
                        } )
                        table.insert( reconditionRecipe.normal.ingredients, {
                            type = 'item',
                            name = ingredient.name or ingredient[1],
                            amount = math.floor( amount *
                                                     internalSettings.reconditionSparePartFactor )
                        } )
                    end
                end
            else
                recyclingRecipe.normal = recipe.normal -- nil or false
                reconditionRecipe.normal = recipe.normal
            end
            if recipe.expensive then
                recyclingRecipe.expensive =
                    table.deepcopy( recyclingRecipeSpecs )
                reconditionRecipe.expensive = table.deepcopy(
                                                  reconditionRecipeSpecs )
                for _, ingredient in ipairs( recipe.expensive.ingredients ) do
                    local amount = mm_util.getIngredientAmount( ingredient )
                    if ingredient.type ~= 'fluid' and amount >= 2 then
                        table.insert( recyclingRecipe.expensive.results, {
                            type = 'item',
                            name = ingredient.name or ingredient[1],
                            amount_min = math.floor( amount / 5 ),
                            amount_max = math.floor( amount / 2 )
                        } )
                        table.insert( reconditionRecipe.expensive.ingredients, {
                            type = 'item',
                            name = ingredient.name or ingredient[1],
                            amount = math.floor( amount *
                                                     internalSettings.reconditionSparePartFactor )
                        } )
                    end
                end
            else
                recyclingRecipe.expensive = recipe.expensive -- nil or false
                reconditionRecipe.expensive = recipe.expensive
            end
        else
            mm_util.appendTable( recyclingRecipe,
                                 table.deepcopy( recyclingRecipeSpecs ) )
            mm_util.appendTable( reconditionRecipe,
                                 table.deepcopy( reconditionRecipeSpecs ) )
            for _, ingredient in ipairs( recipe.ingredients ) do
                local amount = mm_util.getIngredientAmount( ingredient )
                if ingredient.type ~= 'fluid' and amount >= 2 then
                    -- Recondition demands 50% of the initial spent resources. This implies an item amount > 1.
                    table.insert( recyclingRecipe.results, {
                        type = 'item',
                        name = ingredient.name or ingredient[1],
                        amount_min = math.floor( amount / 5 ),
                        amount_max = math.floor( amount / 2 )
                    } )
                    -- Recondition demands a certain percentage of the initial spent resources.
                    table.insert( reconditionRecipe.ingredients, {
                        type = 'item',
                        name = ingredient.name or ingredient[1],
                        amount = math.floor( amount *
                                                 internalSettings.reconditionSparePartFactor )
                    } )
                end
            end
        end

        local dummy = {
            filename = '__maintenance-madness-reloaded__/graphics/dummy.png',
            priority = 'high',
            width = 1,
            height = 1,
            frame_count = 1
        }
        local requesterContainer = {
            -- This chest is required as a target for item request proxies
            type = 'container',
            name = 'mm-chest-' .. protName,
            icon = '__base__/graphics/icons/wooden-chest.png',
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
            collision_box = entityPrototype.collision_box,
            selection_box = entityPrototype.selection_box,
            collision_mask = { 'not-colliding-with-itself' },
            order = 'z',
            alert_icon_shift = entityPrototype.alert_icon_shift,
            inventory_size = 8,
            open_sound = { filename = '__base__/sound/wooden-chest-open.ogg' },
            close_sound = { filename = '__base__/sound/wooden-chest-close.ogg' },
            vehicle_impact_sound = {
                filename = '__base__/sound/car-wood-impact.ogg',
                volume = 1.0
            },
            picture = dummy,
            create_ghost_on_death = false,
            allow_copy_paste = false
        }
        local dimensions = mm_util.getBoundingBoxDimensions(
                               (requesterContainer.selection_box or
                                   requesterContainer.collision_box) )
        -- If an entity hat a non square base, add a rotated version of the maintenance chest
        -- If an entity does not have a selection box, use collision box instead
        local requesterContainerRotated = {}
        if dimensions.width ~= dimensions.height then
            useRotatedRequesterContainer = true -- Flag, evaluated later on

            requesterContainerRotated = table.deepcopy( requesterContainer )
            requesterContainerRotated.name = 'mm-chest-rotated-' .. protName
            requesterContainerRotated.collision_box =
                mm_util.rotateBoundingBox( requesterContainer.collision_box )
            requesterContainerRotated.selection_box =
                mm_util.rotateBoundingBox( requesterContainer.selection_box )
        end

        -- log(serpent.block(requesterContainer, {maxlevel= 1}))

        data:extend( {
            scrappedItem,
            recyclingRecipe,
            reconditionRecipe,
            requesterContainer
        } )
        if useRotatedRequesterContainer then
            data:extend( { requesterContainerRotated } )
        end

        if data.raw.technology['mm-recondition'] then
            -- Add this recipe to the "recondition" tech
            local recipeEffect = {
                type = 'unlock-recipe',
                recipe = reconditionRecipe.name
            }

            table.insert( data.raw.technology['mm-recondition'].effects,
                          recipeEffect )
        end

        if prototypeGroup == 'solar-panel' or prototypeGroup == 'accumulator' then
            -- Solar panels and accumulators need special treatment, because simply setting the "active" property to "false" doesn't do anything.
            -- With this function, we create "faulty" versions of them with much less energy output, simulating the effect of malfunctions.
            -- If a solar panel or an accumulator breaks down, it has to be replaced by a "faulty" one by script.

            local faultyEntityIcon
            local maxIconSize = mm_util.get_maxIconSize( item, 32 )
            if item.icons then -- Multi layered icons
                faultyEntityIcon = table.deepcopy( item.icons )
                table.insert( faultyEntityIcon, {
                    icon = '__maintenance-madness-reloaded__/graphics/icons/machine-malfunction-small.png',
                    scale = maxIconSize / 32,
                    icon_size = 32
                } )
            else
                faultyEntityIcon = {
                    {
                        icon = item.icon,
                        scale = maxIconSize / (item.icon_size or 32),
                        icon_size = item.icon_size,
                        icon_mipmaps = item.icon_mipmaps
                    },
                    {
                        icon = '__maintenance-madness-reloaded__/graphics/icons/machine-malfunction-small.png',
                        scale = maxIconSize / 32,
                        icon_size = 32
                    }
                }
            end

            local faultyEntity = table.deepcopy( entityPrototype )
            faultyEntity.name = 'mm-faulty-' .. protName
            faultyEntity.localised_name = {
                'mm-faulty-entity-name',
                { 'entity-name.' .. protName }
            }
            faultyEntity.icons = faultyEntityIcon
            faultyEntity.icon = nil
            faultyEntity.icon_size = item.icon_size
            if entityPrototype.localised_desctription ~= nil then
                faultyEntity.localised_desctription = {
                    'entity-description.' .. protName
                }
            end
            if prototypeGroup == 'solar-panel' then
                faultyEntity.production = '5kW'
            elseif prototypeGroup == 'accumulator' then
                faultyEntity.energy_source.input_flow_limit = '25kW'
            end
            -- faultyEntity.order = "z"

            local faultyEntityItem = {
                type = 'item',
                name = 'mm-faulty-' .. protName,
                place_result = 'mm-faulty-' .. protName,
                localised_name = item.localised_name,
                -- icon = item.icon,
                icons = faultyEntityIcon,
                icon_size = item.icon_size,
                flags = { 'hidden' },
                subgroup = 'mm-faulty-entity',
                order = item.order,
                stack_size = item.stack_size
            }

            data:extend( { faultyEntity, faultyEntityItem } )
        end
        ::continue:: -- lua apparently doesn't know regular continue orders
    end
end

local proxies = {
    ['mm-maintenance-request-proxy'] = { 'mm-generic-manual-spareparts' },
    ['mm-repair-request-proxy'] = { 'mm-generic-manual-repair' },
    ['mm-secondary-repair-request-proxy'] = { 'mm-generic-manual-spareparts' },
    ['mm-replacement-request-proxy'] = { 'mm-generic-manual-replacement' },
    ['mm-forced-replacement-request-proxy'] = { 'mm-generic-manual-replacement' }
}

for proxyName, additionalDescription in pairs( proxies ) do
    local locale = { 'entity-description.' .. proxyName }
    data.raw['item-request-proxy'][proxyName].localised_description = {
        'mm-style-label-entity-description',
        locale,
        additionalDescription
    }
end
