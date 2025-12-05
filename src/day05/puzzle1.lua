local strings = require "cc.strings"
local puzzle1 = {}

function puzzle1.isFresh(ranges, i)
    for _, range in ipairs(ranges) do
        if range[1] <= i and i <= range[2] then
            return true
        end
    end
    return false
end

function puzzle1.solve(input)
    local lines = strings.split(input, "\n")
    local ranges = {}

    local bIngr = false
    local totalFresh = 0

    for _, line in ipairs(lines) do
        if line == "" then
            bIngr = true
        else
            if bIngr then
                local ingr = tonumber(line)
                if puzzle1.isFresh(ranges, ingr) then
                    totalFresh = totalFresh + 1
                end
            else
                local min, max = line:match("(%d+)%-(%d+)")
                table.insert(ranges, {tonumber(min), tonumber(max)})
            end
        end
    end

    return totalFresh
end

return puzzle1
