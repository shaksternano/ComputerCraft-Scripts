local DIG_WIDTH = 2

local POSITIVE_X = "positive_x"
local NEGATIVE_X = "negative_x"
local POSITIVE_Z = "positive_z"
local NEGATIVE_Z = "negative_z"

local relativeX = 0
local relativeY = 0
local relativeZ = 0

local START_ORIENTATION = POSITIVE_X
local relativeOrientation = START_ORIENTATION

local nextTurnIsRight = true

local movedX = 0
local movedZ = 0
local canMove = true

function digAndMoveForward()
    local moved = turtle.forward()
    if not moved then
        turtle.dig()
        moved = turtle.forward()
    end

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

function digAndMoveDown()
    local moved = turtle.down()
    if not moved then
        turtle.digDown()
        moved = turtle.down()
    end

    if (moved) then
        relativeY = relativeY - 1
    end

    return moved
end

function digAndMoveUp()
    local moved = turtle.up()
    if not moved then
        turtle.digUp()
        moved = turtle.up()
    end

    if (moved) then
        relativeY = relativeY + 1
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

function oritentate(direction)
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

    oritentate(direction)
end

function faceTowardsZ(z)
    local direction
    if z - relativeZ > 0 then
        direction = POSITIVE_Z
    else
        direction = NEGATIVE_Z
    end

    oritentate(direction)
end

function needToRefuel()
    local distanceBack = relativeX + relativeY + relativeZ
    return distanceBack * 2 >= turtle.getFuelLevel()
end

function isInventoryFull()
    for i = 1, 16 do
        if turtle.getItemCount(i) == 0 then
            return false
        end
    end

    return true
end

function travelTo(x, y, z)
    if x ~= relativeX or y ~= relativeY or z ~= relativeZ then
        local toTravelY = y - relativeY
        local goUp = toTravelY > 0
        for i = 1, math.abs(toTravelY) do
            if (goUp) then
                digAndMoveUp()
            else
                digAndMoveDown()
            end
        end

        faceTowardsX(x)
        local toTravelX = x - relativeX
        for i = 1, math.abs(toTravelX) do
            digAndMoveForward()
        end

        faceTowardsZ(z)
        local toTravelZ = z - relativeZ
        for i = 1, math.abs(toTravelZ) do
            digAndMoveForward()
        end
    end
end

function resupply()
    travelTo(0, 0, 0)
    deposit()
    refuelFromStation()
end

function refuel()
    for i = 1, 16 do
        if turtle.getFuelLevel() < turtle.getFuelLimit() then
            turtle.select(i)
            for i = 1, turtle.getItemCount() do
                if turtle.getFuelLevel() < turtle.getFuelLimit() then
                    turtle.refuel(1)
                else
                    break
                end
            end
        else
            break
        end
    end
end

function refuelFromStation()
    turtle.select(1)
    local hasMoreItems = true
    while turtle.getFuelLevel() < turtle.getFuelLimit() and hasMoreItems do
        hasMoreItems = turtle.suckUp()
        refuel()
    end
end

function deposit()
    turnLeft()
    for i = 1, 16 do
        turtle.select(i)
        turtle.drop()
    end
    turnRight()
end

function execute()
    resupply()
    while canMove do
        if needToRefuel() then
            refuel()
        end
        
        if (needToRefuel() or isInventoryFull()) then
            local currentX = relativeX
            local currentY = relativeY
            local currentZ = relativeZ
            local currentOrientation = relativeOrientation
            resupply()
            travelTo(currentX, currentY, currentZ)
            oritentate(currentOrientation)
        end

        canMove = digAndMoveForward()
        if (canMove) then
            movedX = movedX + 1

            if movedX == DIG_WIDTH then
                movedX = 0
                if movedZ == DIG_WIDTH then
                    movedZ = 0
                    nextTurnIsRight = not nextTurnIsRight
                    turn(nextTurnIsRight)
                    canMove = digAndMoveDown()
                else
                    turn(nextTurnIsRight)
                    canMove = digAndMoveForward()
                    if (canMove) then
                        turn(nextTurnIsRight)
                        movedZ = movedZ + 1
                        nextTurnIsRight = not nextTurnIsRight
                    end
                end
            end
        end
    end

    travelTo(0, 0, 0)
    oritentate(START_ORIENTATION)
    deposit()
end

execute()
