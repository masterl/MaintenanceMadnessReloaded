insulate( 'util.conversions.time', function()
    local time = require( 'util.conversions.time' )

    describe( 'time.hours_to_seconds', function()
        local hours_to_seconds = time.hours_to_seconds

        it( 'should correctly convert values from hours to seconds', function()
            assert.are.equal( 3600, hours_to_seconds( 1 ) )
            assert.are.equal( 1800, hours_to_seconds( 0.5 ) )
        end )
    end )

    describe( 'time.seconds_to_ticks', function()
        local seconds_to_ticks = time.seconds_to_ticks

        it( 'should correctly convert values from seconds to game ticks',
            function()
            local TICKS_PER_SECOND = 60

            assert.are.equal( 45 * TICKS_PER_SECOND, seconds_to_ticks( 45 ) )
            assert.are.equal( 70 * TICKS_PER_SECOND, seconds_to_ticks( 70 ) )
        end )
    end )
end )
