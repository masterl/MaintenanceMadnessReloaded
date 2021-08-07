insulate( 'util.gfx module', function()
    local gfx = require( 'util/gfx' )

    describe( 'gfx.get_icon_path', function()
        local get_icon_path = gfx.get_icon_path
        it( 'should return the correct path for the icon', function()
            local icon_name<const> = 'test.png'
            local expected<const> =
                '__maintenance-madness-reloaded__/graphics/icons/' .. icon_name

            assert.is.equal( expected, get_icon_path( icon_name ) )
        end )
    end )

    describe( 'gfx.get_entity_path', function()
        local get_entity_path = gfx.get_entity_path
        it( 'should return the correct path for the entity', function()
            local entity_filename<const> = 'test.png'
            local expected<const> =
                '__maintenance-madness-reloaded__/graphics/entities/' ..
                    entity_filename

            assert.is.equal( expected, get_entity_path( entity_filename ) )
        end )
    end )
end )
