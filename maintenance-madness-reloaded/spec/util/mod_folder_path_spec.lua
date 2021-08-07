insulate( 'util.mod_folder_path', function()
    local mod_folder_path = require( 'util/mod_folder_path' )

    it( 'should prefix with mod name', function()
        local some_path<const> = '/graphics/icons/test.png'
        local expected<const> = '__maintenance-madness-reloaded__' .. some_path

        assert.is.equal( expected, mod_folder_path( some_path ) )
    end )
end )
