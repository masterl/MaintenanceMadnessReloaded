insulate( 'util.get_sound_path', function()
    local get_sound_path = require( 'util.get_sound_path' )

    it( 'should return the correct path for the sound', function()
        local sound_filename<const> = 'test.ogg'
        local expected<const> = '__maintenance-madness-reloaded__/sounds/' ..
                                    sound_filename

        assert.is.equal( expected, get_sound_path( sound_filename ) )
    end )
end )
