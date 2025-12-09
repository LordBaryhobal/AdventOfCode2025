local utils = require "utils"
local puzzle1 = {}

function puzzle1.area(tile1, tile2)
    local dx = math.abs(tile2.x - tile1.x) + 1
    local dy = math.abs(tile2.y - tile1.y) + 1
    return dx * dy
end

function puzzle1.solve(input)
    local lines = utils.splitLines(input)
    local tiles = {}

    for _, line in ipairs(lines) do
        local x, y = line:match("(%d+),(%d+)")
        table.insert(tiles, {x=tonumber(x), y=tonumber(y)})
    end

    local maxArea = 0
    for i, tile1 in ipairs(tiles) do
        for j=i+1, #tiles do
            local tile2 = tiles[j]
            local area = puzzle1.area(tile1, tile2)
            maxArea = math.max(maxArea, area)
        end
    end
    return maxArea
end

return puzzle1
