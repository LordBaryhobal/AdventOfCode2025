SRC_PATH = "/aoc/src"

package.path = SRC_PATH .. "/lib/?.lua;" .. package.path

START_DATE = {day=1, month=12, year=2025}
END_DATE = {day=12, month=12, year=2025}

local json = require("json")
local today = os.date("*t")

local function loadStats(path)
    path = shell.resolve(path)
    if not fs.exists(path) then
        printError("Stats file not found (" .. path .. ")")
        return
    end
    local file, err = fs.open(path, "r")
    if not file then
        printError("Cannot open stats file")
        return
    end
    local data = json.loads(file.readAll())
    file.close()
    return data
end

---Checks whether date2 is after date1
---@param date1 any
---@param date2 any
---@return boolean
local function isAfter(date1, date2)
    if date2.year < date1.year then
        return false
    elseif date2.year > date1.year then
        return true
    end
    if date2.month < date1.month then
        return false
    elseif date2.month > date1.month then
        return true
    end
    return date2.day > date1.day
end

---Checks whether date2 is before date1
---@param date1 any
---@param date2 any
---@return boolean
local function isBefore(date1, date2)
    if date2.year > date1.year then
        return false
    elseif date2.year < date1.year then
        return true
    end
    if date2.month > date1.month then
        return false
    elseif date2.month < date1.month then
        return true
    end
    return date2.day < date1.day
end

local function isInDateRange(startDate, targetDate, endDate)
    return not (isBefore(startDate, targetDate) or isAfter(endDate, targetDate))
end

local function printDateInfo()
    if isBefore(START_DATE, today) then
        print("AoC 2025 has not started yet")
        return
    end
    if isAfter(END_DATE, today) then
        print("AoC 2025 has ended")
        return
    end
    local day = today.day
    print("Day " .. day .. "/" .. END_DATE.day)
end

local function printStats()
    local stats = loadStats("aoc/res/stats.json")
    local keys = {}
    for k in pairs(stats) do
        table.insert(keys, k)
    end
    table.sort(keys)

    local stars = 0

    for _, key in ipairs(keys) do
        local value = stats[key]
        local day = tonumber(key:sub(4))
        local date = {day=day, month=START_DATE.month, year=START_DATE.year}
        if not isBefore(date, today) then
            term.setTextColor(colors.white)
        else
            term.setTextColor(colors.gray)
        end
        write(string.format("Day %2s ", day))
        if value.puzzle1 then
            term.setTextColor(colors.orange)
            stars = stars + 1
        else
            term.setTextColor(colors.gray)
        end
        write("\x04")
        if value.puzzle2 then
            term.setTextColor(colors.orange)
            stars = stars + 1
        else
            term.setTextColor(colors.gray)
        end
        write("\x04")
        term.setTextColor(colors.white)
        print()
    end

    term.setTextColor(colors.white)
    write(string.format("You have %d", stars))
    term.setTextColor(colors.orange)
    write("\x04")
    term.setTextColor(colors.white)
    print()
end

local function main()
    term.setTextColor(colors.green)
    textutils.slowPrint("+--------------------------------------+", 80)
    textutils.slowPrint("|  Welcome to the Advent of Code 2025  |", 80)
    textutils.slowPrint("+--------------------------------------+", 80)
    term.setTextColor(colors.white)

    printDateInfo()
    printStats()
end

main()