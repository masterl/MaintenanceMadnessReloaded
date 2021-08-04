data:extend( {
    {
        type = 'bool-setting',
        name = 'mm-mod-active',
        setting_type = 'runtime-global',
        default_value = true,
        order = 'a1'
    },
    {
        type = 'string-setting',
        name = 'mm-maintenance-cost',
        setting_type = 'runtime-global',
        default_value = 'level-1',
        allowed_values = { 'level-0', 'level-1', 'level-2', 'level-3' },
        order = 'a2'
    },
    {
        type = 'bool-setting',
        name = 'mm-show-flying-text',
        setting_type = 'runtime-global',
        default_value = true,
        order = 'a3'
    },
    {
        type = 'bool-setting',
        name = 'mm-show-maintenance-in-progress-sign-for-solar',
        setting_type = 'runtime-global',
        default_value = false,
        order = 'a4'
    },
    {
        type = 'double-setting',
        name = 'mm-expected-life-time',
        setting_type = 'runtime-global',
        default_value = 12,
        minimum_value = 2,
        maximum_value = 720,
        order = 'a5'
    },
    {
        type = 'double-setting',
        name = 'mm-mean-time-between-maintenance-events',
        setting_type = 'runtime-global',
        default_value = 12,
        minimum_value = 0.5,
        maximum_value = 720,
        order = 'a6'
    },
    {
        type = 'double-setting',
        name = 'mm-mean-time-to-maintain',
        setting_type = 'runtime-global',
        default_value = 3,
        minimum_value = 0.3,
        maximum_value = 30,
        order = 'a7'
    },
    {
        type = 'double-setting',
        name = 'mm-mean-time-to-repair',
        setting_type = 'runtime-global',
        default_value = 5,
        minimum_value = 0.5,
        maximum_value = 300,
        order = 'a8'
    },
    {
        type = 'bool-setting',
        name = 'mm-include-accumulators',
        setting_type = 'runtime-global',
        default_value = true,
        order = 'b1'
    },
    {
        type = 'bool-setting',
        name = 'mm-include-solar-panels',
        setting_type = 'runtime-global',
        default_value = true,
        order = 'b2'
    },
    {
        type = 'bool-setting',
        name = 'mm-include-reactors',
        setting_type = 'runtime-global',
        default_value = true,
        order = 'b3'
    },
    {
        type = 'bool-setting',
        name = 'mm-include-boiler-and-generators',
        setting_type = 'runtime-global',
        default_value = true,
        order = 'b4'
    },
    {
        type = 'bool-setting',
        name = 'mm-include-miners',
        setting_type = 'runtime-global',
        default_value = false,
        order = 'b5'
    },
    {
        type = 'bool-setting',
        name = 'mm-include-roboports',
        setting_type = 'runtime-global',
        default_value = false,
        order = 'b6'
    },
    {
        type = 'bool-setting',
        name = 'mm-include-beacons',
        setting_type = 'runtime-global',
        default_value = true,
        order = 'b7'
    },
    {
        type = 'bool-setting',
        name = 'mm-include-labs',
        setting_type = 'runtime-global',
        default_value = true,
        order = 'b8'
    },
    {
        type = 'int-setting',
        name = 'mm-solar-factor',
        setting_type = 'runtime-global',
        default_value = 3,
        minimum_value = 1,
        maximum_value = 10,
        order = 'c1'
    },
    --[[
    {
        type = "int-setting",
        name = "mm-max-age",
        setting_type = "runtime-global",
        default_value = 100,
        minimum_value = 10,
        maximum_value = 1000,
        order = "c2",
    },]]
    {
        type = 'int-setting',
        name = 'mm-replacement-age',
        setting_type = 'runtime-global',
        default_value = 80,
        minimum_value = 10,
        maximum_value = 300,
        order = 'c3'
    },
    {
        type = 'int-setting',
        name = 'mm-wear-reduction-if-idle',
        setting_type = 'runtime-global',
        default_value = 80,
        minimum_value = 0,
        maximum_value = 100,
        order = 'c4'
    },
    {
        type = 'double-setting',
        name = 'mm-missed-maintenance-malus',
        setting_type = 'runtime-global',
        default_value = 200,
        minimum_value = 0,
        maximum_value = 1000,
        order = 'c5'
    },
    {
        type = 'bool-setting',
        name = 'mm-enable-low-tech-bonus',
        setting_type = 'runtime-global',
        default_value = false,
        order = 'c6'
    },
    {
        type = 'string-setting',
        name = 'mm-low-tech-bonus-target-tech',
        setting_type = 'runtime-global',
        default_value = 'rocket-silo',
        order = 'c7'
    },
    {
        type = 'bool-setting',
        name = 'mm-enable-low-tech-update-notification',
        setting_type = 'runtime-global',
        default_value = true,
        order = 'c8'
    }
} )
