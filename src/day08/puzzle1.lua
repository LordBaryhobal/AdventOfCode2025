local utils = require "utils"
local puzzle1 = {}

function puzzle1.dist(box1, box2)
    return math.sqrt(
        (box2.x - box1.x) ^ 2 +
        (box2.y - box1.y) ^ 2 +
        (box2.z - box1.z) ^ 2
    )
end

function puzzle1.pretty(box)
    return ("%d,%d,%d"):format(box.x, box.y, box.z)
end

function puzzle1.solve(input)
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

    local N = 1000
    if #boxes < 100 then
        N = 10
    end

    for i, d in ipairs(dists) do
        if i > N then
            break
        end
        local circ1 = circuits[d.i]
        local circ2 = circuits[d.j]

        for k, v in pairs(circuits) do
            if v == circ2 then
                circuits[k] = circ1
            end
        end
    end

    local circuitSizes = {}

    for _, c in pairs(circuits) do
        circuitSizes[c] = (circuitSizes[c] or 0) + 1
    end

    local sizes = {}

    for _, s in pairs(circuitSizes) do
        table.insert(sizes, s)
    end

    table.sort(sizes)
    local n = #sizes

    return sizes[n] * sizes[n - 1] * sizes[n - 2]
end

return puzzle1
