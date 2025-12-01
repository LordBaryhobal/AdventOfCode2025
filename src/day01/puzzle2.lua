local utils = require "utils"
local puzzle2 = {}

function puzzle2.solve(input)
    local password = 0
    local cursor = 50
    
    local lines = utils.splitLines(input)
    for _, line in ipairs(lines) do
        local dir = line:sub(1, 1)
        local dist = tonumber(line:sub(2))
        if dir == "R" then
            cursor = cursor + dist
            if cursor > 99 then
                password = password + math.floor(cursor / 100)
            end
        else
            cursor = cursor - dist
            if cursor <= 0 then
                if cursor ~= -dist then
                    password = password + 1
                end
                password = password + math.floor(-cursor / 100)
            end
        end
        cursor = cursor % 100
    end
    return password
end

return puzzle2
