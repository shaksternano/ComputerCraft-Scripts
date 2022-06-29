local RADIUS = 9

local POSITIVE_X = "positive_x"
local NEGATIVE_X = "negative_x"
local POSITIVE_Z = "positive_z"
local NEGATIVE_Z = "negative_z"

local relativeX = 0
local relativeY = 0
local relativeZ = 0

local START_ORIENTATION = POSITIVE_X
local relativeOrientation = START_ORIENTATION

function forward()
    local moved = turtle.forward()

    if (moved) then
        if relativeOrientation == POSITIVE_X then
            relativeX = relativeX + 1
        elseif relativeOrientation == NEGATIVE_X then
            relativeX = relativeX - 1
        elseif relativeOrientation == POSITIVE_Z then
            relativeZ = relativeZ + 1
        elseif relativeOrientation == NEGATIVE_Z then
            relativeZ = relativeZ - 1
        end
    end

    return moved
end

function turnRight()
    turtle.turnRight()

    if relativeOrientation == POSITIVE_X then
        relativeOrientation = POSITIVE_Z
    elseif relativeOrientation == POSITIVE_Z then
        relativeOrientation = NEGATIVE_X
    elseif relativeOrientation == NEGATIVE_X then
        relativeOrientation = NEGATIVE_Z
    elseif relativeOrientation == NEGATIVE_Z then
        relativeOrientation = POSITIVE_X
    end
end

function turnLeft()
    turtle.turnLeft()

    if relativeOrientation == POSITIVE_X then
        relativeOrientation = NEGATIVE_Z
    elseif relativeOrientation == NEGATIVE_Z then
        relativeOrientation = NEGATIVE_X
    elseif relativeOrientation == NEGATIVE_X then
        relativeOrientation = POSITIVE_Z
    elseif relativeOrientation == POSITIVE_Z then
        relativeOrientation = POSITIVE_X
    end
end

function turn(right)
    if right then
        turnRight()
    else
        turnLeft()
    end
end

function orientate(direction)
    while relativeOrientation ~= direction do
        turnRight()
    end
end

function faceTowardsX(x)
    local direction
    if x - relativeX > 0 then
        direction = POSITIVE_X
    else
        direction = NEGATIVE_X
    end

    orientate(direction)
end

function faceTowardsZ(z)
    local direction
    if z - relativeZ > 0 then
        direction = POSITIVE_Z
    else
        direction = NEGATIVE_Z
    end

    orientate(direction)
end

function travelTo(x, y, z)
    if x ~= relativeX or y ~= relativeY or z ~= relativeZ then
        local toTravelY = math.abs(y - relativeY)
        if (y > relativeY) then
            for _ = 1, toTravelY do
                digAndMoveUp()
            end
        end

        faceTowardsX(x)
        local toTravelX = x - relativeX
        for _ = 1, math.abs(toTravelX) do
            forward()
        end

        faceTowardsZ(z)
        local toTravelZ = z - relativeZ
        for _ = 1, math.abs(toTravelZ) do
            forward()
        end

        if (y < relativeY) then
            for _ = 1, toTravelY do
                digAndMoveDown()
            end
        end
    end
end

function refuelFromStation()
    turtle.select(1)
    local hasMoreItems = true
    while turtle.getFuelLevel() < turtle.getFuelLimit() / 2 and hasMoreItems do
        hasMoreItems = turtle.suckUp(1)
        turtle.refuel()
    end
end

function deposit()
    turnLeft()
    turnLeft()
        for i = 1, 16 do
            turtle.select(i)
            turtle.drop()
        end
    turnRight()
    turnRight()
end

function resupply()
    travelTo(0, 0, 0)
    orientate(START_ORIENTATION)
    deposit()
    refuelFromStation()
end

function pickupFlower()
    local success, data = turtle.inspectDown()
    if success then
        if data.name ~= "botania:jaded_amaranthus" then
            turtle.digDown()
        end
    end
end

function execute()
    while (true) do
        resupply()

        local nextTurnIsRight = true
        for i = 1, RADIUS do
            for j = 1, RADIUS do
                pickupFlower()

                if (j ~= RADIUS) then
                    forward()
                end
            end

            if (i ~= RADIUS) then
                if (nextTurnIsRight) then
                    turnRight()
                    forward()
                    turnRight()
                else
                    turnLeft()
                    forward()
                    turnLeft()
                end
                nextTurnIsRight = not nextTurnIsRight
            end
        end
    end
end

execute()
