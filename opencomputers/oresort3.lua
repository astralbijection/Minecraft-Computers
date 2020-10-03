local robot = require('robot')
local component = require('component')
local sides = require('sides')

local inventory = component.inventory_controller


PULVERIZE_NO_SMELT = {
  'diamond ore', 
  'charged certus quartz ore', 
  'certus quartz ore', 
  'nether quartz ore', 
  'emerald ore', 
  'lapis lazuli ore', 
  'destabilized redstone ore',
  'redstone ore',
  'coal ore',
  'sulfur ore',
  'apatite ore',
  'saltpeter ore',
  'ruby ore',
  'sapphire ore',
  'peridot ore',
  'oil sand',
  'black quartz ore',
  'aquamarine shale',
  'tile.projectred.exploration.ore.name', --'electrotine ore',
  'amber bearing stone',
}
PULVERIZE_SMELT = {
  'nickel ore',
  'iron ore',
  'copper ore',
  'platinum ore',
}
IND_SAND_SMELT = {
  'silver ore',
  'aluminum ore',
  'mana infused ore',
  'tin ore',
  'lead ore',
  'cobalt ore',
  'ardite ore',
  'gold ore',
  'yellorite ore',
  'iridium ore', 
}
IND_SLAG_SMELT = {
}
IND_CINN_SMELT = {
}
MAGMA_CRUCIBLE = {
  'resonant end stone',
  'energized netherrack',
  'oil shale',
}
BREAK = {
  'draconium ore',
  'dimensional shard ore'
}
FURN_SMELT = {
  
}

MISC = -243  -- random number

INPUT = sides.top
DESTINATIONS = {
  {
    [sides.left]=IND_SAND_SMELT, 
    [sides.right]=PULVERIZE_NO_SMELT, 
  }, {
    [sides.left]=PULVERIZE_SMELT, 
    --[sides.right]=IND_CINN_SMELT, 
    [sides.right]=BREAK, 
    [sides.top]=MAGMA_CRUCIBLE,
    [sides.bottom]=MISC
    --[sides.bottom]=FURN_SMELT
  }, {
    --[sides.left]=IND_SLAG_SMELT, 
    [sides.right]=MAGMA_CRUCIBLE, 
  },
}

SIDES_NAME = {
  [sides.front] = 'front',
  [sides.back] = 'back',
  [sides.left] = 'left',
  [sides.right] = 'right',
  [sides.bottom] = 'bottom',
  [sides.top] = 'top'
}

OreLocationTable = {}
OreLocationTable.__index = OreLocationTable

OreDestination = {}
OreDestination.__index = OreDestination

function OreDestination:new(dist, side)
  self.dist = dist
  self.side = side
end

function OreLocationTable.new(destinations)
  local self = setmetatable({}, OreLocationTable)
  self.data = {}
  self.miscOutput = nil
  for i, row in pairs(DESTINATIONS) do  -- each position in front
    for side, names in pairs(row) do  -- each side
      if names == MISC then
        self.miscOutput = {row=i, side=side}
      else
        for _, name in pairs(names) do
          table.insert(self.data, {pattern=name, row=i, side=side})
        end
      end
    end
  end
  assert(self.miscOutput ~= nil, "No MISC output provided!")
  return self
end

function OreLocationTable:getDestinationOf(stack)
  for _, entry in pairs(self.data) do
    if stack.label:lower():match(entry.pattern) then
      return entry
    end
  end
  return self.miscOutput
end

function smartDropIntoSlot(side) 
  local internalStack = inventory.getStackInInternalSlot(robot.select())
  for slot = 1, inventory.getInventorySize(side) do
    local stack = inventory.getStackInSlot(side, slot)
    print('Attempting to drop into slot ' .. slot)
    if (stack == nil) or (stack.id == internalStack.id and internalStack.size + stack.size <= 64) then
      if inventory.dropIntoSlot(side, slot) then
        return true
      end
    end
  end
  return false
end

function waitForSmartDropIntoSlot(side, sleeptime)
  while not smartDropIntoSlot(side) do
    print('Waiting to drop...')
    os.sleep(sleeptime)
  end
end

function outputToSide(side) 
  if side == sides.front or side == sides.top or side == sides.bottom then
    waitForSmartDropIntoSlot(side, 1)
  elseif side == sides.left then
    robot.turnLeft()
    waitForSmartDropIntoSlot(sides.front, 1)
    robot.turnRight()
  elseif side == sides.right then
    robot.turnRight()
    waitForSmartDropIntoSlot(sides.front, 1)
    robot.turnLeft()
  elseif side == sides.back then
    robot.turnLeft()
    robot.turnLeft()
    waitForSmartDropIntoSlot(sides.front, 1)
    robot.turnLeft()
    robot.turnLeft()
  end
end

function main()

  print('EnderCorp Ore Sorting Initializing...')
  
  local oreDestinations = OreLocationTable.new(DESTINATIONS)

  while true do

    for slot = 1, inventory.getInventorySize(INPUT) do -- Find items

      robot.select(1)
      local stack = inventory.getStackInSlot(INPUT, slot)

      if stack ~= nil then -- Is there an item stack there?

        print(string.format('Found in %s: "%s"x%s', slot, stack.label, stack.size))
        local dest = oreDestinations:getDestinationOf(stack)

        print(string.format('Destination is row %s, side %s', dest.row, SIDES_NAME[dest.side]))

        inventory.suckFromSlot(INPUT, slot)
        
        -- Move forward appropriately
        print('Moving into position')
        for i=1,dest.row-1 do
          robot.forward()
        end

        --read() -- breakpoint

        print('Outputting')
        outputToSide(dest.side)

        print('Returning to start')
        for i=1,dest.row-1 do
          robot.back()
        end

      else
        print('No items in slot ' .. slot)
      end

      os.sleep(0.25)
      print()

    end

  end
end

main()
