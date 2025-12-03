local utils = require("utils")
local puzzle1 = require(SRC_PATH .. "/day03/puzzle1")
local puzzle2 = {}

local cache = {}

function puzzle2.findMaxJoltage(bank, joltages, n, startI)
    startI = startI or 1
    local key = bank:sub(startI) .. "-" .. tostring(n)
    if cache[key] then
        return cache[key]
    end

    local maxJoltage = 0
    local maxDigit = 0

    if startI > #joltages then
        return nil
    end

    if n == 1 then
        for i=startI, #joltages do
            if joltages[i] > maxDigit then
                maxDigit = joltages[i]
            end
        end
        cache[key] = maxDigit
        return maxDigit
    end

    local i = startI
    while i <= #joltages do
        local digit = joltages[i]
        if digit > maxDigit then
            local maxSuffix = puzzle2.findMaxJoltage(bank, joltages, n - 1, i + 1)
            if maxSuffix ~= nil then
                local joltage = tonumber(tostring(digit) .. tostring(maxSuffix))
                if joltage > maxJoltage then
                    maxDigit = digit
                    maxJoltage = joltage
                end
            end
        end
        i = i + 1
    end
    if maxJoltage == 0 then
        return nil
    end
    cache[key] = maxJoltage
    return maxJoltage
end

function puzzle2.solve(input)
    local banks = utils.splitLines(input)
    local totalJoltage = 0
    for _, bank in ipairs(banks) do
        local joltages = puzzle1.bankJoltages(bank)
        local max = puzzle2.findMaxJoltage(bank, joltages, 12)
        totalJoltage = totalJoltage + max
    end
    return totalJoltage
end

return puzzle2
