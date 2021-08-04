local mod_gui = require( 'mod-gui' )
local mmUtil = require( 'util.util' )
local mmGUI = {}
local mceil = math.ceil
local mfloor = math.floor

local const = require( 'config-runtime' )

function mmGUI.toggleMainButton( player_index )
    local players
    if player_index == nil then
        players = game.players
    else
        players = { game.players[player_index] }
    end
    for _, player in pairs( players ) do
        local mainFlow = mod_gui.get_button_flow( player )
        local button = mainFlow['maintenanceMadness-mainButton']

        if button then
            button.destroy()
            button = nil
        end

        if not button then
            button = mainFlow.add {
                type = 'sprite-button',
                name = 'maintenanceMadness-mainButton',
                sprite = 'repair-pending-icon',
                style = mod_gui.button_style
            }
        end
    end
end

local function buildTitlebar( parent, name, data )
    local prefix = name .. '-'

    local titlebar_flow = parent.add {
        type = 'flow',
        name = prefix .. 'flow',
        style = 'slot_table_spacing_horizontal_flow'
    }

    if data.label then
        titlebar_flow.add {
            type = 'label',
            name = prefix .. 'label',
            style = 'frame_title',
            caption = { data.label }
        }
    end

    local filler = titlebar_flow.add {
        type = 'empty-widget',
        name = prefix .. 'filler',
        style = 'draggable_space_header'
    }
    filler.style.horizontally_stretchable = true
    if data.draggable then
        filler.drag_target = parent
        filler.style.natural_height = 24
    end

    if data.buttons then
        filler.style.right_margin = 7
        local buttons = data.buttons
        for i = 1, #buttons do
            titlebar_flow.add {
                type = 'sprite-button',
                name = prefix .. buttons[i].name .. 'Button',
                style = 'frame_action_button',
                tooltip = { 'gui.cancel' },
                sprite = buttons[i].sprite,
                hovered_sprite = buttons[i].hovered_sprite or nil,
                clicked_sprite = buttons[i].clicked_sprite or nil
            }
        end
    end
    return titlebar_flow
end

local function buildFooter( parent, name, data )
    local prefix = name .. '-'

    local footer_flow = parent.add {
        type = 'flow',
        name = prefix .. 'flow',
        style = 'slot_table_spacing_horizontal_flow'
    }
    footer_flow.style.top_padding = 8
    footer_flow.style.vertically_stretchable = false

    if data.backButton then
        local buttonName = prefix ..
                               (data.backButtonName or 'footer-closeButton')
        footer_flow.add {
            type = 'button',
            name = buttonName,
            style = 'back_button',
            caption = { 'gui.cancel' }
        }
    end

    local filler = footer_flow.add {
        type = 'empty-widget',
        name = prefix .. 'filler',
        style = 'draggable_space'
    }
    filler.style.horizontally_stretchable = true
    filler.style.vertically_stretchable = true
    if data.draggable then
        filler.drag_target = parent
    end

    if data.confirmButton then
        local button = footer_flow.add {
            type = 'button',
            name = prefix .. 'confirmButton',
            style = 'confirm_button',
            caption = { 'gui.confirm' }
        }
        button.enabled = false
        global.userInterface[data.player_index].buttonReference[(prefix ..
            'confirmButton')] = button
    elseif data.discardChangesButton then
        local button = footer_flow.add {
            type = 'button',
            name = prefix .. 'discardChangesButton',
            style = 'red_confirm_button',
            caption = { 'discard-changes' }
        }
    elseif data.confirmResetButton then
        local button = footer_flow.add {
            type = 'button',
            name = prefix .. 'confirmResetButton',
            style = 'red_confirm_button',
            caption = { 'gui.reset' }
        }
    end
    return footer_flow
end

local function addTabAndPanel( gui, name, caption )
    local tabContainer = gui.tabContainer
    local tab = tabContainer.add {
        type = 'tab',
        name = 'maintenanceMadness-tab-' .. name,
        caption = caption
    }
    local content = tabContainer.add {
        type = 'flow',
        name = 'maintenanceMadness-tab-' .. name .. '-frame',
        direction = 'vertical'
    }
    content.style.left_padding = 7
    content.style.top_padding = 7
    content.style.right_padding = 3
    tabContainer.add_tab( tab, content )
    return content
end

local function getEntityCount( entityName, player_index )
    local count
    local get_entity_count = game.players[player_index].force.get_entity_count
    local entityType = game.entity_prototypes[entityName].type
    if entityType == 'solar-panel' or entityType == 'accumulator' then
        -- for entities with faulty versions, count those aswell
        count = get_entity_count( entityName ) +
                    get_entity_count( 'mm-faulty-' .. entityName )
    else
        count = get_entity_count( entityName )
    end
    return count
end

local function getSortedEntityList( player_index,
                                    maintenanceControlData )
    local forceID = game.players[player_index].force.index
    local sortedEntityList = {}
    for entityName, controlData in pairs( maintenanceControlData ) do
        sortedEntityList[#sortedEntityList + 1] = {
            name = entityName,
            count = getEntityCount( entityName, player_index )
        }
    end
    table.sort( sortedEntityList, function( a, b )
        return a.count > b.count
    end )
    return sortedEntityList
end

local function getLocalisedName( object )
    local name
    if game.entity_prototypes[object] then
        name = { 'entity-name.' .. object }
    else
        name = { 'item-name.' .. object }
    end
    return name
end

local function format_percentage( input, precision )
    return mmUtil.round( input, precision ) * 100 .. '%'
end

local function createNoMachinesLabel( parent )
    local flow = parent.add { type = 'flow', direction = 'horizontal' }
    flow.style.vertical_align = 'center'
    flow.style.horizontal_align = 'center'
    flow.style.minimal_width = 740
    local sb = flow.add {
        type = 'sprite-button',
        sprite = 'utility/warning_white',
        style = 'transparent_slot'
    }
    flow.add {
        type = 'label',
        style = 'label_with_left_padding',
        caption = { 'gui.mm-no-machines' }
    }
end

local function populateItemPolicyTable( parent, player_index, policyType )
    if not global.userInterface[player_index].buttonReference then
        global.userInterface[player_index].buttonReference = {}
    end
    if not global.userInterface[player_index].labelReference then
        global.userInterface[player_index].labelReference = {}
    end
    if not global.userInterface[player_index].iconReference then
        global.userInterface[player_index].iconReference = {}
    end
    local buttonReference =
        global.userInterface[player_index].buttonReference or {}
    if global.temporaryMaintenanceControl and
        global.temporaryMaintenanceControl[player_index] then
        local control =
            global.temporaryMaintenanceControl[player_index]['byEntity']
        local order = getSortedEntityList( player_index, control )
        if order[1] and order[1].count == 0 then
            return false
        end
        for _, element in pairs( order ) do
            if element.count > 0 then

                local flow1 = parent.add {
                    type = 'flow',
                    direction = 'horizontal'
                }
                local sb = flow1.add {
                    type = 'sprite-button',
                    sprite = 'item/' .. element.name,
                    style = 'transparent_slot',
                    number = element.count
                }
                flow1.add {
                    type = 'label',
                    style = 'label_with_left_padding',
                    caption = { 'entity-name.' .. element.name }
                }
                flow1.style.vertical_align = 'center'
                local effectPercent = 0
                if policyType == 'maintenance' or policyType == 'repair' then
                    local itemData
                    local itemSpritePathG, itemSpritePath
                    local itemCount = mmUtil.getLength(
                                          control[element.name][policyType] )
                    local repairItemData, repairItemCount
                    if policyType == 'maintenance' then
                        itemData =
                            global.entitiesWithMROenabled[element.name][policyType][const.maintenanceLevel]
                        itemSpritePathG = 'maintenance-needed-grey-icon'
                        itemSpritePath = 'maintenance-needed-icon'
                    elseif policyType == 'repair' then
                        itemData =
                            global.entitiesWithMROenabled[element.name][policyType][const.maintenanceLevel]
                                .secondary
                        repairItemData =
                            global.entitiesWithMROenabled[element.name][policyType][const.maintenanceLevel]
                                .primary
                        repairItemCount = mmUtil.getLength( repairItemData )
                        itemSpritePathG = 'repair-in-progress-gray-icon'
                        itemSpritePath = 'repair-in-progress-icon'
                        itemCount = itemCount + repairItemCount
                    end
                    local effectLabelNameComplete =
                        'maintenanceMadness-itemPolicyEffectLabel-' ..
                            policyType .. '-' .. element.name
                    local buttonName = 'maintenanceMadness-itemPolicyButton-' ..
                                           policyType .. '-' .. element.name ..
                                           '-'

                    local flow2, flow2a, flow2b
                    local manyItems = false
                    local itemNo = 0
                    if itemCount > 5 then
                        manyItems = true
                        flow2 = parent.add {
                            type = 'flow',
                            direction = 'vertical'
                        }
                        flow2.style.vertical_spacing = 4
                        flow2a = flow2.add {
                            type = 'flow',
                            direction = 'horizontal'
                        }
                        flow2b = flow2.add {
                            type = 'flow',
                            direction = 'horizontal'
                        }
                    else
                        flow2 = parent.add {
                            type = 'flow',
                            direction = 'horizontal'
                        }
                    end
                    if policyType == 'repair' then
                        for repairItemName, _ in pairs( repairItemData ) do
                            local buttonNameComplete = buttonName ..
                                                           repairItemName
                            local repairItemButton
                            itemNo = itemNo + 1

                            if manyItems then
                                if itemNo % 2 == 1 then
                                    repairItemButton = flow2a.add {
                                        type = 'sprite-button',
                                        name = buttonNameComplete,
                                        sprite = 'item/' .. repairItemName,
                                        ignored_by_interaction = true,
                                        style = 'blue_slot',
                                        tooltip = getLocalisedName(
                                            repairItemName )
                                    }
                                else
                                    repairItemButton = flow2b.add {
                                        type = 'sprite-button',
                                        name = buttonNameComplete,
                                        sprite = 'item/' .. repairItemName,
                                        ignored_by_interaction = true,
                                        style = 'blue_slot',
                                        tooltip = getLocalisedName(
                                            repairItemName )
                                    }
                                end
                            else
                                repairItemButton = flow2.add {
                                    type = 'sprite-button',
                                    name = buttonNameComplete,
                                    sprite = 'item/' .. repairItemName,
                                    ignored_by_interaction = true,
                                    style = 'blue_slot',
                                    tooltip = getLocalisedName( repairItemName )
                                }
                            end
                        end
                    end

                    for itemName, use in pairs(
                                             control[element.name][policyType] ) do
                        local buttonNameComplete = buttonName .. itemName
                        itemNo = itemNo + 1

                        if manyItems then
                            if itemNo % 2 == 1 then
                                if use.enabled == true then
                                    flow2a.add {
                                        type = 'sprite-button',
                                        name = buttonNameComplete,
                                        sprite = 'item/' .. itemName,
                                        style = 'green_slot',
                                        tooltip = getLocalisedName( itemName )
                                    }
                                    effectPercent = effectPercent +
                                                        itemData[itemName]
                                                            .expectedEffect
                                else
                                    flow2a.add {
                                        type = 'sprite-button',
                                        name = buttonNameComplete,
                                        sprite = 'item/' .. itemName,
                                        style = 'red_slot',
                                        tooltip = getLocalisedName( itemName )
                                    }
                                end
                            else
                                if use.enabled == true then
                                    flow2b.add {
                                        type = 'sprite-button',
                                        name = buttonNameComplete,
                                        sprite = 'item/' .. itemName,
                                        style = 'green_slot',
                                        tooltip = getLocalisedName( itemName )
                                    }
                                    effectPercent = effectPercent +
                                                        itemData[itemName]
                                                            .expectedEffect
                                else
                                    flow2b.add {
                                        type = 'sprite-button',
                                        name = buttonNameComplete,
                                        sprite = 'item/' .. itemName,
                                        style = 'red_slot',
                                        tooltip = getLocalisedName( itemName )
                                    }
                                end
                            end
                        else
                            if use.enabled == true then
                                flow2.add {
                                    type = 'sprite-button',
                                    name = buttonNameComplete,
                                    sprite = 'item/' .. itemName,
                                    style = 'green_slot',
                                    tooltip = getLocalisedName( itemName )
                                }
                                effectPercent = effectPercent +
                                                    itemData[itemName]
                                                        .expectedEffect
                            else
                                flow2.add {
                                    type = 'sprite-button',
                                    name = buttonNameComplete,
                                    sprite = 'item/' .. itemName,
                                    style = 'red_slot',
                                    tooltip = getLocalisedName( itemName )
                                }
                            end
                        end
                        global.userInterface[player_index].buttonReference[buttonNameComplete] =
                            {
                                policyType = policyType,
                                entity = element.name,
                                item = itemName,
                                effectLabelName = effectLabelNameComplete
                            }
                    end
                    if manyItems and itemNo % 2 == 1 then
                        local fillerButton = flow2b.add {
                            type = 'sprite-button',
                            style = 'transparent_slot'
                        }
                        fillerButton.style.width = 36
                        fillerButton.style.height = 36
                    end
                    local spritePath
                    if (mceil( 100000 * effectPercent ) / 100000) < 1 then
                        spritePath = itemSpritePath
                    else
                        spritePath = itemSpritePathG
                    end
                    local flow3 = parent.add {
                        type = 'flow',
                        direction = 'horizontal'
                    }
                    flow3.style.vertical_align = 'center'
                    local effectIcon = flow3.add {
                        type = 'sprite-button',
                        name = effectLabelNameComplete .. '-icon',
                        sprite = spritePath,
                        style = 'transparent_slot'
                    }
                    local effectLabel = flow3.add {
                        type = 'label',
                        name = effectLabelNameComplete,
                        style = 'count_label',
                        caption = format_percentage( effectPercent, 0.001 )
                    }
                    global.userInterface[player_index].labelReference[effectLabelNameComplete] =
                        effectLabel
                    global.userInterface[player_index].iconReference[effectLabelNameComplete ..
                        '-icon'] = effectIcon

                    local warningArrow = flow3.add {
                        type = 'sprite-button',
                        sprite = 'utility/expand',
                        style = 'transparent_slot'
                    }
                    global.userInterface[player_index].iconReference[effectLabelNameComplete ..
                        '-warning-arrow'] = warningArrow
                    local warningIcon = flow3.add {
                        type = 'sprite-button',
                        style = 'transparent_slot'
                    }
                    global.userInterface[player_index].iconReference[effectLabelNameComplete ..
                        '-warning-icon'] = warningIcon
                    local warningLabel = flow3.add {
                        type = 'label',
                        name = effectLabelNameComplete .. '-warning',
                        style = 'count_label'
                    }
                    warningLabel.style.font_color = const.textColors.negative
                    global.userInterface[player_index].labelReference[effectLabelNameComplete ..
                        '-warning'] = warningLabel

                    if (mceil( 100000 * effectPercent ) / 100000) < 1 then
                        if policyType == 'maintenance' then
                            local warningPercent = 1 / (1 /
                                                       (((1 - effectPercent) *
                                                           (const.maxMissedMaintenanceMalus /
                                                               const.baseAgeing) +
                                                           1) - 1))
                            warningLabel.caption = '+' ..
                                                       format_percentage(
                                                           warningPercent, 0.01 )
                            warningIcon.sprite =
                                'item/mm-scrapped-' .. element.name -- "machine-malfunction-icon"
                        elseif policyType == 'repair' then
                            local warningPercent =
                                (1 - effectPercent) /
                                    (1 / ((1 / const.baseRepairEffectivity) - 1))
                            warningLabel.caption = '+' ..
                                                       format_percentage(
                                                           warningPercent, 0.01 )
                            warningIcon.sprite = 'utility/clock'
                        end
                    else
                        warningArrow.sprite = 'utility/check_mark_white'
                        warningIcon.visible = false
                        warningLabel.visible = false
                    end

                end
            end
        end
        return true
    else
        return false
    end
end

local function replacementAgeGetSliderValue( sliderValue )
    -- translate the slider value into the replacement age value
    if sliderValue <= 15 then
        return sliderValue * 10
    elseif sliderValue <= 17 then
        return (sliderValue - 15) * 25 + 150
    elseif sliderValue <= 19 then
        return (sliderValue - 17) * 50 + 200
    elseif sliderValue == 20 then
        return 0
    end
end

local function replacementAgeSetSliderValue( value )
    -- translate the replacement age value into the slider value
    if value == 0 then
        return 20
    elseif value <= 150 then
        return mmUtil.round( value, 10 ) / 10
    elseif value <= 200 then
        return mmUtil.round( (value - 150), 25 ) / 25 + 15
    elseif value <= 300 then
        return mmUtil.round( (value - 200), 50 ) / 50 + 17
    end
end

local function calculateFailureRate( machineAge )
    if machineAge > 0 then
        local avgMachineAge = machineAge / 2
        local failureProb = const.repairProbabilityModifier *
                                (avgMachineAge / const.maxAge)
        local failureTime = const.MTTR +
                                ((avgMachineAge / const.maxAge) *
                                    const.repairTimeModifier * const.MTTR)
        local defaultCycleTime = const.MTBM + (1 - failureProb) * const.MTTM +
                                     failureProb * failureTime
        local machineFailureRate = failureProb * failureTime / defaultCycleTime
        return machineFailureRate
    else
        return 'max'
    end
end

local function populateReplacementPolicyTable( parent, player_index )
    local policyType = 'replacement'
    if not global.userInterface[player_index].buttonReference then
        global.userInterface[player_index].buttonReference = {}
    end
    if not global.userInterface[player_index].labelReference then
        global.userInterface[player_index].labelReference = {}
    end
    if not global.userInterface[player_index].iconReference then
        global.userInterface[player_index].iconReference = {}
    end
    local buttonReference =
        global.userInterface[player_index].buttonReference or {}
    if global.temporaryMaintenanceControl and
        global.temporaryMaintenanceControl[player_index] then
        local control =
            global.temporaryMaintenanceControl[player_index]['byEntity']
        local order = getSortedEntityList( player_index, control )
        if order[1] and order[1].count == 0 then
            return false
        end
        for _, element in pairs( order ) do
            if element.count > 0 then
                local sliderNameComplete =
                    'maintenanceMadness-replacmentPolicySlider-' .. element.name
                local forcedSliderNameComplete =
                    'maintenanceMadness-forcedReplacmentPolicySlider-' ..
                        element.name
                local effectLabelNameComplete =
                    'maintenanceMadness-replacementPolicyEffectLabel-' ..
                        element.name
                local valueStart = control[element.name].replacement.start
                local valueLimit = control[element.name].replacement.limit
                local effectLabelCaption = ''
                if valueStart < valueLimit then
                    effectLabelCaption =
                        format_percentage( valueStart / 100, 0.01 ) .. ' … ' ..
                            format_percentage( valueLimit / 100, 0.01 )
                elseif valueStart == valueLimit then
                    effectLabelCaption = '= ' ..
                                             format_percentage(
                                                 valueStart / 100, 0.01 )
                elseif (valueStart > 0) and (valueLimit == 0) then
                    effectLabelCaption =
                        format_percentage( valueStart / 100, 0.01 ) .. ' +'
                end

                local flow1 = parent.add {
                    type = 'flow',
                    direction = 'horizontal'
                }
                local sb = flow1.add {
                    type = 'sprite-button',
                    sprite = 'item/' .. element.name,
                    style = 'transparent_slot',
                    number = element.count
                }
                flow1.add {
                    type = 'label',
                    style = 'label_with_left_padding',
                    caption = { 'entity-name.' .. element.name }
                }
                flow1.style.vertical_align = 'center'
                -- local effectPercent = 0
                local flow2 =
                    parent.add { type = 'flow', direction = 'vertical' }
                -- flow2.style.vertical_align = "center"
                flow2.style.horizontal_align = 'right'
                flow2.style.minimal_height = 36
                local slider1 = flow2.add {
                    type = 'slider',
                    name = sliderNameComplete,
                    style = 'notched_slider',
                    minimum_value = 1,
                    maximum_value = 20,
                    value = replacementAgeSetSliderValue(
                        control[element.name].replacement.start ),
                    value_step = 1,
                    discrete_slider = true,
                    discrete_values = true
                }
                global.userInterface[player_index].buttonReference[sliderNameComplete] =
                    {
                        element = slider1,
                        policyType = policyType,
                        entity = element.name,
                        effectLabelName = effectLabelNameComplete,
                        sibling = forcedSliderNameComplete
                    }
                slider1.style.horizontally_stretchable = true
                slider1.style.left_margin = 10
                slider1.style.right_margin = 10
                slider1.style.top_margin = 6
                local slider2 = flow2.add {
                    type = 'slider',
                    name = forcedSliderNameComplete,
                    style = 'notched_slider',
                    minimum_value = 1,
                    maximum_value = 20,
                    value = replacementAgeSetSliderValue(
                        control[element.name].replacement.limit ),
                    value_step = 1,
                    discrete_slider = true,
                    discrete_values = true
                }
                global.userInterface[player_index].buttonReference[forcedSliderNameComplete] =
                    {
                        element = slider2,
                        policyType = policyType,
                        entity = element.name,
                        effectLabelName = effectLabelNameComplete,
                        sibling = sliderNameComplete
                    }
                slider2.style.horizontally_stretchable = true
                slider2.style.left_margin = 10
                slider2.style.right_margin = 10
                slider2.style.top_margin = 6
                -- local tb1 = flow2.add{type="text-box", name = effectLabelNameComplete.."-textbox", text = slider1.slider_value, style = "slider_value_textfield"}
                -- tb1.style.width = 60
                -- tb1.style.natural_width = 60
                -- local flow2b = flow2v.add{type="flow", direction="horizontal"}
                -- local cb1 = flow2b.add{type="checkbox", state = true, caption = "Max operating age"}
                -- local tb2 = flow2b.add{type="text-box", text = slider1.slider_value*2, style = "slider_value_textfield"}
                -- tb2.style.width = 60
                -- tb1.style.natural_width = 60

                local flow3 = parent.add {
                    type = 'flow',
                    direction = 'horizontal'
                }
                flow3.style.vertical_align = 'center'
                local flow3a =
                    flow3.add { type = 'flow', direction = 'vertical' }
                flow3a.style.vertical_align = 'center'
                flow3a.style.horizontal_align = 'center'
                local flow3aa = flow3a.add {
                    type = 'flow',
                    direction = 'horizontal'
                }
                flow3aa.style.vertical_align = 'center'
                flow3aa.style.horizontal_align = 'center'
                local flow3ab = flow3a.add {
                    type = 'flow',
                    direction = 'horizontal'
                }
                flow3ab.style.vertical_align = 'center'
                flow3ab.style.horizontal_align = 'center'
                local noReplacementLabel = flow3aa.add {
                    type = 'label',
                    name = effectLabelNameComplete .. '-no-replacement',
                    style = 'bold_label',
                    caption = { 'gui.mm-no-replacement' }
                }
                noReplacementLabel.visible = false
                global.userInterface[player_index].labelReference[effectLabelNameComplete ..
                    '-no-replacement'] = noReplacementLabel
                local effectIcon = flow3aa.add {
                    type = 'sprite-button',
                    name = effectLabelNameComplete .. '-icon',
                    sprite = 'replacement-request-icon',
                    style = 'transparent_slot'
                }
                local effectLabel = flow3ab.add {
                    type = 'label',
                    name = effectLabelNameComplete,
                    style = 'count_label',
                    caption = effectLabelCaption
                }
                global.userInterface[player_index].labelReference[effectLabelNameComplete] =
                    effectLabel

                --[[local effectLabelMid = flow3ab.add{type="label", name = effectLabelNameComplete, style = "count_label", caption = format_percentage(control[element.name].replacement.start/100, 0.001)}
                global.userInterface[player_index].labelReference[effectLabelNameComplete] = effectLabelStart
                local effectLabelLimit = flow3ab.add{type="label", name = effectLabelNameComplete, style = "count_label", caption = format_percentage(control[element.name].replacement.start/100, 0.001)}
                global.userInterface[player_index].labelReference[effectLabelNameComplete] = effectLabelStart]]
                -- global.userInterface[player_index].iconReference[effectLabelNameComplete.."-icon"] = effectIcon

                local warningArrow = flow3.add {
                    type = 'sprite-button',
                    sprite = 'utility/expand',
                    style = 'transparent_slot'
                }
                global.userInterface[player_index].iconReference[effectLabelNameComplete ..
                    '-warning-arrow'] = warningArrow
                local flow3b =
                    flow3.add { type = 'flow', direction = 'vertical' }
                local flow3c =
                    flow3.add { type = 'flow', direction = 'vertical' }

                local warningIcon_1 = flow3b.add {
                    type = 'sprite-button',
                    style = 'transparent_slot'
                }
                global.userInterface[player_index].iconReference[effectLabelNameComplete ..
                    '-warning-icon-1'] = warningIcon_1
                local warningIcon_2 = flow3b.add {
                    type = 'sprite-button',
                    style = 'transparent_slot'
                }
                global.userInterface[player_index].iconReference[effectLabelNameComplete ..
                    '-warning-icon-2'] = warningIcon_2
                local warningLabel_1 = flow3c.add {
                    type = 'label',
                    name = effectLabelNameComplete .. '-warning-1',
                    style = 'count_label'
                }
                warningLabel_1.style.height = 36
                warningLabel_1.style.vertical_align = 'center'
                global.userInterface[player_index].labelReference[effectLabelNameComplete ..
                    '-warning-1'] = warningLabel_1
                local warningLabel_2 = flow3c.add {
                    type = 'label',
                    name = effectLabelNameComplete .. '-warning-2',
                    style = 'count_label'
                }
                warningLabel_2.style.height = 36
                warningLabel_2.style.vertical_align = 'center'
                global.userInterface[player_index].labelReference[effectLabelNameComplete ..
                    '-warning-2'] = warningLabel_2
                local warningIcon_3 = flow3.add {
                    type = 'sprite-button',
                    style = 'transparent_slot',
                    tooltip = { 'gui.mm-tooltip-warning-operation-age' }
                }
                global.userInterface[player_index].iconReference[effectLabelNameComplete ..
                    '-warning-icon-3'] = warningIcon_3
                warningIcon_1.sprite = 'item/mm-scrapped-' .. element.name
                warningIcon_2.sprite = 'machine-malfunction-icon'
                warningIcon_3.sprite = 'warning-icon'

                local machineFailureRate
                local machineReplacementCost

                if control[element.name].replacement.start > 0 then
                    local machineFailureRateIndex =
                        calculateFailureRate( const.replacementAge ) -- falure rate at default replacement value
                    local thisMachineFailureRate =
                        calculateFailureRate(
                            control[element.name].replacement.start )
                    machineFailureRate =
                        (thisMachineFailureRate / machineFailureRateIndex) - 1

                    local machineReplacementCostIndex = 1 /
                                                            (const.replacementAge /
                                                                const.maxAge)
                    local thisMachineReplacementCost = 1 /
                                                           (control[element.name]
                                                               .replacement
                                                               .start /
                                                               const.maxAge)
                    machineReplacementCost =
                        (thisMachineReplacementCost /
                            machineReplacementCostIndex) - 1
                else
                    machineFailureRate = { 'gui.mm-no-replacement-max-failure' }
                    machineReplacementCost = -1

                    slider1.style = 'maintenanceMadness_red_notched_slider'
                    noReplacementLabel.visible = true
                    effectLabel.visible = false
                    warningIcon_3.sprite = 'danger-icon'
                    warningIcon_3.tooltip = {
                        'gui.mm-tooltip-danger-operation-age'
                    }
                end
                if control[element.name].replacement.limit == 0 then
                    slider2.style = 'maintenanceMadness_red_notched_slider'
                end

                if control[element.name].replacement.start == 0 or
                    control[element.name].replacement.start > 100 then
                    warningIcon_3.visible = true
                else
                    warningIcon_3.visible = false
                end
                if control[element.name].replacement.start ~=
                    const.replacementAge then
                    if machineReplacementCost > 0 then
                        warningLabel_1.caption = '+'
                        warningLabel_1.style.font_color = const.textColors
                                                              .negative
                    else
                        warningLabel_1.caption = ''
                        warningLabel_1.style.font_color = const.textColors
                                                              .positive
                    end
                    warningLabel_1.caption =
                        warningLabel_1.caption ..
                            format_percentage( machineReplacementCost, 0.01 )
                    if tonumber( machineFailureRate ) ~= nil then
                        if machineFailureRate > 0 then
                            warningLabel_2.caption = '+'
                            warningLabel_2.style.font_color = const.textColors
                                                                  .negative
                        else
                            warningLabel_2.caption = ''
                            warningLabel_2.style.font_color = const.textColors
                                                                  .positive
                        end
                        warningLabel_2.caption =
                            warningLabel_2.caption ..
                                format_percentage( machineFailureRate, 0.01 )
                    else
                        warningLabel_2.caption = machineFailureRate
                        warningLabel_2.style.font_color = const.textColors
                                                              .negative
                    end

                else
                    warningArrow.visible = false
                    -- flow3a.style.maximal_height = 36
                    -- flow3b.style.maximal_height = 36
                    warningLabel_1.visible = false
                    warningLabel_2.visible = false
                    warningIcon_1.visible = false
                    warningIcon_2.visible = false
                end
            end
        end
        return true
    else
        return false
    end
end

function resetToDefault( player_index )
    local ui = global.userInterface[player_index]
    local forceID = game.players[player_index].force.index
    for _, entity in pairs( global.maintenanceControl[forceID].byEntity ) do
        for _, item in pairs( entity.maintenance ) do
            if item.enabled == false then
                item.enabled = true
            end
        end
        for _, item in pairs( entity.repair ) do
            if item.enabled == false then
                item.enabled = true
            end
        end
        if entity.replacement.start ~= const.replacementAge then
            entity.replacement.start = const.replacementAge
        end
        if entity.replacement.limit ~= const.maxOperationAge then
            entity.replacement.limit = const.maxOperationAge
        end
    end
end

function discardChangedMaintenanceControlSettings( player_index )
    global.changedControlSettings[player_index] = nil
    global.changedControlSettings[player_index] = {}
    global.changedControlSettings[player_index].total = 0
end

function confirmNewMaintenanceControlSettings( player_index, reset )
    local forceID = game.players[player_index].force.index
    local changedControls = global.changedControlSettings[player_index]
    local updatedControls = global.maintenanceControl[forceID]

    if reset then
        resetToDefault( player_index )
    else
        if changedControls.byEntity then
            for entityName, controls in pairs( changedControls.byEntity ) do
                if controls.maintenance then
                    for itemName, setting in pairs( controls.maintenance ) do
                        updatedControls.byEntity[entityName].maintenance[itemName]
                            .enabled = setting.enabled
                    end
                end
                if controls.repair then
                    for itemName, setting in pairs( controls.repair ) do
                        updatedControls.byEntity[entityName].repair[itemName]
                            .enabled = setting.enabled
                    end
                end
                if controls.replacement then
                    for setting, value in pairs( controls.replacement ) do
                        updatedControls.byEntity[entityName].replacement[setting] =
                            value
                    end
                end
            end
        end
    end
    discardChangedMaintenanceControlSettings( player_index )
    if game.is_multiplayer() then
        game.forces[forceID].print( {
            'mm-notification-maintenance-settings-changed-MP',
            game.players[player_index].name
        } )
    end
end

function countChangedSettings( forceID )
    local numOptions = 0
    if global.maintenanceControl[forceID] and
        global.maintenanceControl[forceID].byEntity then
        for _, entity in pairs( global.maintenanceControl[forceID].byEntity ) do
            for _, item in pairs( entity.maintenance ) do
                if item.enabled == false then
                    numOptions = numOptions + 1
                end
            end
            for _, item in pairs( entity.repair ) do
                if item.enabled == false then
                    numOptions = numOptions + 1
                end
            end
            if entity.replacement.start ~= const.replacementAge then
                numOptions = numOptions + 1
            end
            if entity.replacement.limit ~= const.maxOperationAge then
                numOptions = numOptions + 1
            end
        end
    end
    return numOptions
end

function toggleConfirmResetDialog( player_index )
    local ui = global.userInterface[player_index]
    local forceID = game.players[player_index].force.index
    local numOptions = global.maintenanceControl[forceID].numOptions

    if ui.root.gui2 ~= nil then
        ui.root.gui2.destroy()
        ui.root.gui2 = nil
        ui.root.gui.ignored_by_interaction = false
        return
    end

    local player = game.players[player_index]
    local root = ui.root
    root.gui2 = player.gui.screen.add {
        type = 'frame',
        name = 'maintenanceMadness-notification-window',
        direction = 'vertical'
    }
    local gui2 = root.gui2

    buildTitlebar( gui2, 'maintenanceMadness-confirmationDialog', {
        label = 'gui.confirmation',
        draggable = true,
        buttons = {
            {
                name = 'close',
                sprite = 'utility/close_white',
                hovered_sprite = 'utility/close_black',
                clicked_sprite = 'utility/close_black'
            }
        }
    } )
    local flow1 = gui2.add { type = 'flow', direction = 'vertical' }
    flow1.style.vertically_stretchable = true
    flow1.style.vertical_align = 'center'
    flow1.add {
        type = 'label',
        style = 'label_with_left_padding',
        caption = { 'reset-to-defaults', numOptions }
    }
    gui2.style.minimal_height = 125
    gui2.style.minimal_width = 350
    buildFooter( gui2, 'maintenanceMadness-window-footer', {
        backButton = true,
        backButtonName = 'quitResetConfirmationDialog',
        confirmResetButton = true,
        draggable = true,
        player_index = player_index
    } )

    gui2.force_auto_center()
    root.gui.ignored_by_interaction = true
end

function toggleConfirmationDialog( player_index )
    local ui = global.userInterface[player_index]
    local player = game.players[player_index]

    if ui.root.gui2 ~= nil then
        ui.root.gui2.destroy()
        ui.root.gui2 = nil
        ui.root.gui.ignored_by_interaction = false
        player.opened = ui.root.gui -- set gui focus back to main element
        return
    end

    local root = ui.root
    root.gui2 = player.gui.screen.add {
        type = 'frame',
        name = 'maintenanceMadness-notification-window',
        direction = 'vertical'
    }
    local gui2 = root.gui2

    buildTitlebar( gui2, 'maintenanceMadness-confirmationDialog', {
        label = 'gui.confirmation',
        draggable = true,
        buttons = {
            {
                name = 'close',
                sprite = 'utility/close_white',
                hovered_sprite = 'utility/close_black',
                clicked_sprite = 'utility/close_black'
            }
        }
    } )
    local flow1 = gui2.add { type = 'flow', direction = 'vertical' }
    flow1.style.vertically_stretchable = true
    flow1.style.vertical_align = 'center'
    flow1.add {
        type = 'label',
        style = 'label_with_left_padding',
        caption = {
            'unconfirmed-changes',
            global.changedControlSettings[player_index].total
        }
    }
    gui2.style.minimal_height = 125
    gui2.style.minimal_width = 350
    buildFooter( gui2, 'maintenanceMadness-window-footer', {
        backButton = true,
        backButtonName = 'quitConfirmationDialog',
        discardChangesButton = true,
        draggable = true,
        player_index = player_index
    } )

    gui2.force_auto_center()
    root.gui.ignored_by_interaction = true
end

function updateLegendInformation( player_index, tab_index, hide )
    local ui = global.userInterface[player_index]
    local legend = ui.root.legend
    if hide then
        legend.contentFlow1.visible = false
        legend.contentFlow2.visible = false
        legend.showLegendButton.sprite = 'utility/expand_dark'
        legend.showLegendLabel.caption = { 'gui.mm-legend-show' }
    else
        legend.contentFlow1.visible = true
        legend.contentFlow2.visible = true
        legend.showLegendButton.sprite = 'utility/collapse_dark'
        legend.showLegendLabel.caption = { 'gui.mm-legend-hide' }
    end
    if tab_index == 1 then
        information = 'maintenance'
    elseif tab_index == 2 then
        information = 'repair'
    elseif tab_index == 3 then
        information = 'replacement'
    end
    local interactionLegendCaption = {}
    local legendCaptions = {}
    local shortInfoCaptions = {}
    interactionLegendCaption.maintenance = {
        ['red'] = { 'gui.mm-legend-maintenance-red-button' },
        ['green'] = { 'gui.mm-legend-maintenance-green-button' }
    }
    interactionLegendCaption.repair = {
        ['red'] = { 'gui.mm-legend-repair-red-button' },
        ['green'] = { 'gui.mm-legend-repair-green-button' },
        ['blue'] = { 'gui.mm-legend-repair-blue-button' }
    }
    interactionLegendCaption.replacement = {}
    shortInfoCaptions.maintenance = { 'gui.mm-legend-maintenance-header' }
    shortInfoCaptions.repair = { 'gui.mm-legend-repair-header' }
    shortInfoCaptions.replacement = { 'gui.mm-legend-replacement-header' }
    legendCaptions.maintenance = {
        {
            'gui.mm-legend-maintenance-detail1',
            '[img=maintenance-needed-grey-icon] '
        },
        { 'gui.mm-legend-maintenance-detail2', '[img=maintenance-needed-icon] ' },
        {
            'gui.mm-legend-maintenance-detail3',
            '[item=mm-scrapped-assembling-machine-1] '
        }
    }
    legendCaptions.repair = {
        { 'gui.mm-legend-repair-detail1', '[img=repair-in-progress-gray-icon] ' },
        { 'gui.mm-legend-repair-detail2', '[img=repair-in-progress-icon] ' },
        { 'gui.mm-legend-repair-detail3', '[img=utility/clock] ' }
    }
    legendCaptions.replacement = {
        { 'gui.mm-legend-replacement-detail1', '[img=replacement-request-icon] ' },
        {
            'gui.mm-legend-replacement-detail2',
            '[item=mm-scrapped-assembling-machine-1] '
        },
        { 'gui.mm-legend-replacement-detail3', '[img=machine-malfunction-icon] ' },
        { 'gui.mm-legend-replacement-detail4', '[img=warning-icon] ' }
    }
    legend.informationLabel.caption = shortInfoCaptions[information]
    if interactionLegendCaption[information]['blue'] then
        legend.icon1.visible = true
        legend.label1.visible = true
        legend.label1.caption = interactionLegendCaption[information]['blue']
    else
        legend.icon1.visible = false
        legend.label1.visible = false
    end
    if interactionLegendCaption[information]['green'] then
        legend.icon2.visible = true
        legend.label2.visible = true
        legend.label2.caption = interactionLegendCaption[information]['green']
    else
        legend.icon2.visible = false
        legend.label2.visible = false
    end
    if interactionLegendCaption[information]['red'] then
        legend.icon3.visible = true
        legend.label3.visible = true
        legend.label3.caption = interactionLegendCaption[information]['red']
    else
        legend.icon3.visible = false
        legend.label3.visible = false
    end
    if legendCaptions[information][4] then
        legend.label4.caption = legendCaptions[information][4]
        legend.label4.visible = true
    else
        legend.label4.visible = false
    end
    legend.label5.caption = legendCaptions[information][1]
    legend.label6.caption = legendCaptions[information][2]
    legend.label7.caption = legendCaptions[information][3]
end

function toggleLegend( player_index )
    local ui = global.userInterface[player_index]
    ui.hideLegend = not ui.hideLegend
    updateLegendInformation( player_index, ui.selectedTab, ui.hideLegend )
end

function mmGUI.toggleMasterPanel( player_index, update )

    if global.userInterface == nil then
        global.userInterface = {}
    end
    local ui = global.userInterface[player_index] or {}

    if ui and ui.root then
        if update and global.changedControlSettings[player_index].total > 0 then
            return -- no update while settings are being changed
        end
        local screenLocation = ui.root.gui.location
        ui.screenLocation = screenLocation
        ui.root.gui.destroy()
        if ui.root.gui2 then
            ui.root.gui2.destroy()
        end
        ui.root = nil
        if not update then
            global.userInterface[player_index] = ui
            global.temporaryMaintenanceControl[player_index] = nil
            return
        end
    end
    if ui.hideLegend == nil then
        ui.hideLegend = true
    end
    local player = game.players[player_index]
    local forceID = game.players[player_index].force.index
    global.temporaryMaintenanceControl[player_index] =
        global.temporaryMaintenanceControl[player_index] or
            global.maintenanceControl[forceID]
    -- if not already done, create a temporary instance of the maintenance settings of the player's force
    global.changedControlSettings[player_index] = {}
    global.changedControlSettings[player_index].total = 0
    if not global.maintenanceControl[forceID] then
        global.maintenanceControl[forceID] = {}
        global.maintenanceControl[forceID].byItem = {}
        global.maintenanceControl[forceID].byEntity = {}
    end
    global.maintenanceControl[forceID].numOptions =
        countChangedSettings( forceID )

    ui.root = {}
    ui.root.gui = player.gui.screen.add {
        type = 'frame',
        name = 'maintenanceMadness-window',
        direction = 'vertical',
        style = 'frame'
    }

    local root = ui.root
    local gui = root.gui
    player.opened = gui
    if ui.screenLocation then
        gui.location = ui.screenLocation
    else
        gui.force_auto_center()
    end
    root.tabpanes = root.tabpanes or {}
    global.userInterface[player_index] = ui

    buildTitlebar( gui, 'maintenanceMadness-window-title', {
        label = 'gui.mm-window-title',
        draggable = true,
        buttons = {
            {
                name = 'close',
                sprite = 'utility/close_white',
                hovered_sprite = 'utility/close_black',
                clicked_sprite = 'utility/close_black'
            }
        }
    } )

    local container = gui.add {
        type = 'frame',
        name = 'maintenanceMadness-window-container',
        direction = 'vertical',
        style = 'inside_deep_frame'
    }
    container.style.horizontally_stretchable = true
    container.style.maximal_height = (player.display_resolution.height -
                                         (240 * player.display_scale)) /
                                         player.display_scale

    local subheader = container.add {
        type = 'frame',
        name = 'maintenanceMadness-window-subheader-frame',
        direction = 'horizontal',
        style = 'subheader_frame'
    }
    subheader.style.horizontally_stretchable = true
    local subheaderFlow = subheader.add {
        type = 'flow',
        direction = 'horizontal'
    }

    subheaderFlow.style.horizontal_align = 'right'
    subheaderFlow.style.horizontally_stretchable = true

    -- WIP local searchButton = subheaderFlow.add{type="sprite-button", sprite = "utility/search_icon", style = "tool_button"}
    -- WIP local settingsButton = subheaderFlow.add{type="sprite-button", sprite = "utility/preset", style = "tool_button"}
    -- WIP local toggleSortLogicButton = subheaderFlow.add{type="sprite-button", sprite = "utility/shuffle", style = "tool_button"}
    -- WIP local helpButton = subheaderFlow.add{type="sprite-button", sprite = "utility/questionmark", style = "tool_button"}
    local resetButton = subheaderFlow.add {
        type = 'sprite-button',
        name = 'maintenanceMadness-resetButton',
        sprite = 'utility/reset',
        style = 'tool_button_red'
    }
    if global.maintenanceControl[forceID].numOptions > 0 then
        resetButton.tooltip = {
            'reset-to-defaults',
            global.maintenanceControl[forceID].numOptions
        }
    else
        resetButton.tooltip = { 'reset-to-defaults-disabled' }
        resetButton.enabled = false
    end
    if const.lowTechModifierEnabled then
        local lowTechBarFrame = container.add {
            type = 'flow',
            direction = 'horizontal'
        }
        lowTechBarFrame.style.left_margin = 13
        lowTechBarFrame.style.right_margin = 10
        lowTechBarFrame.style.top_margin = 6
        local tooltip = {
            'gui.mm-window-tab-statusbar-lowtech-bonus-tooltip',
            { 'gui.mm-window-tab-statusbar-lowtech-bonus-tooltip-description' },
            {
                'gui.mm-window-tab-statusbar-lowtech-bonus-tooltip-1',
                { 'technology-name.' .. const.lowTechModifierTarget }
            },
            {
                'gui.mm-window-tab-statusbar-lowtech-bonus-tooltip-2',
                mmUtil.getLength( global.lowTechModifier[forceID].techs )
            },
            {
                'gui.mm-window-tab-statusbar-lowtech-bonus-tooltip-3',
                global.lowTechModifier[forceID].researchedUnits,
                global.lowTechModifier[forceID].totalUnits
            }
        }
        local lowTechBarLabel = lowTechBarFrame.add {
            type = 'label',
            style = 'description_property_name_label',
            caption = { 'gui.mm-window-tab-statusbar-lowtech-bonus' },
            tooltip = tooltip
        }
        local lowTechBarBar = lowTechBarFrame.add {
            type = 'progressbar',
            value = global.lowTechModifier[forceID].factor,
            tooltip = tooltip
        }
        lowTechBarBar.style.horizontally_stretchable = true
        lowTechBarBar.style.left_margin = 10
        lowTechBarBar.style.right_margin = 10
        lowTechBarBar.style.top_margin = 6
        local lowTechBarPercentage = lowTechBarFrame.add {
            type = 'label',
            caption = format_percentage( global.lowTechModifier[forceID].factor,
                                         0.001 ),
            tooltip = tooltip
        }
    end
    root.tabContainer = container.add {
        type = 'tabbed-pane',
        name = 'maintenanceMadness-tabContainer'
    }
    root.tabContainer.style.top_padding = 12

    for name, data in pairs( {
        ['maintenance'] = {
            caption = { 'gui.mm-window-tab-title-maintenance' },
            column_count = 3
        },
        ['repair'] = {
            caption = { 'gui.mm-window-tab-title-repair' },
            column_count = 3
        },
        ['overhaul'] = {
            caption = { 'gui.mm-window-tab-title-overhaul' },
            column_count = 3
        }
        -- ["statistics"] = {caption="Statistics", column_count=3},
    } ) do
        root.tabpanes[name] = addTabAndPanel( root, name, data.caption )
        local tableHeaderFrame = root.tabpanes[name].add {
            type = 'frame',
            direction = 'horizontal',
            style = 'subpanel_frame'
        }
        tableHeaderFrame.style.left_margin = 1

        local tableHeader = tableHeaderFrame.add {
            type = 'table',
            column_count = data.column_count,
            style = 'maintenanceMadness_item_header_table'
        }
        tableHeader.style.horizontally_stretchable = true

        local scrollpane = root.tabpanes[name].add {
            type = 'scroll-pane',
            style = 'tab_scroll_pane',
            vertical_scroll_policy = 'always',
            horizontal_scroll_policy = 'auto'
        }
        scrollpane.style.horizontally_stretchable = true
        scrollpane.style.width = 763
        scrollpane.style.left_margin = -6
        scrollpane.style.right_margin = 0

        local table = scrollpane.add {
            type = 'table',
            column_count = data.column_count,
            style = 'maintenanceMadness_item_table'
        }

        if name == 'maintenance' then
            tableHeader.add {
                type = 'label',
                style = 'orange_label',
                caption = { 'gui.mm-window-tab-maintenance-header-name' }
            }
            tableHeader.add {
                type = 'label',
                style = 'orange_label',
                caption = { 'gui.mm-window-tab-maintenance-header-setting' }
            }
            tableHeader.add {
                type = 'label',
                style = 'orange_label',
                caption = { 'gui.mm-window-tab-maintenance-header-effect' }
            }
            if not populateItemPolicyTable( table, player_index, 'maintenance' ) then
                table.destroy()
                createNoMachinesLabel( scrollpane )
            end
        end

        if name == 'repair' then
            tableHeader.add {
                type = 'label',
                style = 'orange_label',
                caption = { 'gui.mm-window-tab-repair-header-name' }
            }
            tableHeader.add {
                type = 'label',
                style = 'orange_label',
                caption = { 'gui.mm-window-tab-repair-header-setting' }
            }
            tableHeader.add {
                type = 'label',
                style = 'orange_label',
                caption = { 'gui.mm-window-tab-repair-header-effect' }
            }
            if not populateItemPolicyTable( table, player_index, 'repair' ) then
                table.destroy()
                createNoMachinesLabel( scrollpane )
            end
        elseif name == 'overhaul' then
            tableHeader.add {
                type = 'label',
                style = 'orange_label',
                caption = { 'gui.mm-window-tab-overhaul-header-name' }
            }
            tableHeader.add {
                type = 'label',
                style = 'orange_label',
                caption = { 'gui.mm-window-tab-overhaul-header-setting' }
            }
            tableHeader.add {
                type = 'label',
                style = 'orange_label',
                caption = { 'gui.mm-window-tab-overhaul-header-effect' }
            }
            if not populateReplacementPolicyTable( table, player_index ) then
                table.destroy()
                createNoMachinesLabel( scrollpane )
            end

        elseif name == 'statistics' then
            --[[
            for name, type in pairs(game.styles) do
                if type == "frame_style" then
                    local flow = table.add{type="flow", direction="vertical"}
                    flow.add{type="text-box", style="info_box_textbox", text=name}
                    local scrp = flow.add{type="frame", style=name}
                    scrp.style.horizontally_stretchable = true
                    scrp.style.vertically_stretchable = true
                    scrp.style.minimal_height = 64
                    scrp.style.minimal_width = 128
                    scrp.add{type="label", caption = "Label 1"}
                    scrp.add{type="label", caption = "Label 2"}
                    scrp.add{type="label", caption = "Label 3"}
                    scrp.add{type="label", caption = "Label 4"}
                end
            end
            for name, type in pairs(game.styles) do
                if type == "table_style" then
                    local flow = table.add{type="flow", direction="vertical"}
                    flow.add{type="text-box", style="info_box_textbox", text=name}
                    local scrp = flow.add{type="table", style=name, column_count = 2}
                    scrp.style.horizontally_stretchable = true
                    scrp.style.vertically_stretchable = true
                    scrp.style.minimal_height = 64
                    scrp.style.minimal_width = 128
                    scrp.add{type="label", caption = "Label 1"}
                    scrp.add{type="label", caption = "Label 2"}
                    scrp.add{type="label", caption = "Label 3"}
                    scrp.add{type="label", caption = "Label 4"}
                end
            end
            ]]
        end
    end
    local subfooter = container.add {
        type = 'frame',
        name = 'maintenanceMadness-subfooter',
        direction = 'horizontal',
        style = 'subfooter_frame'
    }
    subfooter.style.horizontally_stretchable = true
    subfooter.style.left_padding = 8
    local subfooter_flow = subfooter.add {
        type = 'flow',
        name = 'maintenanceMadness-subfooter-flow',
        direction = 'vertical'
    }
    subfooter_flow.style.minimal_height = 24
    subfooter_flow.style.top_padding = 1
    local subfooter_headerFlow = subfooter_flow.add {
        type = 'flow',
        name = 'maintenanceMadness-subfooter-headerFlow',
        direction = 'horizontal'
    }
    subfooter_headerFlow.style.horizontally_stretchable = true
    subfooter_headerFlow.style.vertical_align = 'center'
    root.legend = {}
    local legend = root.legend
    legend.informationLabel = subfooter_headerFlow.add {
        type = 'label',
        name = 'maintenanceMadness-subfooter-informationLabel',
        style = 'caption_label'
    }
    legend.informationLabel.caption =
        'Click on any item to toggle its use for maintenance or repair operations'
    legend.informationLabel.style.bottom_padding = 2
    local filler = subfooter_headerFlow.add {
        type = 'flow',
        direction = 'horizontal'
    }
    filler.style.horizontally_stretchable = true
    legend.showLegendLabel = subfooter_headerFlow.add {
        type = 'label',
        style = 'info_label'
    }
    legend.showLegendLabel.style.bottom_padding = 2
    legend.showLegendLabel.style.right_margin = 3
    legend.showLegendButton = subfooter_headerFlow.add {
        type = 'sprite-button',
        name = 'maintenanceMadness-toggleLegendButton',
        sprite = 'utility/expand_dark',
        style = 'tool_button'
    }
    legend.showLegendButton.style.padding = -2
    legend.contentFlow1 = subfooter_flow.add {
        type = 'flow',
        direction = 'horizontal'
    }
    legend.contentFlow1.style.natural_height = 24
    -- subfooter_flow.style.vertical_align = "center"

    legend.icon1 = legend.contentFlow1.add {
        type = 'sprite-button',
        style = 'blue_slot'
    }
    legend.icon1.style.width = 20
    legend.icon1.style.height = 20
    legend.icon1.style.natural_width = 20
    legend.icon1.style.natural_height = 20
    legend.label1 = legend.contentFlow1.add {
        type = 'label',
        name = 'maintenanceMadness-subfooter-legendLabel1',
        style = 'info_label'
    }
    legend.label1.style.right_margin = 14
    legend.label1.style.left_margin = 3

    legend.icon2 = legend.contentFlow1.add {
        type = 'sprite-button',
        style = 'green_slot'
    }
    legend.icon2.style.width = 20
    legend.icon2.style.height = 20
    legend.icon2.style.natural_width = 20
    legend.icon2.style.natural_height = 20
    legend.label2 = legend.contentFlow1.add {
        type = 'label',
        name = 'maintenanceMadness-subfooter-legendLabel2',
        style = 'info_label'
    }
    legend.label2.style.right_margin = 14
    legend.label2.style.left_margin = 3

    legend.icon3 = legend.contentFlow1.add {
        type = 'sprite-button',
        style = 'red_slot'
    }
    legend.icon3.style.width = 20
    legend.icon3.style.height = 20
    legend.icon3.style.natural_width = 20
    legend.icon3.style.natural_height = 20
    legend.label3 = legend.contentFlow1.add {
        type = 'label',
        name = 'maintenanceMadness-subfooter-legendLabel3',
        style = 'info_label'
    }
    legend.label3.style.right_margin = 14
    legend.label3.style.left_margin = 3
    legend.label4 = legend.contentFlow1.add {
        type = 'label',
        name = 'maintenanceMadness-subfooter-legendLabel4',
        style = 'info_label'
    }
    legend.label4.style.right_margin = 14

    legend.contentFlow2 = subfooter_flow.add {
        type = 'flow',
        direction = 'horizontal'
    }
    legend.contentFlow2.style.minimal_height = 24
    subfooter_flow.style.vertical_align = 'center'
    legend.label5 = legend.contentFlow2.add {
        type = 'label',
        name = 'maintenanceMadness-subfooter-legendLabel5',
        style = 'info_label'
    }
    legend.label5.style.right_margin = 14
    legend.label6 = legend.contentFlow2.add {
        type = 'label',
        name = 'maintenanceMadness-subfooter-legendLabel6',
        style = 'info_label'
    }
    legend.label6.style.right_margin = 14
    legend.label7 = legend.contentFlow2.add {
        type = 'label',
        name = 'maintenanceMadness-subfooter-legendLabel7',
        style = 'info_label'
    }
    legend.label7.style.right_margin = 14

    buildFooter( gui, 'maintenanceMadness-window-footer', {
        backButton = true,
        confirmButton = true,
        draggable = true,
        player_index = player_index
    } )

    root.tabContainer.selected_tab_index = ui.selectedTab or 1
    updateLegendInformation( player_index, root.tabContainer.selected_tab_index,
                             ui.hideLegend )
end

function mmGUI.updateReplacementPolicySlider( element, player_index )
    local buttonReference =
        global.userInterface[player_index].buttonReference[element.name]
    local confirmButton =
        global.userInterface[player_index].buttonReference['maintenanceMadness-window-footer-confirmButton']
    if buttonReference then
        local sliderValue = replacementAgeGetSliderValue( element.slider_value )
        local sibling =
            global.userInterface[player_index].buttonReference[buttonReference.sibling]
                .element

        local control = global.temporaryMaintenanceControl[player_index]
                            .byEntity[buttonReference.entity][buttonReference.policyType]
        local changedControls = global.changedControlSettings[player_index]

        if not changedControls.byEntity then
            changedControls.byEntity = {}
        end
        if not changedControls.byEntity[buttonReference.entity] then
            changedControls.byEntity[buttonReference.entity] = {}
        end
        if not changedControls.byEntity[buttonReference.entity][buttonReference.policyType] then
            changedControls.byEntity[buttonReference.entity][buttonReference.policyType] =
                {}
        end

        if control.start ~= sliderValue then
            -- save new value
            if not changedControls.byEntity[buttonReference.entity][buttonReference.policyType]
                .start then
                changedControls.total = changedControls.total + 1
            end
            changedControls.byEntity[buttonReference.entity][buttonReference.policyType]
                .start = sliderValue
            confirmButton.enabled = true
        else
            -- same value as default -> remove this from the list
            if changedControls.byEntity[buttonReference.entity][buttonReference.policyType]
                .start ~= nil then
                changedControls.total = changedControls.total - 1
            end
            changedControls.byEntity[buttonReference.entity][buttonReference.policyType]
                .start = nil

            if changedControls.total == 0 then
                confirmButton.enabled = false
            end
        end

        local sibling_sliderValue = replacementAgeGetSliderValue(
                                        sibling.slider_value )

        if (sibling_sliderValue < sliderValue and sibling_sliderValue > 0) or
            (sliderValue == 0 and sibling_sliderValue > 0) then
            -- adjust slider for max replacement age
            sibling.slider_value = replacementAgeSetSliderValue( sliderValue )
            mmGUI.updateForcedReplacementPolicySlider( sibling, player_index )
        end

        local label =
            global.userInterface[player_index].labelReference[buttonReference.effectLabelName]
        local noReplacementLabel = global.userInterface[player_index]
                                       .labelReference[buttonReference.effectLabelName ..
                                       '-no-replacement']
        local icon =
            global.userInterface[player_index].iconReference[buttonReference.effectLabelName ..
                '-icon']
        local warningArrow =
            global.userInterface[player_index].iconReference[buttonReference.effectLabelName ..
                '-warning-arrow']
        local warningIcon_1 =
            global.userInterface[player_index].iconReference[buttonReference.effectLabelName ..
                '-warning-icon-1']
        local warningLabel_1 =
            global.userInterface[player_index].labelReference[buttonReference.effectLabelName ..
                '-warning-1']
        local warningIcon_2 =
            global.userInterface[player_index].iconReference[buttonReference.effectLabelName ..
                '-warning-icon-2']
        local warningLabel_2 =
            global.userInterface[player_index].labelReference[buttonReference.effectLabelName ..
                '-warning-2']
        local warningIcon_3 =
            global.userInterface[player_index].iconReference[buttonReference.effectLabelName ..
                '-warning-icon-3']

        if label.valid then
            local valueStart = sliderValue
            local valueLimit = replacementAgeGetSliderValue(
                                   sibling.slider_value )
            local caption = ''
            if valueStart < valueLimit then
                caption =
                    format_percentage( valueStart / 100, 0.01 ) .. ' … ' ..
                        format_percentage( valueLimit / 100, 0.01 )
            elseif valueStart == valueLimit then
                caption = '= ' .. format_percentage( valueStart / 100, 0.01 )
            elseif (valueStart > 0) and (valueLimit == 0) then
                caption = format_percentage( valueStart / 100, 0.01 ) .. ' +'
            end
            label.caption = caption
        end

        local machineFailureRate
        local machineReplacementCost

        if sliderValue > 0 then
            local machineFailureRateIndex =
                calculateFailureRate( const.replacementAge ) -- default value
            local thisMachineFailureRate = calculateFailureRate( sliderValue )
            machineFailureRate = (thisMachineFailureRate /
                                     machineFailureRateIndex) - 1

            local machineReplacementCostIndex = 1 /
                                                    (const.replacementAge /
                                                        const.maxAge)
            local thisMachineReplacementCost = 1 / (sliderValue / const.maxAge)
            machineReplacementCost = (thisMachineReplacementCost /
                                         machineReplacementCostIndex) - 1

            element.style = 'notched_slider'
            if label.valid then
                label.visible = true
            end
            if noReplacementLabel.valid then
                noReplacementLabel.visible = false
            end
            if warningIcon_3.valid then
                warningIcon_3.sprite = 'warning-icon'
                warningIcon_3.tooltip =
                    { 'gui.mm-tooltip-warning-operation-age' }
            end
        else
            machineFailureRate = { 'gui.mm-no-replacement-max-failure' }
            machineReplacementCost = -1

            element.style = 'maintenanceMadness_red_notched_slider'
            if label.valid then
                label.visible = false
            end
            if noReplacementLabel.valid then
                noReplacementLabel.visible = true
            end
            if warningIcon_3.valid then
                warningIcon_3.sprite = 'danger-icon'
                warningIcon_3.tooltip =
                    { 'gui.mm-tooltip-danger-operation-age' }
            end
        end

        if sliderValue ~= const.replacementAge then
            if warningArrow.valid then
                warningArrow.visible = true
            end
            if warningIcon_1.valid then
                warningIcon_1.visible = true
            end
            if warningIcon_2.valid then
                warningIcon_2.visible = true
            end

            if machineReplacementCost > 0 then
                if warningLabel_1.valid then
                    warningLabel_1.caption = '+'
                    warningLabel_1.style.font_color = const.textColors.negative
                end
            else
                if warningLabel_1.valid then
                    warningLabel_1.caption = ''
                    warningLabel_1.style.font_color = const.textColors.positive
                end
            end
            if warningLabel_1.valid then
                warningLabel_1.visible = true
                warningLabel_1.caption =
                    warningLabel_1.caption ..
                        format_percentage( machineReplacementCost, 0.01 )
            end
            if tonumber( machineFailureRate ) ~= nil then
                if machineFailureRate > 0 then
                    if warningLabel_2.valid then
                        warningLabel_2.caption = '+'
                        warningLabel_2.style.font_color = const.textColors
                                                              .negative
                    end
                else
                    if warningLabel_2.valid then
                        warningLabel_2.caption = ''
                        warningLabel_2.style.font_color = const.textColors
                                                              .positive
                    end
                end
                if warningLabel_2.valid then
                    warningLabel_2.visible = true
                    warningLabel_2.caption =
                        warningLabel_2.caption ..
                            format_percentage( machineFailureRate, 0.01 )
                end
            else
                if warningLabel_2.valid then
                    warningLabel_2.visible = true
                    warningLabel_2.style.font_color = const.textColors.negative
                    warningLabel_2.caption = machineFailureRate
                end
            end
        else
            if warningArrow.valid then
                warningArrow.visible = false
            end
            if warningLabel_1.valid then
                warningLabel_1.visible = false
                warningLabel_1.caption = ''
            end
            if warningLabel_1.valid then
                warningLabel_2.visible = false
                warningLabel_2.caption = ''
            end
            if warningIcon_1.valid then
                warningIcon_1.visible = false
            end
            if warningIcon_2.valid then
                warningIcon_2.visible = false
            end
        end
        if sliderValue == 0 or sliderValue > 100 then
            warningIcon_3.visible = true
        else
            warningIcon_3.visible = false
        end
    end
end

function mmGUI.updateForcedReplacementPolicySlider( element, player_index )
    local buttonReference =
        global.userInterface[player_index].buttonReference[element.name]
    local confirmButton =
        global.userInterface[player_index].buttonReference['maintenanceMadness-window-footer-confirmButton']
    if buttonReference then
        local sliderValue = replacementAgeGetSliderValue( element.slider_value )
        local sibling =
            global.userInterface[player_index].buttonReference[buttonReference.sibling]
                .element

        local control = global.temporaryMaintenanceControl[player_index]
                            .byEntity[buttonReference.entity][buttonReference.policyType]
        local changedControls = global.changedControlSettings[player_index]

        if not changedControls.byEntity then
            changedControls.byEntity = {}
        end
        if not changedControls.byEntity[buttonReference.entity] then
            changedControls.byEntity[buttonReference.entity] = {}
        end
        if not changedControls.byEntity[buttonReference.entity][buttonReference.policyType] then
            changedControls.byEntity[buttonReference.entity][buttonReference.policyType] =
                {}
        end

        if control.limit ~= sliderValue then
            -- save new value
            if not changedControls.byEntity[buttonReference.entity][buttonReference.policyType]
                .limit then
                changedControls.total = changedControls.total + 1
            end
            changedControls.byEntity[buttonReference.entity][buttonReference.policyType]
                .limit = sliderValue
            confirmButton.enabled = true
        else
            -- same value as default -> remove this from the list
            if changedControls.byEntity[buttonReference.entity][buttonReference.policyType]
                .limit ~= nil then
                changedControls.total = changedControls.total - 1
            end
            changedControls.byEntity[buttonReference.entity][buttonReference.policyType]
                .limit = nil

            if changedControls.total == 0 then
                confirmButton.enabled = false
            end
        end
        local sibling_sliderValue = replacementAgeGetSliderValue(
                                        sibling.slider_value )

        if (sibling_sliderValue > sliderValue and sliderValue > 0) or
            (sibling_sliderValue == 0 and sliderValue > 0) then
            -- adjust slider for min replacement age
            sibling.slider_value = replacementAgeSetSliderValue( sliderValue )
            mmGUI.updateReplacementPolicySlider( sibling, player_index )
        end

        local label =
            global.userInterface[player_index].labelReference[buttonReference.effectLabelName]

        if label.valid then
            local valueStart = replacementAgeGetSliderValue(
                                   sibling.slider_value )
            local valueLimit = sliderValue
            local caption = ''
            if valueStart < valueLimit then
                caption =
                    format_percentage( valueStart / 100, 0.01 ) .. ' … ' ..
                        format_percentage( valueLimit / 100, 0.01 )
            elseif valueStart == valueLimit then
                caption = '= ' .. format_percentage( valueStart / 100, 0.01 )
            elseif (valueStart > 0) and (valueLimit == 0) then
                caption = format_percentage( valueStart / 100, 0.01 ) .. ' +'
            end
            label.caption = caption
        end

        if sliderValue > 0 then
            element.style = 'notched_slider'
        else
            element.style = 'maintenanceMadness_red_notched_slider'
        end
    end
end

function mmGUI.toggleItemPolicyButton( element, player_index )
    local bR = global.userInterface[player_index].buttonReference[element.name]
    if bR then
        local control = global.temporaryMaintenanceControl[player_index]
                            .byEntity[bR.entity][bR.policyType]
        local changedControls = global.changedControlSettings[player_index]
        local confirmButton =
            global.userInterface[player_index].buttonReference['maintenanceMadness-window-footer-confirmButton']

        if not changedControls.byEntity then
            changedControls.byEntity = {}
        end
        if not changedControls.byEntity[bR.entity] then
            changedControls.byEntity[bR.entity] = {}
        end
        if not changedControls.byEntity[bR.entity][bR.policyType] then
            changedControls.byEntity[bR.entity][bR.policyType] = {}
        end
        if not changedControls.byEntity[bR.entity][bR.policyType][bR.item] then
            changedControls.byEntity[bR.entity][bR.policyType][bR.item] = {}
        end

        if changedControls.byEntity[bR.entity][bR.policyType][bR.item].enabled ==
            nil then
            buttonEnabled = not control[bR.item].enabled
        else
            buttonEnabled =
                not changedControls.byEntity[bR.entity][bR.policyType][bR.item]
                    .enabled
        end
        -- invert the value every time this button is clicked

        if control[bR.item].enabled ~= buttonEnabled then
            -- save new value
            if changedControls.byEntity[bR.entity][bR.policyType][bR.item]
                .enabled == nil then
                changedControls.total = changedControls.total + 1
            end
            changedControls.byEntity[bR.entity][bR.policyType][bR.item].enabled =
                buttonEnabled
            confirmButton.enabled = true
        else
            -- same value as default -> remove this from the list
            if changedControls.byEntity[bR.entity][bR.policyType][bR.item] ~=
                nil then
                changedControls.total = changedControls.total - 1
            end
            changedControls.byEntity[bR.entity][bR.policyType][bR.item] = nil

            if changedControls.total == 0 then
                confirmButton.enabled = false
            end
        end

        local label =
            global.userInterface[player_index].labelReference[bR.effectLabelName]
        local icon =
            global.userInterface[player_index].iconReference[bR.effectLabelName ..
                '-icon']
        local warningArrow =
            global.userInterface[player_index].iconReference[bR.effectLabelName ..
                '-warning-arrow']
        local warningIcon =
            global.userInterface[player_index].iconReference[bR.effectLabelName ..
                '-warning-icon']
        local warningLabel =
            global.userInterface[player_index].labelReference[bR.effectLabelName ..
                '-warning']
        local itemData

        local itemSpritePathG, itemSpritePath, warningIconSpritePath
        if bR.policyType == 'maintenance' and label.valid then
            itemData =
                global.entitiesWithMROenabled[bR.entity][bR.policyType][const.maintenanceLevel]
            itemSpritePathG = 'maintenance-needed-grey-icon'
            itemSpritePath = 'maintenance-needed-icon'
            warningIconSpritePath = 'item/mm-scrapped-' .. bR.entity
        elseif bR.policyType == 'repair' and label.valid then
            itemData =
                global.entitiesWithMROenabled[bR.entity][bR.policyType][const.maintenanceLevel]
                    .secondary
            itemSpritePathG = 'repair-in-progress-gray-icon'
            itemSpritePath = 'repair-in-progress-icon'
            warningIconSpritePath = 'utility/clock'
        end
        if buttonEnabled then
            element.style = 'green_slot'
        else
            element.style = 'red_slot'
        end
        local newEffectPercentage = 0
        if label.valid then
            for itemName, item in pairs( control ) do
                if changedControls.byEntity[bR.entity][bR.policyType][itemName] then
                    if changedControls.byEntity[bR.entity][bR.policyType][itemName]
                        .enabled then
                        newEffectPercentage =
                            newEffectPercentage +
                                itemData[itemName].expectedEffect
                    else
                        -- this item has just been disabled
                    end
                else
                    -- not setting changed for this item, use current control setting
                    if item.enabled then
                        newEffectPercentage =
                            newEffectPercentage +
                                itemData[itemName].expectedEffect
                    end
                end
            end
            label.caption = format_percentage( newEffectPercentage, 0.001 ) -- const.maxMissedMaintenanceMalus
        end

        if (mceil( 100000 * newEffectPercentage ) / 100000) < 1 then
            local warningPercent
            if bR.policyType == 'maintenance' then
                warningPercent = 1 / (1 / (((1 - newEffectPercentage) *
                                     (const.maxMissedMaintenanceMalus /
                                         const.baseAgeing) + 1) - 1))
            elseif bR.policyType == 'repair' then
                warningPercent = (1 - newEffectPercentage) /
                                     (1 /
                                         ((1 / const.baseRepairEffectivity) - 1))
            end
            if icon.valid then
                icon.sprite = itemSpritePath
            end
            if warningArrow.valid then
                warningArrow.sprite = 'utility/expand'
            end
            if warningIcon.valid then
                warningIcon.sprite = warningIconSpritePath
                warningIcon.visible = true
            end
            if warningLabel.valid then
                warningLabel.caption = '+' ..
                                           format_percentage( warningPercent,
                                                              0.01 )
                warningLabel.visible = true
            end
        else
            if icon.valid then
                icon.sprite = itemSpritePathG
            end
            if warningArrow.valid then
                warningArrow.sprite = 'utility/check_mark_white'
            end
            if warningIcon.valid then
                warningIcon.visible = false
            end
            if warningLabel.valid then
                warningLabel.visible = false
            end
        end
    end
end

function mmGUI.processClickedElement( event )
    local element = event.element
    local element_name = element.name
    local player_index = event.player_index
    local nameStrings = {}
    for i in string.gmatch( string.gsub( element_name, '%-', ' ' ), '%S+' ) do
        nameStrings[i] = true
    end
    if nameStrings['maintenanceMadness'] then
        if nameStrings['mainButton'] or nameStrings['closeButton'] then
            if nameStrings['confirmationDialog'] then
                toggleConfirmationDialog( player_index )
            else
                if global.changedControlSettings[player_index] and
                    global.changedControlSettings[player_index].total > 0 then
                    toggleConfirmationDialog( player_index )
                else
                    mmGUI.toggleMasterPanel( player_index )
                end
            end
        elseif nameStrings['itemPolicyButton'] then
            mmGUI.toggleItemPolicyButton( element, player_index )
        elseif nameStrings['quitConfirmationDialog'] then
            toggleConfirmationDialog( player_index )
        elseif nameStrings['confirmButton'] then
            confirmNewMaintenanceControlSettings( player_index, false )
            mmGUI.toggleMasterPanel( player_index )
        elseif nameStrings['confirmResetButton'] then
            confirmNewMaintenanceControlSettings( player_index, true )
            mmGUI.toggleMasterPanel( player_index )
        elseif nameStrings['discardChangesButton'] then
            discardChangedMaintenanceControlSettings( player_index )
            mmGUI.toggleMasterPanel( player_index )
        elseif nameStrings['resetButton'] or
            nameStrings['quitResetConfirmationDialog'] then
            toggleConfirmResetDialog( player_index )
        elseif nameStrings['toggleLegendButton'] then
            toggleLegend( player_index )
        end
    end
end

function mmGUI.processChangedSlider( event )
    local element = event.element
    local element_name = element.name
    local player_index = event.player_index
    local nameStrings = {}
    for i in string.gmatch( string.gsub( element_name, '%-', ' ' ), '%S+' ) do
        nameStrings[i] = true
    end
    if nameStrings['maintenanceMadness'] then
        if nameStrings['replacmentPolicySlider'] then
            mmGUI.updateReplacementPolicySlider( element, player_index )
        elseif nameStrings['forcedReplacmentPolicySlider'] then
            mmGUI.updateForcedReplacementPolicySlider( element, player_index )
        end
    end
end

function mmGUI.processChangedTab( event )
    local element = event.element
    local player_index = event.player_index
    local ui = global.userInterface[player_index] or {}
    local nameStrings = {}
    for i in string.gmatch( string.gsub( element.name, '%-', ' ' ), '%S+' ) do
        nameStrings[i] = true
    end
    if nameStrings['maintenanceMadness'] then
        ui.selectedTab = element.selected_tab_index
        updateLegendInformation( player_index, element.selected_tab_index,
                                 ui.hideLegend )
    end
end

function mmGUI.processClosedElement( event )
    local element = event.element
    local player_index = event.player_index
    local player = game.players[player_index]
    local ui = global.userInterface[player_index] or {}
    local nameStrings = {}
    if element ~= nil then
        for i in string.gmatch( string.gsub( element.name, '%-', ' ' ), '%S+' ) do
            nameStrings[i] = true
        end
        if nameStrings['maintenanceMadness'] then
            if global.changedControlSettings[player_index] and
                global.changedControlSettings[player_index].total > 0 then
                -- if some settings have been altered but not saved yet: show (or close) confirmation dialog
                toggleConfirmationDialog( player_index )
            else
                -- close the main gui window
                mmGUI.toggleMasterPanel( player_index )
            end
        end
        if ui.root ~= nil and ui.root.gui2 ~= nil then
            -- if the confirmation dialog ("gui2") is still open because some setting has not been saved yet, then return focus to this confirmation dialog
            player.opened = ui.root.gui2
        end
    end
end

return mmGUI
