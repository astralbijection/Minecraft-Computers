--[[
	Quarrying Script

	Usage: quarry depth width height [options]

	The chest full of tools is placed behind the robot. A charger can charge the block it starts on.
	
	Options:
		-c: use if continuing from previous quarry attempt. The robot must be placed somewhere directly below the resupply zone. It will stop when it encounters a block above it signaling the resupply zone.
		-y: skip confirmation
]]

local coroutine = require 'coroutine'
local io = require 'io'
local shell = require 'shell'

local component = require 'component'
local computer = require 'computer'
local robot = require 'robot'

local dr = require 'deadreckoning'

local inventory = component.inventory_controller

POWER_PER_METER = 75
BASE_MIN_POWER = 1000
MAX_FWD_ATTEMPTS = 10

local args, opts = shell.parse(...)

local zLen, xLen, yLen = table.unpack(args)
zLen = tonumber(zLen)
xLen = tonumber(xLen)
yLen = tonumber(yLen)

local isContinuing = opts.c
local skipConfirm = opts.y

function getMinPower(wrap)
	return (wrap.x + wrap.y + wrap.z) * POWER_PER_METER + BASE_MIN_POWER
end

function main()
	if not skipConfirm then confirm() end

	local wrap = dr.RobotWrapper.new()

	if isContinuing then
		print('Searching for resupply center above...')
		while wrap:up() do end
		local dy = wrap.y
		print(('Found resupply %sm above, returning to start'):format(dy))
		wrap = dr.RobotWrapper.new()
		while wrap.y ~= -dy do
			wrap:down()
		end
	end
	wrap.facing = dr.direction.south

	local diggingCoro = coroutine.create(diggingTask)
	coroutine.resume(diggingCoro, wrap, xLen, yLen, zLen)

	local fwdAttempts = 0
	while coroutine.status(diggingCoro) ~= 'dead' do

		local coords = wrap:coords()
		local errored, fwdResult, fwdReason = coroutine.resume(diggingCoro)
		print(fwdResult, fwdReason)
		if not fwdResult then
			fwdAttempts = fwdAttempts + 1
			print('Could not move forward, this is attempt #' .. fwdAttempts)
			if fwdAttempts > MAX_FWD_ATTEMPTS then
				print('Cannot break through this obstacle, going around it')
				goOverObstacle(wrap)
			end
		end
		if computer.energy() < getMinPower(wrap) then
			print('Power too low, returning for recharge')
			local returnPos = moveToResupply(wrap)
			print('Arrived at resupply')
			performResupply()
			print('Returning to original location')
			moveToPos(wrap, returnPos)
			print('Returned to original coordinates')
		end

	end
	print('Task complete, returning to original coordinates')
	moveToResupply(wrap)
end

function performResupply()
	print('Depositing all items into the destination chest')
	for i = 2, robot.inventorySize() do
		--robot.
	end
	print('Waiting for full charge')
	while computer.energy() < computer.maxEnergy() - 100 do
		os.sleep(1)
	end
	print('Battery recharged')
end

function goOverObstacle(wrap)
	local originalYPos = wrap.y
	while not wrap:forward() do
		wrap:up()
	end
	while not wrap:down() do
		wrap:forward()
	end
	while wrap.y > originalYPos do
		robot.swingDown()
		wrap:down()
	end
end

function diggingTask(wrap, xLen, yLen, zLen)

	for y=1, yLen do

		local layerEndX = xLen - wrap.x - 1

		local layerEndZ

		if (zLen % 2 == 0) then
			layerEndZ = zLen - wrap.z - 1
		else
			layerEndZ = wrap.z
		end

		local movingLeft = (layerEndX > wrap.x)

		print(('ending at (%s, %s, %s)'):format(layerEndZ, wrap.y, layerEndZ))
		while wrap.x ~= layerEndX or wrap.z ~= layerEndZ do

			local rowEndZ = zLen - wrap.z - 1
			local movingForward = (rowEndZ > wrap.z)
			print(('going %s, rowEndZ = %s'):format(movingForward and 'forward' or 'backward', rowEndZ))
			if movingForward then
				wrap:turnTo(dr.direction.south)
			else
				wrap:turnTo(dr.direction.north)
			end
			while wrap.z ~= rowEndZ do
				local c = wrap:coords()
				print('pos', c.x, c.y, c.z, c.facing)

				robot.swingDown()
				robot.swing()
				local fwdResult, fwdReason = wrap:forward()
				coroutine.yield(fwdResult, fwdReason)
			end

			local turnToLeft = (movingLeft == movingForward)
			local notFinalTile = (wrap.x ~= layerEndX or wrap.z ~= layerEndZ)

			if notFinalTile then
				if turnToLeft then
					print('turning left')
					wrap:turnLeft()
					robot.swingDown()
					robot.swing()
					wrap:forward()
					wrap:turnLeft()
				else
					print('turning right')
					wrap:turnRight()
					robot.swingDown()
					robot.swing()
					wrap:forward()
					wrap:turnRight()
				end
			else
				robot.swingDown()
			end
		end

		robot.swingDown()
		wrap:down()

	end
	
end

function swing(up, forward, down)
	if up then robot.swingUp() end
	if forward then robot.swingForward() end
	if down then robot.swingDown() end
end

function moveToResupply(wrap)
	local returnPos = wrap:coords()

	while wrap.y ~= 0 do
		wrap:up()
	end

	wrap:turnTo(dr.direction.west)
	while wrap.x ~= 0 do
		wrap:forward()
	end
	wrap:turnLeft()
	while wrap.z ~= 0 do
		wrap:back()
	end

	return returnPos
end

function moveToPos(wrap, pos)
	
	while wrap.z ~= pos.z do
		wrap:forward()
	end
	wrap:turnLeft()
	while wrap.x ~= pos.x do
		wrap:forward()
	end
	wrap:turnTo(pos.facing)
	while wrap.y ~= pos.y do
		wrap:down()
	end

end

function confirm()
	print(('Digging out an area of depth %s, width %s, height %s'):format(zLen, xLen, yLen))
	print('Depth is along the axis the robot is currently facing. Width is horizontal and perpendicular to depth, and height is vertical.')
	print('The tools chest is behind the robot. The mined item chest is to the right of the robot. This starting block also has a charger attached to it.')
	print('I will be digging forwards, down, and to the left.')
	if isContinuing then
		print('We are continuing from a previous attempt and there is a resupply zone somewhere above my head. A block is directly above the resupply space.')
	end
	print()
	print('Press ENTER to confirm, or CTRL-ALT-C to quit.')
	io.read()
	print('Okay. Digging begins now.')
end

main()
