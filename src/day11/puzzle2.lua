local strings = require "cc.strings"
local utils = require "utils"
local puzzle2 = {}

local cache = {}

function puzzle2.countPaths(edges, startDev, endDev, dac, fft)
    dac = dac or false
    fft = fft or false
    local key = startDev .. "-" .. endDev .. "-" .. tostring(dac) .. "-" .. tostring(fft)
    if cache[key] then
        return cache[key]
    end
    if startDev == endDev then
        if dac and fft then
            return 1
        else
            return 0
        end
    end
    local outs = edges[startDev]
    local total = 0
    for _, out in ipairs(outs) do
        local dac2 = dac
        local fft2 = fft
        if out == "dac" then
            dac2 = true
        elseif out == "fft" then
            fft2 = true
        end
        total = total + puzzle2.countPaths(edges, out, endDev, dac2, fft2)
    end
    cache[key] = total
    return total
end

function puzzle2.solve(input)
    local lines = utils.splitLines(input)
    local outputs = {}

    for _, line in ipairs(lines) do
        local device, outs = line:match("(.+): (.+)")
        outputs[device] = strings.split(outs, " ")
    end

    return puzzle2.countPaths(outputs, "svr", "out")
end

return puzzle2
