local utils = require "utils"

local puzzle1 = {}

function puzzle1.solve(input)
    local lines = utils.splitLines(input)

    local beams = {}
    local totalSplits = 0

    for i, line in ipairs(lines) do
        local newBeams = {}
        if i == 1 then
            newBeams[line:find("S")] = true
        else
            for j=1, #line do
                if beams[j] then
                    if line:sub(j, j) == "^" then
                        totalSplits = totalSplits + 1
                        newBeams[j - 1] = true
                        newBeams[j + 1] = true
                    else
                        newBeams[j] = true
                    end
                end
            end
        end
        beams = newBeams
    end

    return totalSplits
end

return puzzle1
