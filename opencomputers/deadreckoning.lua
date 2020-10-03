local robot = require('robot')

local direction = {
    north = 0,
    east = 1,
    south = 2,
    west = 3
}

local function getDelta(dir)
    return ({
        [direction.north] = {0, -1},
        [direction.east] = {1, 0},
        [direction.south] = {0, 1},
        [direction.west] = {-1, 0}
    })[dir]
end

local RobotWrapper = {}

RobotWrapper.__index = RobotWrapper

function RobotWrapper.new(x, y, z, facing)
    local self = setmetatable({}, RobotWrapper)
    self.x = x and x or 0
    self.y = y and y or 0
    self.z = z and z or 0
    self.facing = facing and facing or 0
    return self
end

function RobotWrapper:coords()
    return {x = self.x, y = self.y, z = self.z, facing = self.facing}
end

function RobotWrapper:turnLeft()
    self.facing = (self.facing - 1) % 4
    robot.turnLeft()
end

function RobotWrapper:turnRight()
    self.facing = (self.facing + 1) % 4
    robot.turnRight()
end

function RobotWrapper:turnAround()
    self.facing = (self.facing + 2) % 4
    robot.turnAround()
end

function RobotWrapper:turnTo(direction)
    while self.facing ~= direction do
        self:turnRight()
    end
end

function RobotWrapper:forward()
    local worked, err = robot.forward()
    if worked then
        local dx, dz = table.unpack(getDelta(self.facing))
        self.x = self.x + dx
        self.z = self.z + dz
    end
    return worked, err
end

function RobotWrapper:back()
    local worked, err = robot.back()
    if worked then
        local dx, dz = table.unpack(getDelta(self.facing))
        self.x = self.x - dx
        self.z = self.z - dz
    end
    return worked, err
end

function RobotWrapper:up()
    local worked, err = robot.up()
    if worked then
        self.y = self.y + 1
    end
    return worked, err
end

function RobotWrapper:down()
    local worked, err = robot.down()
    if worked then
        self.y = self.y - 1
    end
    return worked, err
end

return {
    direction = direction,
    getDelta = getDelta,
    RobotWrapper = RobotWrapper
}