local utils = require "utils"
local puzzle1 = require(SRC_PATH .. "/day08/puzzle1")
local puzzle2 = {}

function puzzle2.solve(input)
    local boxes = {}

    local lines = utils.splitLines(input)

    for i, line in ipairs(lines) do
        local x, y, z = line:match("(%d+),(%d+),(%d+)")
        table.insert(boxes, {x=x, y=y, z=z, i=i, circuit=i})
    end

    local dists = {}
    local circuits = {}

    for i, box1 in ipairs(boxes) do
        circuits[i] = i
        for j=i+1, #boxes do
            local box2 = boxes[j]
            table.insert(dists, {
                i=i,
                j=j,
                dist=puzzle1.dist(box1, box2)
            })
        end
    end

    table.sort(dists, function (a, b)
        return a.dist < b.dist
    end)

    for _, d in ipairs(dists) do
        local circ1 = circuits[d.i]
        local circ2 = circuits[d.j]
        
        local connex = true
        for k, v in pairs(circuits) do
            if v == circ2 then
                circuits[k] = circ1
            elseif v ~= circ1 then
                connex = false
            end
        end
        if connex then
            return boxes[d.i].x * boxes[d.j].x
        end
    end
end

return puzzle2
