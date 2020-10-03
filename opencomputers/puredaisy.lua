component = require('component')
robot = require('robot')
sides = require('sides')

inventory = component.inventory_controller

DELAY = 60

print('EnderCorp Pure Daisy Automation Initializing...')

while true do

	print('Cycling...')

	for _ = 1, 4 do
		robot.forward()
		robot.swingUp()
		robot.placeUp()
		robot.turnLeft()
		robot.forward()
		robot.swingUp()
		robot.placeUp()
	end

	print('Done. Now delaying ' .. DELAY .. ' seconds')

	os.sleep(DELAY)

end