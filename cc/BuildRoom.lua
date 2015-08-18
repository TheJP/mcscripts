--Searches for a slot with blocks.
--This is blocking until it finds blocks, or the user inserts new blocks into to the turtles inventory.
function findSlot()

end

--Decides, which move function a turtle gets.
--If the previous move function was forward it will return back,
--otherwise it will return forward
function toggleMove(previousMove)
    if(previousMove == turtle.forward) then
        return turtle.back
    else
        return turtle.forward
    end
end

--Building functions.
--The following functions have a custom moving and placing behavior

function buildPlatform(width, length)
    local move = turtle.forward
    for x = 1,width do
        for y = 1,length do
            turtle.placeDown()
            move()
        end
        turtle.turnLeft()
        turtle.forward()
        turtle.turnRight()
        move = toggleMove(move)
        move()
    end
end

function buildWalls(width, length)
end

function buildRoom(width, length, height)
    
    buildPlatform(width, width)
    turtle.moveUp()
    for i = 1,height do
        buildWalls(width, length)
        turtle.moveUp()
    end
    buildPlatform(width, height)
end

--Entry point of the application
local args = {...}
local argLength = table.getn(args);

if(argLength ~= 3) then
    print("Usage: " .. shell.getRunningProgram() .. " <length> <width> <height>")
    print("The turtle is facing in the length direction 1 Block above floor level")
    print("The turtle will build forward, to the right and up")
    error()
end

local length, width, height = args[0], args[1], args[2]

buildRoom(width, length, height)
