insulate( 'util.conversions.time', function()
    local time = require( 'util.conversions.time' )

    local SECONDS_PER_MINUTE = 60
    local SECONDS_PER_HOUR = 3600
    local TICKS_PER_SECOND = 60
    local TICKS_PER_MINUTE = SECONDS_PER_MINUTE * TICKS_PER_SECOND

    describe( 'time.hours_to_seconds', function()
        local hours_to_seconds = time.hours_to_seconds

        it( 'should correctly convert values from hours to seconds', function()
            assert.are.equal( 1 * SECONDS_PER_HOUR, hours_to_seconds( 1 ) )
            assert.are.equal( 0.5 * SECONDS_PER_HOUR, hours_to_seconds( 0.5 ) )
        end )
    end )

    describe( 'time.minutes_to_seconds', function()
        local minutes_to_seconds = time.minutes_to_seconds

        it( 'should correctly convert values from minutes to seconds',
            function()
            assert.are.equal( 1 * SECONDS_PER_MINUTE, minutes_to_seconds( 1 ) )
            assert.are.equal( 1.5 * SECONDS_PER_MINUTE,
                              minutes_to_seconds( 1.5 ) )
        end )
    end )

    describe( 'time.minutes_to_ticks', function()
        local minutes_to_ticks = time.minutes_to_ticks

        it( 'should correctly convert values from minutes to ticks', function()
            assert.are.equal( 1 * TICKS_PER_MINUTE, minutes_to_ticks( 1 ) )
            assert.are
                .equal( 17.5 * TICKS_PER_MINUTE, minutes_to_ticks( 17.5 ) )
        end )
    end )

    describe( 'time.seconds_to_ticks', function()
        local seconds_to_ticks = time.seconds_to_ticks

        it( 'should correctly convert values from seconds to game ticks',
            function()

            assert.are.equal( 45 * TICKS_PER_SECOND, seconds_to_ticks( 45 ) )
            assert.are.equal( 70 * TICKS_PER_SECOND, seconds_to_ticks( 70 ) )
        end )
    end )
end )
