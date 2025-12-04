local utils = require "utils"

local puzzle2 = {}

function puzzle2.inGrid(x, y, w, h)
    return 1 <= x and x <= w and 1 <= y and y <= h
end

function puzzle2.countNeighbors(lines, w, h, x, y)
    local neighbors = 0
    for dy=-1, 1 do
        for dx=-1, 1 do
            if dx ~=0 or dy ~= 0 then
                local x2 = x + dx
                local y2 = y + dy
                if puzzle2.inGrid(x2, y2, w, h) then
                    if lines[y2]:sub(x2, x2) == "@" then
                        neighbors = neighbors + 1
                    end
                end
            end
        end
    end
    return neighbors
end

function puzzle2.copyGrid(grid)
    local grid2 = {}
    for y, row in ipairs(grid) do
        local row2 = {}
        for x, n in ipairs(row) do
            row2[x] = n
        end
        grid2[y] = row2
    end
    return grid2
end

function puzzle2.removeRoll(grid, x, y, w, h)
    for dy=-1, 1 do
        for dx=-1, 1 do
            if dx ~= 0 or dy ~= 0 then
                local x2 = x + dx
                local y2 = y + dy
                if puzzle2.inGrid(x2, y2, w, h) then
                    if grid[y2][x2] > 0 then
                        grid[y2][x2] = grid[y2][x2] - 1
                    end
                end
            end
        end
    end
    grid[y][x] = -1
end

function puzzle2.removeRolls(grid, w, h)
    local removed = 0
    local grid2 = puzzle2.copyGrid(grid)

    for y, row in ipairs(grid) do
        for x, n in ipairs(row) do
            if 0 <= n and n < 4 then
                puzzle2.removeRoll(grid2, x, y, w, h)
                removed = removed + 1
            end
        end
    end

    return removed, grid2
end

function puzzle2.solve(input)
    local lines = utils.splitLines(input)

    local h = #lines
    local w = #lines[1]

    local grid = {}

    for y, line in ipairs(lines) do
        local row = {}
        for x=1, #line do
            local neighbors = -1
            if line:sub(x, x) == "@" then
                neighbors = puzzle2.countNeighbors(lines, w, h, x, y)
            end
            row[x] = neighbors
        end
        grid[y] = row
    end

    local totalRemoved = 0

    local removed = 0
    while true do
        removed, grid = puzzle2.removeRolls(grid, w, h)
        if removed == 0 then
            break
        end
        totalRemoved = totalRemoved + removed
    end

    return totalRemoved
end

return puzzle2
