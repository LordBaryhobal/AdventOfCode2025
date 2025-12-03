local utils = require("utils")
local puzzle1 = {}

function puzzle1.bankJoltages(bank)
    local joltages = {}
    for i=1, #bank do
        table.insert(joltages, tonumber(bank:sub(i, i)))
    end
    return joltages
end

function puzzle1.findMaxJoltage(bank)
    local maxTens = 0
    local maxJoltage = 0
    local joltages = puzzle1.bankJoltages(bank)

    for i, tens in ipairs(joltages) do
        if tens > maxTens then
            for j=i+1, #joltages do
                local ones = joltages[j]
                local joltage = tens * 10 + ones
                if joltage > maxJoltage then
                    maxTens = tens
                    maxJoltage = joltage
                end
            end
        end
    end
    return maxJoltage
end

function puzzle1.solve(input)
    local banks = utils.splitLines(input)
    local totalJoltage = 0
    for _, bank in ipairs(banks) do
        totalJoltage = totalJoltage + puzzle1.findMaxJoltage(bank)
    end
    return totalJoltage
end

return puzzle1
