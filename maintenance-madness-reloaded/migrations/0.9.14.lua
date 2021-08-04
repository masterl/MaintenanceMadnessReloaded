for _, force in pairs( game.forces ) do
    initLowTechModifierCalculation( force.index )
    calculateLowTechModifier( force.index, true )
end
