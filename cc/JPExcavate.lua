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
countFile = "count.dat"

stateDown = "d"
stateUp = "u"
stateUnload = "l"
stateUnload2 = "2"
stateUnload3 = "3"
stateSearchNext = "s"
stateSearchNext2 = "b"

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
    return -1
end

--Checks if turtle has empty slot.
--If not, the turtle should be emptied.
function hasEmptySlot()
    for i = 1,16 do
        if(turtle.getItemCount(i) <= 0) then
            return true
        end
    end
    return false
end

--Searches the inventory of the turtle for fuel and refuels itself.
function refuel()
    if(turtle.getFuelLevel() == "unlimited" or turtle.getFuelLevel() > 0) then
        return true
    end
    for i = 1,16 do
        turtle.select(i)
        if(turtle.refuel(1)) then
            return true
        end
    end
    print("Turtle is out of fuel")
    print("Add fuel to the inventory and then restart the program without parameter")
    error()
end

--Movement functions with refueling

function up()
    refuel()
    return turtle.up()
end
function down()
    refuel()
    return turtle.down()
end
function forward()
    refuel()
    return turtle.forward()
end
function back()
    refuel()
    return turtle.back()
end

--Read first line from given file in the script directory.
function get(fileName)
    local file = fs.open(dir .. fileName, "r")
    local result = file.readLine()
    file.close()
    return result
end

--Write first line into given file in the script directory.
function set(fileName, line)
    local file = fs.open(dir .. fileName, "w")
    file.writeLine(line)
    file.close()
    return line
end

--State machine, which stores each state change in a file.
--If the turtle is stopped before it can flush the changes,
--it should be able to define the new state from looking at the previous state and
--the available information.
function continue()
    local dimension = tonumber(get(dimFile))
    local state = get(stateFile)
    local count = get(countFile)
    while(true) do
        if(state == stateDown) then
            if(not hasEmptySlot()) then
                state = set(stateFile, stateUp)
            elseif(not turtle.digDown() and not down()) then
                state = set(stateFile, stateUp)
            end
        elseif(state == stateUp) then
            if(not up()) then
                if(not hasEmptySlot()) then
                    state = set(stateFile, stateUnload)
                else
                    state = set(stateFile, stateSearchNext)
                end
            end
        elseif(state == stateUnload) then
            if(not back()) then
                --There is an inconsistency: If the turtle reboots between the following 2 steps, the system breaks!
                --This could be avoided, by having a compass or only digging 1 wide tunnels.
                state = set(stateFile, stateUnload2)
                turtle.turnLeft()
            end
        elseif(state == stateUnload2) then
            if(not back()) then
                --There is an inconsistency: If the turtle reboots between the following 2 steps, the system breaks!
                --This could be avoided, by having a compass or only digging 1 wide tunnels.
                state = set(stateFile, stateUnload3)
                turtle.turnRight()
            end
        elseif(state == stateUnload3) then
            if(findSlot() > 0) then
                if(not turtle.dropUp()) then
                    print("Target inventory is full")
                    print("Clear out space in the inventory and then restart the program without parameter")
                    error()
                end
            else
                if(count >= (dimension*dimension) - 1) then
                    print("Finished the job!")
                    error()
                end
                count = set(countFile, 0)
                state = set(stateFile, stateSearchNext)
            end
        elseif(state == stateSearchNext) then
            if(count >= (dimension*dimension) - 1) then
                state = set(stateFile, stateUnload)
            elseif(count % dimension >= dimension - 1) then
                --End reched in length: go back, and move to next row
                if(not back()) then
                    --There is an inconsistency: If the turtle reboots between the following 2 steps, the system breaks!
                    --This could be avoided, by having a compass or only digging 1 wide tunnels.
                    state = set(stateFile, stateSearchNext2)
                    turtle.turnLeft()
                end
            else
                if(turtle.inspectDown()) then
                    state = set(stateFile, stateDown)
                else
                    turtle.dig()
                    --There is an inconsistency: If the turtle reboots between the following 2 steps, the system breaks!
                    --This could be avoided, if there was no dimesion constraint to the turtle
                    --The only "bad thing" that could happen is, that the turtle digs too far
                    if(forward()) then
                        count = set(countFile, count + 1)
                    end
                end
            end
        elseif(state == stateSearchNext2) then
            if(count % dimension >= dimension - 1) then
                turtle.dig()
                --There is an inconsistency: If the turtle reboots between the following 2 steps, the system breaks!
                --This could be avoided, if there was no dimesion constraint to the turtle
                --The only "bad thing" that could happen is, that the turtle digs too far
                if(forward()) then
                    count = set(countFile, count + 1)
                end
            else
                --There is an inconsistency: If the turtle reboots between the following 2 steps, the system breaks!
                --This could be avoided, by having a compass or only digging 1 wide tunnels.
                state = set(stateFile, stateSearchNext)
                turtle.turnRight()
            end
        else
            print("Unknown state")
            error()
        end
    end
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
    set(dimFile, dimension)
    set(stateFile, stateDown)
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
    if(not fs.exists(dir .. dimFile) or not fs.exists(dir .. stateFile)) then
        usage() error()
    end
    init()
    continue()
end
