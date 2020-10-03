--[[
  A program to expand your island without you expanding your island! Put the robot on the side of your current
  island and run this program. The argument -t tells the robot to place up and the argument -b tells the robot
  to place below it
]]

computer = require('computer')
robot = require('robot')
shell = require('shell')

MINIMUM_POWER = 100

function recover()
  print('Moving to recoverable position before terminating...')
  robot.up()
  robot.up()
  robot.turnRight()
  robot.forward()
  robot.forward()
end

local args = {...}

local top = true -- Change me
local bottom = true -- Change me
local blocksPerPlacement = (top and 1 or 0) + (bottom and 1 or 0)

print('EnderCorp Incorporated Island Expansion initializing...')

if top then
  print('Will build top')
end
if bottom then
  print('Will build bottom')
end

while not robot.detect() do
  robot.turnLeft()
end
print('Found valid edge to build from')
robot.turnLeft()
robot.back()

while 1 do

  if computer.energy() < MINIMUM_POWER then -- Ensure there is enough power
    print('I am almost out of power!')
    recover()
    return
  end

  while robot.count() < blocksPerPlacement do -- Ensure there are enough blocks in slot 1
    print('I am out of blocks in this slot')
    local foundValidSlot = false 
    for i=2,robot.inventorySize() do -- Find the next slot with blocks
      if robot.count(i) > 0 then
        print('I found blocks in slot ' .. i)
        foundValidSlot = true
        robot.select(i) -- Move them to slot 1
        robot.transferTo(1) 
        robot.select(1)
        break
      end
    end
    if not foundValidSlot then -- There are no more blocks in the inventory
      print('No more building blocks!')
      recover()
      return
    end
  end

  robot.place() -- Place the block
  if top then
    robot.placeUp()
  end
  if bottom then
    robot.placeDown()
  end

  robot.turnRight() -- Check if it is still next to the island
  if robot.detect() then -- Is it next to the island?
    robot.turnLeft() -- Yes, now move back
    if not robot.back() then -- Was it unable to move back (aka block behind it)?
      print('I am at a concave corner')
      robot.turnRight() -- Yes, now move around the concave corner
      robot.back()
    end
  else -- No, it is floating at the corner of the island
    print('I am at a convex corner')
    robot.turnLeft() -- Turn around and move to the next edge
    robot.turnLeft()
    robot.back()
  end

end