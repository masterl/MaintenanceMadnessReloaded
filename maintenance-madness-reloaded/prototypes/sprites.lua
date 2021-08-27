local mod_helpers = require( 'util.mod_helpers' )

local this_mod = mod_helpers.this_mod
local core_mod = mod_helpers.core_mod

-- TODO: find on other files all the names listed here and prefix them with mod name

local function make_cursor_box( name, x, y, shift )
    return {
        type = 'sprite',
        name = name,
        filename = core_mod:get_graphics_path( 'cursor-boxes.png' ),
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
        name = this_mod:add_prefix( 'maintenance-needed-icon' ),
        filename = this_mod:get_graphics_path( 'icons/maintenance-needed.png' ),
        flags = { 'icon' },
        priority = 'extra-high',
        width = 64,
        height = 64,
        shift = { 0, 0 },
        scale = 0.5
    },
    {
        type = 'sprite',
        name = this_mod:add_prefix( 'maintenance-needed-grey-icon' ),
        filename = this_mod:get_graphics_path(
            'icons/maintenance-needed-grey.png' ),
        flags = { 'icon' },
        priority = 'extra-high',
        width = 64,
        height = 64,
        shift = { 0, 0 },
        scale = 0.5
    },
    {
        type = 'sprite',
        name = this_mod:add_prefix( 'machine-malfunction-icon' ),
        filename = this_mod:get_graphics_path( 'icons/machine-malfunction.png' ),
        flags = { 'icon' },
        priority = 'extra-high',
        width = 64,
        height = 64,
        shift = { 0, 0 },
        scale = 0.5
    },
    {
        type = 'sprite',
        name = this_mod:add_prefix( 'repair-pending-icon' ),
        filename = this_mod:get_graphics_path( 'icons/repair-pending.png' ),
        flags = { 'icon' },
        priority = 'extra-high',
        width = 64,
        height = 64,
        shift = { 0, 0 },
        scale = 0.5
    },
    {
        type = 'sprite',
        name = this_mod:add_prefix( 'repair-in-progress-icon' ),
        filename = this_mod:get_graphics_path( 'icons/repair-in-progress.png' ),
        flags = { 'icon' },
        priority = 'extra-high',
        width = 64,
        height = 64,
        shift = { 0, 0 },
        scale = 0.5
    },
    {
        type = 'sprite',
        name = this_mod:add_prefix( 'repair-in-progress-gray-icon' ),
        filename = this_mod:get_graphics_path(
            'icons/repair-in-progress-gray.png' ),
        flags = { 'icon' },
        priority = 'extra-high',
        width = 64,
        height = 64,
        shift = { 0, 0 },
        scale = 0.5
    },
    {
        type = 'sprite',
        name = this_mod:add_prefix( 'replacement-request-icon' ),
        filename = this_mod:get_graphics_path( 'icons/replacement-request.png' ),
        flags = { 'icon' },
        priority = 'extra-high',
        width = 64,
        height = 64,
        shift = { 0, 0 },
        scale = 0.5
    },
    {
        type = 'sprite',
        name = this_mod:add_prefix( 'replacement-required-icon' ),
        filename = this_mod:get_graphics_path( 'icons/replacement-required.png' ),
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
        filename = core_mod:get_graphics_path( 'icons/alerts/warning-icon.png' ),
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
        filename = core_mod:get_graphics_path( 'icons/alerts/danger-icon.png' ),
        flags = { 'icon' },
        priority = 'extra-high',
        width = 64,
        height = 64,
        shift = { 0, 0 },
        scale = 0.5
    }
} )
