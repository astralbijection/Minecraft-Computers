--[[
	The_Enderpenguin's Simple Big Reactors Script

	Usage: > reactor <port id> [redstone, default top]
]]

REACTOR_ENERGY = 10000000
MAX_ENERGY = 9000000 -- The maximum amount of energy allowed
MIN_ENERGY = 1000000 -- The minimum amount of energy allowed

ARGS = {...}
REDSTONESIDE = ARGS[2] or "top"

local reactor = peripheral.wrap(ARGS[1])

if reactor == nil then -- Ensure the reactor is real
	error('No reactors found') -- Quit, theres nothing to do here.
else
	print('Found a reactor')
end

while true do -- Main loop

	if reactor.getEnergyStored() > MAX_ENERGY then -- The max cap
		reactor.setActive(false)
	elseif reactor.getEnergyStored() < MIN_ENERGY then -- The min cap
		reactor.setActive(true)
	end

	if redstone.getOutput(REDSTONESIDE) then -- Is it turned off?
		reactor.setActive(false)
		while redstone.getOutput(REDSTONESIDE) do
			sleep(10) -- Make sure it doesn't lag the server
		end
	end

	sleep(5) -- Make sure it doesn't lag the server

end
