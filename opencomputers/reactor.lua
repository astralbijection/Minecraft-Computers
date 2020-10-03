--[[
	The_Enderpenguin's Simple Big Reactors Script

	Usage: > reactor <port id> [redstone, default top]
]]

component = require('component')
sides = require('sides')

reactor = component.br_reactor

REACTOR_ENERGY = 10000000
MAX_ENERGY = 9000000 -- The maximum amount of energy allowed
MIN_ENERGY = 1000000 -- The minimum amount of energy allowed

ARGS = {...}

while true do -- Main loop

	if reactor.getEnergyStored() > MAX_ENERGY then -- The max cap
		print('Reactor is at max energy limit, deactivating.')
		reactor.setActive(false)
	elseif reactor.getEnergyStored() < MIN_ENERGY then -- The min cap
		print('Reactor is at min energy limit, activating.')
		reactor.setActive(true)
	end

	os.sleep(5) -- Make sure it doesn't lag the server

end
