local utils = require "utils"

local puzzle1 = {}

function puzzle1.inGrid(x, y, w, h)
    return 1 <= x and x <= w and 1 <= y and y <= h
end

function puzzle1.isAccessible(lines, w, h, x, y)
    local neighbors = 0
    for dy=-1, 1 do
        for dx=-1, 1 do
            if dx ~=0 or dy ~= 0 then
                local x2 = x + dx
                local y2 = y + dy
                if puzzle1.inGrid(x2, y2, w, h) then
                    if lines[y2]:sub(x2, x2) == "@" then
                        neighbors = neighbors + 1
                    end
                end
            end
        end
    end
    return neighbors < 4
end

function puzzle1.solve(input)
    local lines = utils.splitLines(input)
    local accessible = 0

    local h = #lines
    local w = #lines[1]

    for y, line in ipairs(lines) do
        for x=1, #line do
            if line:sub(x, x) == "@" and puzzle1.isAccessible(lines, w, h, x, y) then
                accessible = accessible + 1
            end
        end
    end
    return accessible
end

return puzzle1
