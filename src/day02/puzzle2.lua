local utils = require "utils"
local puzzle1 = require(SRC_PATH .. "/day02/puzzle1")
local puzzle2 = {}

function puzzle2.isValid(id)
    local str = tostring(id)
    local totLen = #str
    for len=1, totLen - 1 do
        if totLen % len == 0 then
            local ref = str:sub(1, len)
            local allSame = true
            for i=1, totLen / len - 1 do
                if str:sub(len * i + 1, len * (i + 1)) ~= ref then
                    allSame = false
                    break
                end
            end
            if allSame then
                return false
            end
        end
    end
    return true
end

function puzzle2.countInvalids(range)
    local min, max = puzzle1.splitRange(range)
    local total = 0
    for i=min, max do
        if not puzzle2.isValid(i) then
            total = total + i
        end
    end
    return total
end

function puzzle2.solve(input)
    local ranges = utils.split(input, ",")
    local total = 0
    for _, range in ipairs(ranges) do
        total = total + puzzle2.countInvalids(range)
    end
    return total
end

return puzzle2
