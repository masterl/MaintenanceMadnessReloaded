insulate( 'util.ModInfo', function()
    local ModInfo = require( 'util.ModInfo' )

    describe( 'ModInfo:new', function()
        describe( 'when executing without parameters', function()
            it( 'should fail', function()
                assert.has.errors( function()
                    ModInfo:new()
                end )
            end )
        end )

        describe( 'when executing without passing a name', function()
            it( 'should fail', function()
                assert.has.errors( function()
                    ModInfo:new( {} )
                end )
            end )
        end )

        describe( 'when executing without passing a string for the name',
                  function()
            it( 'should fail', function()
                assert.has.errors( function()
                    ModInfo:new( { name = 15 } )
                end )
            end )
        end )

        describe( 'when specifying just the name', function()
            local mod_name = 'test-mod'
            local helper

            setup( function()
                helper = ModInfo:new( { name = mod_name } )
            end )

            it( 'should have name field', function()
                assert.is.equal( mod_name, helper.name )
            end )

            it( 'should have prefix field', function()
                local expected<const> = mod_name .. '-'

                assert.is.equal( expected, helper.prefix )
            end )

            it( 'should have folder field', function()
                local expected<const> = '__' .. mod_name .. '__'

                assert.is.equal( expected, helper.folder )
            end )

            it( 'should have gfx_path field with a default value', function()
                local expected<const> = '__' .. mod_name .. '__/graphics'

                assert.is.equal( expected, helper.gfx_path )
            end )

            it( 'should have sounds_path field with a default value', function()
                local expected<const> = '__' .. mod_name .. '__/sound'

                assert.is.equal( expected, helper.sounds_path )
            end )
        end )

        describe( 'when specifying all options', function()
            local mod_name = 'test-mod'
            local gfx_folder = 'graf'
            local sounds_folder = 'asrar-somzada'
            local helper

            setup( function()
                helper = ModInfo:new( {
                    name = mod_name,
                    gfx_folder = gfx_folder,
                    sounds_folder = sounds_folder
                } )
            end )

            it( 'should have name field', function()
                assert.is.equal( mod_name, helper.name )
            end )

            it( 'should have prefix field', function()
                local expected<const> = mod_name .. '-'

                assert.is.equal( expected, helper.prefix )
            end )

            it( 'should have folder field', function()
                local expected<const> = '__' .. mod_name .. '__'

                assert.is.equal( expected, helper.folder )
            end )

            it( 'should have set gfx_path with specified value', function()
                local expected<const> = '__' .. mod_name .. '__/' .. gfx_folder

                assert.is.equal( expected, helper.gfx_path )
            end )

            it( 'should have sounds_path field with a default value', function()
                local expected<const> = '__' .. mod_name .. '__/' ..
                                            sounds_folder

                assert.is.equal( expected, helper.sounds_path )
            end )
        end )
    end )

    describe( 'ModInfo:get_path_to_graphics', function()
        local mod_name = 'some-test-mod'
        local mod_info

        setup( function()
            mod_info = ModInfo:new( { name = mod_name } )
        end )

        it( 'should return the correct path', function()
            local filename<const> = 'test.png'
            local expected<const> = mod_info.folder .. '/graphics/' .. filename

            assert.is
                .equal( expected, mod_info:get_path_to_graphics( filename ) )
        end )

        it( 'should be able to handle nested folders', function()
            local filename<const> = 'test.png'
            local nested<const> = { 'icons', 'deep' }
            local expected<const> =
                mod_info.folder .. '/graphics/' .. nested[1] .. '/' .. nested[2] ..
                    '/' .. filename

            assert.is.equal( expected, mod_info:get_path_to_graphics( nested[1],
                                                                      nested[2],
                                                                      filename ) )
        end )
    end )

    describe( 'ModInfo:get_path_to_sounds', function()
        local mod_name = 'another-test-mod'
        local mod_info

        setup( function()
            mod_info = ModInfo:new( { name = mod_name } )
        end )

        it( 'should return the correct path', function()
            local filename<const> = 'test.png'
            local expected<const> = mod_info.folder .. '/sound/' .. filename

            assert.is.equal( expected, mod_info:get_path_to_sounds( filename ) )
        end )

        it( 'should be able to handle nested folders', function()
            local filename<const> = 'test.png'
            local nested<const> = { 'icons', 'deep' }
            local expected<const> = mod_info.folder .. '/sound/' .. nested[1] ..
                                        '/' .. nested[2] .. '/' .. filename

            assert.is.equal( expected, mod_info:get_path_to_sounds( nested[1],
                                                                    nested[2],
                                                                    filename ) )
        end )
    end )

    describe( 'ModInfo:add_prefix', function()
        local mod_name = 'prefix-test-mod'
        local mod_info

        setup( function()
            mod_info = ModInfo:new( { name = mod_name } )
        end )

        it( 'should return the string with the correct prefix', function()
            local str<const> = 'some-string'
            local expected<const> = mod_name .. '-' .. str

            assert.is.equal( expected, mod_info:add_prefix( str ) )
        end )
    end )
end )
