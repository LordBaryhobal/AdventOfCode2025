local strings = require "cc.strings"
local utils = require "utils"
local puzzle1 = {}

function puzzle1.parseMachine(line)
    local lightsStr = line:match("%[([.#]+)%]")
    local buttonsStr = strings.split(line:match(" (.+) "), " ")

    local lightsBools = {}
    local lightsVal = 0
    for i=1, #lightsStr do
        local c = lightsStr:sub(i, i)
        lightsBools[i] = c == "#"
        if c == "#" then
            local pow = bit.blshift(1, i - 1)
            lightsVal = lightsVal + pow
        end
    end

    local buttons = {}

    for _, btnStr in ipairs(buttonsStr) do
        local lights = {}
        local value = 0
        for n in btnStr:gmatch("%d+") do
            local v = tonumber(n)
            table.insert(lights, v)
            value = value + bit.blshift(1, v)
        end
        table.insert(buttons, {
            lights=lights,
            value=value,
            presses=0
        })
    end

    return {
        lightsBools=lightsBools,
        lightsVal=lightsVal,
        buttons=buttons
    }
end

function puzzle1.startMachine(target, btns)
    local queue = {{value=0, presses=0, used=0}}
    local cache = {}
    while #queue ~= 0 do
        local test = table.remove(queue, 1)
        local key = tostring(test.value) .. "-" .. tostring(test.used)
        if not cache[key] then
            cache[key] = true
            if test.value == target then
                return test.presses
            end
            for i=(test.presses + 1), #btns do
                local pow = bit.blshift(1, i - 1)
                if bit.band(test.used, pow) == 0 then
                    table.insert(queue, {
                        value=bit.bxor(test.value, btns[i].value),
                        presses=test.presses + 1,
                        used=test.used + pow
                    })
                end
            end
        end
    end
    print("Could not find valid button combination")
    return -1
end

function puzzle1.solve(input)
    local lines = utils.splitLines(input)
    local machines = {}
    for _, line in ipairs(lines) do
        table.insert(machines, puzzle1.parseMachine(line))
    end

    local totalPresses = 0

    for i, machine in ipairs(machines) do
        print("Machine " .. tostring(i) .. "/" .. tostring(#machines))
        totalPresses = totalPresses + puzzle1.startMachine(machine.lightsVal, machine.buttons)
    end

    return totalPresses
end

return puzzle1
