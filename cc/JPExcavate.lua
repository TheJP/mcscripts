--Created by TheJP
--Script which excavates the land. It tries to be more reliable than the standard excavate.
--Set this script as startup script so it can run optimally.

--Prints the program usage.
function usage()
    print("Usage: " .. shell.getRunningProgram() .. " [<dimension>]")
    print("If a dimension is given, a new excavation is started.")
    print("Otherwise the script tries to continue the last excavation.")
    print("Tip: Place a chest in the 1. slot of the turtle before starting it.")
end

--[[ Constants --]]
--Directory, in which all state is stored.
dir = ".exv/"
dimFile = "dimension.dat"
stateFile = "state.dat"

stateDown = "d"
stateUp = "u"

--Initializes the program.
function init()
    fs.makeDir(dir)
end

--Searches for and selects a slot with blocks.
function findSlot()
    for i = 1,16 do
        if(turtle.getItemCount(i) > 0) then
            turtle.select(i)
            return i
        end
    end
end

function continue()
end

--Start excavation.
--This is the only unsafe operation.
--The turtle should not be unloaded until this function completes
function start(dimension)
    --Dig a hole, that is at least 3 blocks deep
    local digCount = 0
    repeat
        if(turtle.digDown()) then
            digCount = digCount + 1
        end
        turtle.down()
    until(digCount >= 3)
    --Place corner (this is important, so the turtle finds back to the starting position)
    --Because 3 blocks were dug out, we assume that the turtle has 3 placeable blocks
    findSlot()
    turtle.placeUp()
    turtle.turnRight()
    fundSlot()
    turtle.place()
    turtle.turnRight()
    findSlot()
    turtle.place()
    turtle.turnRight()
    turtle.turnRight()
    --World and position are setup
    --Now the state in the file system will be prepared
    local dim = fs.open(dir .. dimFile, "w")
    dim.writeLine(dimension)
    dim.close()
    local state = fs.open(dir .. stateFile, "w")
    state.writeLine(stateDown)
    state.close()
    --Now the turtle is safe to be restarted any time
    print("Turtle is setup and it is safe to unload / reboot it.")
    --Start state machine
    continue()
end

--Entry point of the application
local args = {...}
local argLength = table.getn(args);

if(argLength > 1) then
    usage() error()
end

if(argLength == 1) then
    local dimension = tonumber(args[1])
    if(dimension < 1) then
        usage() error()
    end
    fs.delete(dir)
    init()
    start(dimension)
else
    init()
    continue()
end