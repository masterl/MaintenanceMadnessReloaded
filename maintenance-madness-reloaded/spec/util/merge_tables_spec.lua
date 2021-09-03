insulate( 'util.merge_tables', function()
    local merge_tables = require( 'util.merge_tables' )

    describe( 'given two tables', function()
        local first_table = { a = 7, b = 2, c = 3 }
        local second_table = { d = 19, e = 12, f = 34 }

        it( 'should merge the second table into the first one', function()
            merge_tables( first_table, second_table )

            -- Ensure first_table still has it's elements
            assert.are.equal( first_table.a, 7 )
            assert.are.equal( first_table.b, 2 )
            assert.are.equal( first_table.c, 3 )
            -- Check that new elements have been merged in
            assert.are.equal( first_table.d, 19 )
            assert.are.equal( first_table.e, 12 )
            assert.are.equal( first_table.f, 34 )

        end )
    end )
end )
