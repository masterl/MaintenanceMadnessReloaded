local function make_cursor_box( name, x, y, shift )
    return {
        type = 'sprite',
        name = name,
        filename = '__core__/graphics/cursor-boxes.png',
        priority = 'extra-high-no-scale',
        width = 64,
        height = 64,
        scale = 0.5,
        -- tint = {1, 0.75, 0.5, 1},
        x = x,
        y = y,
        shift = (function()
            if shift then
                return { 0.5 - shift[1] / 32.0, 0.5 - shift[2] / 32.0 }
            else
                return { 0.5, 0.5 }
            end
        end)()
    }
end

local cursor_box_1 = make_cursor_box( 'selection-box-small', 128, 256 )
local cursor_box_2 = make_cursor_box( 'selection-box-medium', 64, 256 )
local cursor_box_3 = make_cursor_box( 'selection-box-large', 0, 256 )

data:extend( { cursor_box_1, cursor_box_2, cursor_box_3 } )

data:extend( {
    {
        type = 'sprite',
        name = 'maintenance-needed-icon',
        filename = '__maintenance-madness-reloaded__/graphics/icons/maintenance-needed.png',
        flags = { 'icon' },
        priority = 'extra-high',
        width = 64,
        height = 64,
        shift = { 0, 0 },
        scale = 0.5
    },
    {
        type = 'sprite',
        name = 'maintenance-needed-grey-icon',
        filename = '__maintenance-madness-reloaded__/graphics/icons/maintenance-needed-grey.png',
        flags = { 'icon' },
        priority = 'extra-high',
        width = 64,
        height = 64,
        shift = { 0, 0 },
        scale = 0.5
    },
    {
        type = 'sprite',
        name = 'machine-malfunction-icon',
        filename = '__maintenance-madness-reloaded__/graphics/icons/machine-malfunction.png',
        flags = { 'icon' },
        priority = 'extra-high',
        width = 64,
        height = 64,
        shift = { 0, 0 },
        scale = 0.5
    },
    {
        type = 'sprite',
        name = 'repair-pending-icon',
        filename = '__maintenance-madness-reloaded__/graphics/icons/repair-pending.png',
        flags = { 'icon' },
        priority = 'extra-high',
        width = 64,
        height = 64,
        shift = { 0, 0 },
        scale = 0.5
    },
    {
        type = 'sprite',
        name = 'repair-in-progress-icon',
        filename = '__maintenance-madness-reloaded__/graphics/icons/repair-in-progress.png',
        flags = { 'icon' },
        priority = 'extra-high',
        width = 64,
        height = 64,
        shift = { 0, 0 },
        scale = 0.5
    },
    {
        type = 'sprite',
        name = 'repair-in-progress-gray-icon',
        filename = '__maintenance-madness-reloaded__/graphics/icons/repair-in-progress-gray.png',
        flags = { 'icon' },
        priority = 'extra-high',
        width = 64,
        height = 64,
        shift = { 0, 0 },
        scale = 0.5
    },
    {
        type = 'sprite',
        name = 'replacement-request-icon',
        filename = '__maintenance-madness-reloaded__/graphics/icons/replacement-request.png',
        flags = { 'icon' },
        priority = 'extra-high',
        width = 64,
        height = 64,
        shift = { 0, 0 },
        scale = 0.5
    },
    {
        type = 'sprite',
        name = 'replacement-required-icon',
        filename = '__maintenance-madness-reloaded__/graphics/icons/replacement-required.png',
        flags = { 'icon' },
        priority = 'extra-high',
        width = 64,
        height = 64,
        shift = { 0, 0 },
        scale = 0.5
    },
    {
        type = 'sprite',
        name = 'warning-icon',
        filename = '__core__/graphics/icons/alerts/warning-icon.png',
        flags = { 'icon' },
        priority = 'extra-high',
        width = 64,
        height = 64,
        shift = { 0, 0 },
        scale = 0.5
    },
    {
        type = 'sprite',
        name = 'danger-icon',
        filename = '__core__/graphics/icons/alerts/danger-icon.png',
        flags = { 'icon' },
        priority = 'extra-high',
        width = 64,
        height = 64,
        shift = { 0, 0 },
        scale = 0.5
    }
} )
