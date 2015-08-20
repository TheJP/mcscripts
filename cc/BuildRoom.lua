--Created by TheJP
--Script which builds basic cuboids using one block type

--Prints the program usage.
function usage()
    print("Usage: " .. shell.getRunningProgram() .. " <length> <width> <height>")
    print("The turtle is facing in the length direction 1 Block above floor level")
    print("The turtle will build forward, to the right and up")
end

--Searches for a slot with blocks.
--This is blocking until it finds blocks, or the user inserts new blocks into to the turtles inventory.
function findSlot()
    local found = false
    local told = false
    repeat
        --find slot with building blocks
        for i = 1,16 do
            if(turtle.getItemCount(i) > 0) then
                turtle.select(i)
                found = true
                break
            end
        end
        --Tell why the turtle stopped
        if(not found and not told) then
            print(os.getComputerLabel() .. " is waiting for new blocks")
            told = true
        end
    until(found)
end

--Custom placeDown function, which performs a slot check.
function placeDown()
    if(not turtle.placeDown()) then
        findSlot()
        turtle.placeDown()
    end
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
    --build platform in a snake pattern
    local move = turtle.forward
    for x = 1,width do
        for y = 1,length do
            placeDown()
            move()
        end
        turtle.turnLeft()
        turtle.forward()
        turtle.turnRight()
        move = toggleMove(move)
        move()
    end
    --move back to starting position
    if(width % 2 == 1) then
        for i = 1,(length-1) do
            turtle.back()
        end
    end
    turtle.turnRight()
    for i = 1,width do
        turtle.forward()
    end
    turtle.turnLeft()
end

function buildWall(length)
    for i = 1,length do
        placeDown()
        turtle.forward()
    end
    turtle.back()
end

function buildWalls(width, length)
    local walls = { length, width, length, width }
    for i = 1,4 do
        buildWall(walls[i])
        turtle.turnLeft()
    end
end

function buildRoom(width, length, height)
    buildPlatform(width, width)
    turtle.up()
    for i = 1,height do
        buildWalls(width, length)
        turtle.up()
    end
    buildPlatform(width, length)
end

--Entry point of the application
local args = {...}
local argLength = table.getn(args);

if(argLength ~= 3) then
    usage() error()
end

local length, width, height = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])

if(length < 3 or width < 3 or height < 1) then
    usage() error()
end

buildRoom(width, length, height)
