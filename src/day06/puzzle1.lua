local strings = require "cc.strings"
local puzzle1 = {}

function puzzle1.solve(input)
    local lines = strings.split(input, "\n")
    local problems = {}
    local n = #lines

    local ops = strings.split(lines[n], "%s+")

    for i, line in ipairs(lines) do
        local j = 1
        for num in line:gmatch("(%d+)") do
            local op = ops[j]
            if i == 1 then
                if op == "+" then
                    table.insert(problems, 0)
                else
                    table.insert(problems, 1)
                end
            end
            local val = tonumber(num)
            if op == "+" then
                problems[j] = problems[j] + val
            else
                problems[j] = problems[j] * val
            end
            j = j + 1
        end
    end

    local total = 0
    for _, val in ipairs(problems) do
        total = total + val
    end
    return total
end

return puzzle1
