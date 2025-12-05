local strings = require "cc.strings"
local puzzle2 = {}

function puzzle2.solve(input)
    local lines = strings.split(input, "\n")
    local bounds = {}

    for _, line in ipairs(lines) do
        if line == "" then
            break
        end
        local min, max = line:match("(%d+)%-(%d+)")
        min = tonumber(min)
        max = tonumber(max)
        table.insert(bounds, {i=min, type="start"})
        table.insert(bounds, {i=max, type="end"})
    end

    table.sort(bounds, function (a, b)
        if a.i == b.i then
            return a.type == "start" and b.type == "end"
        end
        return a.i < b.i
    end)

    local totalFresh = 0
    local min = 0
    local balance = 0

    for _, bound in ipairs(bounds) do
        if bound.type == "start" then
            if balance == 0 then
                min = bound.i
            end
            balance = balance + 1
        else
            balance = balance - 1
            if balance == 0 then
                totalFresh = totalFresh + bound.i - min + 1
            end
        end
    end

    return totalFresh
end

return puzzle2
