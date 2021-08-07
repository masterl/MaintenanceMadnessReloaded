insulate( 'util.add_mod_prefix', function()
    local add_mod_prefix = require( 'util/add_mod_prefix' )

    it( 'should prefix with mod name', function()
        local some_name<const> = 'test-name'
        local expected<const> = 'maintenance-madness-reloaded-' .. some_name

        assert.is.equal( expected, add_mod_prefix( some_name ) )
    end )
end )
