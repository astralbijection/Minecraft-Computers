--[[
	The_Enderpenguin's PID Big Reactors Script

	Usage: > reactor <port id> [redstone, default top]
]]

component = require('component')
sides = require('sides')

reactor = component.br_reactor

K_P = 5
K_D = 0

TOTAL_REACTOR_ENERGY = 10000000
ENERGY_TARGET = 0.75
TEMP_TARGET = 1000

function linMaxExpMinCost(x, k1, k2)
	return -math.exp(-k1 * x) + k2 * x + 1
end

function linMinExpMaxCost(x, k1, k2)
	return math.exp(k1 * x) + k2 * x - 1
end

ARGS = {...}

local lastCost = 0

while true do -- Main loop

	local energy = reactor.getEnergyStored()
	local energyPercent = energy / TOTAL_REACTOR_ENERGY
	local temp = reactor.getCasingTemperature()

	local rawTempCost = TEMP_TARGET - temp
	local rawEnergyCost = ENERGY_TARGET - energyPercent
	local tempCost = linMaxExpMinCost(rawTempCost / 1000, 16, 1)
	local energyCost = linMaxExpMinCost(rawEnergyCost, 16, 1)

	local cost = tempCost + energyCost
	local delta = cost - lastCost
	local out = K_P * cost + K_D * delta
	lastCost = cost

	local clampedOut = math.min(math.max(out, 0), 1)
	reactor.setAllControlRodLevels(100 * (1 - clampedOut))

	print(("tc=%.f,%.2f ec=%.f,%.2f out=%.3f"):format(rawTempCost, tempCost, rawEnergyCost, energyCost, out))
	os.sleep(1) -- Make sure it doesn't lag the server

end
