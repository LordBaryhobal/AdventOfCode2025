local utils = require "utils"
local puzzle1 = {}

function puzzle1.splitRange(range)
    local parts = utils.split(range, "-")
    return tonumber(parts[1]), tonumber(parts[2])
end

function puzzle1.isValid(id)
    local str = tostring(id)
    if #str % 2 == 1 then
        return true
    end
    local mid = #str / 2
    return str:sub(1, mid) ~= str:sub(mid + 1)
end

function puzzle1.countInvalids(range)
    local min, max = puzzle1.splitRange(range)
    local total = 0
    for i=min, max do
        if not puzzle1.isValid(i) then
            total = total + i
        end
    end
    return total
end

function puzzle1.solve(input)
    local ranges = utils.split(input, ",")
    local total = 0
    for _, range in ipairs(ranges) do
        total = total + puzzle1.countInvalids(range)
    end
    return total
end

return puzzle1
