local strings = require "cc.strings"
local utils = require "utils"
local puzzle1 = {}

local cache = {}

function puzzle1.countPaths(edges, startDev, endDev)
    local key = startDev .. "-" .. endDev
    if cache[key] then
        return cache[key]
    end
    if startDev == endDev then
        return 1
    end
    local outs = edges[startDev]
    local total = 0
    for _, out in ipairs(outs) do
        total = total + puzzle1.countPaths(edges, out, endDev)
    end
    cache[key] = total
    return total
end

function puzzle1.solve(input)
    local lines = utils.splitLines(input)
    local outputs = {}

    for _, line in ipairs(lines) do
        local device, outs = line:match("(.+): (.+)")
        outputs[device] = strings.split(outs, " ")
    end

    return puzzle1.countPaths(outputs, "you", "out")
end

return puzzle1
