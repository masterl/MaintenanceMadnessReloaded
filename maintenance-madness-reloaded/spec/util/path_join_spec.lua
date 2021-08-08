insulate( 'util.path_join', function()
    local path_join = require( 'util.path_join' )

    it( 'should join paths using /', function()
        local base<const> = '__mod__/some/folder'
        local file<const> = 'test.png'
        local expected<const> = base .. '/' .. file

        assert.is.equal( expected, path_join( base, file ) )
    end )
end )
