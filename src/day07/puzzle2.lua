local utils = require "utils"

local puzzle2 = {}

function puzzle2.solve(input)
    local lines = utils.splitLines(input)

    local beams = {}

    for i, line in ipairs(lines) do
        local newBeams = {}
        if i == 1 then
            newBeams[line:find("S")] = 1
        else
            for j=1, #line do
                if beams[j] then
                    if line:sub(j, j) == "^" then
                        newBeams[j - 1] = (newBeams[j - 1] or 0) + beams[j]
                        newBeams[j + 1] = (newBeams[j + 1] or 0) + beams[j]
                    else
                        newBeams[j] = (newBeams[j] or 0) + beams[j]
                    end
                end
            end
        end
        beams = newBeams
    end

    local finalBeams = 0
    for _, v in pairs(beams) do
        finalBeams = finalBeams + v
    end

    return finalBeams
end

return puzzle2
