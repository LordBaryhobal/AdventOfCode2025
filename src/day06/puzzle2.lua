local strings = require "cc.strings"
local puzzle2 = {}

function puzzle2.parseNumbers(lines)
    local numbers = {}
    local n = #lines

    for i, line in ipairs(lines) do
        if i ~= n then
            for j=1, #line do
                local c = line:sub(j, j)
                if #numbers < j then
                    table.insert(numbers, {})
                end
                if c ~= " " then
                    table.insert(numbers[j], c)
                end
            end
        end
    end

    local problems = {{}}
    for _, num in ipairs(numbers) do
        if #num == 0 then
            table.insert(problems, {})
        else
            local value = tonumber(table.concat(num, ""))
            table.insert(problems[#problems], value)
        end
    end
    return problems
end

function puzzle2.solve(input)
    local lines = strings.split(input, "\n")
    local values = puzzle2.parseNumbers(lines)
    local ops = strings.split(lines[#lines], "%s+")

    local total = 0
    for p, numbers in ipairs(values) do
        local op = ops[p]
        local value = 0
        if op == "*" then
            value = 1
        end
        for _, num in ipairs(numbers) do
            if op == "+" then
                value = value + num
            else
                value = value * num
            end
        end
        total = total + value
    end
    return total
end

return puzzle2
