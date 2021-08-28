insulate( 'util.order_generators', function()
    local order_generators = require( 'util.order_generators' )

    describe( 'order_generators.next_simple_order', function()
        local next_simple_order = order_generators.next_simple_order

        describe( 'when passing (\'a\', 1)', function()
            local result = next_simple_order( 'a', 1 )

            it( 'should return a letter', function()
                assert.are.equal( 'a', result.letter )
            end )

            it( 'should return a number', function()
                assert.are.equal( 2, result.number )
            end )

            it( 'should return as_string containing the order string',
                function()
                assert.are.equal( 'a2', result.as_string )
            end )
        end )

        describe( 'when passing (\'a\', 8)', function()
            local result = next_simple_order( 'a', 8 )

            it( 'should return \'b\' letter', function()
                assert.are.equal( 'b', result.letter )
            end )

            it( 'should return the number 1', function()
                assert.are.equal( 1, result.number )
            end )

            it( 'should return as_string containing \'b1\'', function()
                assert.are.equal( 'b1', result.as_string )
            end )
        end )

        -- Wrap around test
        describe( 'when passing (\'z\', 8)', function()
            local result = next_simple_order( 'z', 8 )

            it( 'should return \'a\' letter', function()
                assert.are.equal( 'a', result.letter )
            end )

            it( 'should return the number 1', function()
                assert.are.equal( 1, result.number )
            end )

            it( 'should return as_string containing \'a1\'', function()
                assert.are.equal( 'a1', result.as_string )
            end )
        end )
    end )
end )
