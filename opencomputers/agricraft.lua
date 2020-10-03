--[[
	Place first seeds in slots 1 and 2
	Place bonemeal and crop sticks everywhere else (no particular order)
]]

component = require('component')
robot = require('robot')
sides = require('sides')

geolyzer = component.geolyzer
inventory = component.inventory

GENERATIONS = 8
CROP_STICKS = 'AgriCraft:cropsItem'
BONEMEAL = 'minecraft:dye'

function findItem(name) -- Returns the first slot that the string was found in, or nil if not found
	for slot = 1, robot.inventorySize() do
		if string.find(string.lower(inventory.getStackInInternalSlot(i).name), name) ~= nil then
			return slot
		end
	end
	return nil
end

print('EnderCorp Incorporated Darwinism Simulator Initializing...')

for slot = 1, 4 do -- Plant the first seeds
	robot.forward()
	robot.select(i)
	inventory.equip()
	robot.use(sides.bottom)
	robot.back()
	robot.turnLeft()
end

for i = 1, GENERATIONS do

	for i = 1, 4 do -- Create 4 seeds

		local cropStickSlot = findItem(CROP_STICKS) -- Get crop sticks
		if cropStickSlot == nil then -- If out of crop sticks
			print('No crop sticks found, waiting to be resupplied')
			while cropStickSlot == nil do -- Wait for new crop sticks
				os.sleep(10)
				cropStickSlot = findItem(CROP_STICKS)
			end 
		end

		print('Found crop sticks in slot ' .. cropStickSlot)

		robot.select(cropStickSlot)
		inventory.equip()
		robot.use(sides.bottom)
		robot.use(sides.bottom)

		print('Placed crop sticks')

		local bonemealSlot = findItem(BONEMEAL)
		if bonemealSlot == nil then
			print('No bonemeal found, waiting to be resupplied')
			
			while bonemealSlot == nil do
				os.sleep(10)
				cropStickSlot = findItem(CROP_STICKS)
			end

			print('Found bonemeal in slot ' .. bonemealSlot)
			robot.select(bonemealSlot)
			inventory.equip()



		end
	end

end