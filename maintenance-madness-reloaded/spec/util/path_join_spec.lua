insulate( 'util.path_join', function()
    local path_join = require( 'util.path_join' )

    it( 'should join paths using /', function()
        local base<const> = '__mod__/some/folder'
        local file<const> = 'test.png'
        local expected<const> = base .. '/' .. file

        assert.is.equal( expected, path_join( base, file ) )
    end )

    it( 'should be able to join multiple arguments', function()
        local arguments<const> = { '__mod__', 'some', 'folder', 'test.png' }
        local expected<const> = arguments[1] .. '/' .. arguments[2] .. '/' ..
                                    arguments[3] .. '/' .. arguments[4]

        assert.is.equal( expected, path_join( arguments[1], arguments[2],
                                              arguments[3], arguments[4] ) )
    end )
end )
