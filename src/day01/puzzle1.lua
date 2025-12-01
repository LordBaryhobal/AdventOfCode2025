local utils = require "utils"
local puzzle1 = {}

function puzzle1.solve(input)
    local password = 0
    local cursor = 50
    
    local lines = utils.splitLines(input)
    for _, line in ipairs(lines) do
        local dir = line:sub(1, 1)
        local dist = tonumber(line:sub(2))
        if dir == "R" then
            cursor = cursor + dist
        else
            cursor = cursor - dist
        end
        cursor = cursor % 100
        if cursor == 0 then
            password = password + 1
        end
    end
    return password
end

return puzzle1
