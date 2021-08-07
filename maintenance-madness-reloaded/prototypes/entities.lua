local add_mod_prefix = require( 'util.add_mod_prefix' )
local mod_folder_path = require( 'util.mod_folder_path' )

local function add_recycler()
    data:extend( {
        {
            type = 'furnace',
            name = add_mod_prefix( 'recycler' ),
            icon = mod_folder_path( '/graphics/icons/recycler.png' ),
            icon_size = 32,
            flags = { 'placeable-neutral', 'placeable-player', 'player-creation' },
            minable = { mining_time = 1, result = add_mod_prefix( 'recycler' ) },
            max_health = 300,
            alert_icon_shift = util.by_pixel( -3, -12 ),
            corpse = 'big-remnants',
            dying_explosion = 'medium-explosion',
            resistances = { { type = 'fire', percent = 75 } },
            collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
            selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
            module_specification = {
                module_slots = 3,
                module_info_icon_shift = { 0, 0.8 }
            },
            allowed_effects = {
                'consumption',
                'speed',
                'productivity',
                'pollution'
            },
            crafting_categories = { add_mod_prefix( 'recycling' ) },
            result_inventory_size = 7,
            crafting_speed = 1,
            energy_usage = '275kW',
            source_inventory_size = 1,
            energy_source = {
                type = 'electric',
                usage_priority = 'secondary-input',
                emissions = 0.05,
                smoke = {
                    {
                        name = 'smoke',
                        frequency = 10,
                        position = { -1.0, -1.2 },
                        starting_vertical_speed = 0.08,
                        starting_frame_deviation = 60
                    }
                }
            },
            vehicle_impact_sound = {
                filename = '__base__/sound/car-metal-impact.ogg',
                volume = 0.65
            },
            working_sound = {
                sound = {
                    filename = '__base__/sound/electric-furnace.ogg',
                    volume = 0.7
                },
                apparent_volume = 1.5
            },
            animation = {
                layers = {
                    {
                        filename = mod_folder_path(
                            '/graphics/entities/recycler.png' ),
                        priority = 'high',
                        width = 107,
                        height = 113,
                        frame_count = 1,
                        shift = util.by_pixel( 0, 1 ), -- TODO
                        -- shift = {0.421875, 0},
                        hr_version = {
                            filename = mod_folder_path(
                                '/graphics/entities/hr-recycler.png' ),
                            priority = 'high',
                            width = 214,
                            height = 225,
                            frame_count = 1,
                            shift = util.by_pixel( 0, 2.25 ),
                            scale = 0.5
                            -- shift = util.by_pixel(0.75, 5.75),
                        }
                    },
                    {
                        filename = mod_folder_path(
                            '/graphics/entities/recycler-shadow.png' ),
                        priority = 'high',
                        width = 98,
                        height = 82,
                        frame_count = 1,
                        -- shift = {0.421875, 0},
                        shift = util.by_pixel( 12, 5 ),
                        draw_as_shadow = true,
                        hr_version = {
                            filename = mod_folder_path(
                                '/graphics/entities/hr-recycler-shadow.png' ),
                            priority = 'high',
                            width = 196,
                            height = 163,
                            frame_count = 1,
                            draw_as_shadow = true,
                            shift = util.by_pixel( 12, 4.75 ),
                            -- shift = util.by_pixel(11.25, 7.75),
                            scale = 0.5
                        }
                    }
                }
            },
            working_visualisations = {
                {
                    animation = {
                        filename = mod_folder_path(
                            '/graphics/entities/recycler-propeller.png' ),
                        priority = 'high',
                        width = 19,
                        height = 13,
                        frame_count = 4,
                        animation_speed = 0.5,
                        shift = util.by_pixel( 7, -18.5 ),
                        hr_version = {
                            filename = mod_folder_path(
                                '/graphics/entities/hr-recycler-propeller.png' ),
                            priority = 'high',
                            width = 37,
                            height = 25,
                            frame_count = 4,
                            animation_speed = 0.5,
                            shift = util.by_pixel( 7, -16.5 ),
                            scale = 0.5
                        }
                    }
                }
            }
        }
    } )
end

local function add_maintenance_unit()
    data:extend( {
        {
            type = 'container',
            name = add_mod_prefix( 'simple-maintenance-unit' ),
            icon = mod_folder_path(
                '/graphics/icons/simple-maintenance-unit-icon.png' ),
            icon_size = 64,
            flags = { 'placeable-neutral', 'player-creation' },
            minable = {
                mining_time = 0.2,
                result = add_mod_prefix( 'simple-maintenance-unit' )
            },
            max_health = 250,
            corpse = 'small-remnants',
            open_sound = {
                filename = '__base__/sound/metallic-chest-open.ogg',
                volume = 0.65
            },
            close_sound = {
                filename = '__base__/sound/metallic-chest-close.ogg',
                volume = 0.7
            },
            resistances = {
                { type = 'fire', percent = 75 },
                { type = 'impact', percent = 60 }
            },
            collision_box = { { -0.35, -0.35 }, { 0.35, 0.35 } },
            selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
            inventory_size = 12,
            vehicle_impact_sound = {
                filename = '__base__/sound/car-metal-impact.ogg',
                volume = 0.65
            },
            -- radius_visualisation_specification = {
            --     filename = mod_folder_path(
            --         '/graphics/entities/maintenance-unit-radius-visualization.png' ),
            --     priority = 'extra-high-no-scale',
            --     width = 10,
            --     height = 10
            -- },
            picture = {
                layers = {
                    {
                        filename = mod_folder_path(
                            '/graphics/entities/simple-maintenance-unit.png' ),
                        priority = 'extra-high',
                        width = 35,
                        height = 42,
                        shift = util.by_pixel( 0, -1.5 ),
                        hr_version = {
                            filename = mod_folder_path(
                                '/graphics/entities/hr-simple-maintenance-unit.png' ),
                            priority = 'extra-high',
                            width = 70,
                            height = 84,
                            shift = util.by_pixel( 0.75, -1.5 ),
                            scale = 0.5
                        }
                    },
                    {
                        filename = mod_folder_path(
                            '/graphics/entities/simple-maintenance-unit-shadow.png' ),
                        priority = 'extra-high',
                        width = 56,
                        height = 22,
                        shift = util.by_pixel( 12, 7.5 ),
                        draw_as_shadow = true,
                        hr_version = {
                            filename = mod_folder_path(
                                '/graphics/entities/hr-simple-maintenance-unit-shadow.png' ),
                            priority = 'extra-high',
                            width = 110,
                            height = 46,
                            shift = util.by_pixel( 12.25, 8 ),
                            draw_as_shadow = true,
                            scale = 0.5
                        }
                    }
                }
            },
            circuit_wire_connection_point = circuit_connector_definitions['chest']
                .points,
            circuit_connector_sprites = circuit_connector_definitions['chest']
                .sprites,
            circuit_wire_max_distance = default_circuit_wire_max_distance
        }
    } )
end

local function add_flying_text()
    data:extend( {
        {
            type = 'flying-text',
            name = add_mod_prefix( 'flying-text' ),
            flags = { 'not-on-map', 'placeable-off-grid' },
            time_to_live = 165,
            speed = 0.01,
            text_alignment = 'center'
        }
    } )
end

local function add_request_proxy( name, graphics_path )
    data:extend( {
        {
            type = 'item-request-proxy',
            name = add_mod_prefix( name ),
            picture = {
                filename = mod_folder_path( graphics_path ),
                flags = { 'icon' },
                priority = 'extra-high',
                width = 64,
                height = 64,
                shift = { 0, 0 },
                scale = 0.5
            },
            use_target_entity_alert_icon_shift = true,
            flags = {
                'not-on-map',
                'placeable-off-grid',
                'not-blueprintable',
                'not-deconstructable'
            },
            -- minable = {minable = false}, --{ mining_time = 0, results={}},
            collision_box = { { 0, 0 }, { 0, 0 } },
            selection_box = { { -0.5, -0.4 }, { 0.5, 0.6 } }
        }
    } )
end

add_recycler()
add_maintenance_unit()

add_request_proxy( 'maintenance-request-proxy',
                   '/graphics/icons/maintenance-needed.png' )
add_request_proxy( 'repair-request-proxy',
                   '/graphics/icons/machine-malfunction.png' )
add_request_proxy( 'secondary-repair-request-proxy',
                   '/graphics/icons/repair-pending.png' )
add_request_proxy( 'replacement-request-proxy',
                   '/graphics/icons/replacement-request.png' )
add_request_proxy( 'forced-replacement-request-proxy',
                   '/graphics/icons/replacement-required.png' )
