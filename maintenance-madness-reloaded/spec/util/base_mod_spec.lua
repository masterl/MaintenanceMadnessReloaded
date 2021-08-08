insulate( 'util.base_mod module', function()
    local base_mod = require( 'util.base_mod' )

    describe( 'base_mod.get_sound_path', function()
        local get_sound_path = base_mod.get_sound_path
        it( 'should return the correct path for the sound', function()
            local sound_filename<const> = 'test.ogg'
            local expected<const> = '__base__/sounds/' .. sound_filename

            assert.is.equal( expected, get_sound_path( sound_filename ) )
        end )
    end )
end )
