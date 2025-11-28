SRC_PATH = "/aoc/src"
RES_PATH = "/aoc/res"

package.path = SRC_PATH .. "/lib/?.lua;" .. package.path

START_DATE = {day=1, month=12, year=2025}
END_DATE = {day=12, month=12, year=2025}

local json = require("json")
local dates = require("dates")
local days = require("days")
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

local function printDateInfo()
    if dates.isBefore(START_DATE, today) then
        print("AoC 2025 has not started yet")
        return
    end
    if dates.isAfter(END_DATE, today) then
        print("AoC 2025 has ended")
        return
    end
    local day = today.day
    print("Day " .. day .. "/" .. END_DATE.day)
end

local function printStats(stats, selected)
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
        term.setTextColor(colors.lightBlue)
        if selected == day then
            write("- ")
        else
            write("  ")
        end
        if not dates.isBefore(date, today) then
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

local function printBanner()
    term.setTextColor(colors.green)
    print("+--------------------------------------+")
    print("|  Welcome to the Advent of Code 2025  |")
    print("+--------------------------------------+")
    term.setTextColor(colors.white)
end

local function main()
    local stats = loadStats("aoc/res/stats.json")
    local selectedDay = math.max(1, math.min(END_DATE.day, today.day))
    if not dates.isInDateRange(START_DATE, today, END_DATE) then
        selectedDay = 1
    end
    
    while true do
        term.clear()
        term.setCursorPos(1, 1)
        printBanner()
        printDateInfo()
        printStats(stats, selectedDay)

        local event, key, is_held = os.pullEvent("key")
        if key == keys.up then
            selectedDay = math.max(1, selectedDay - 1)
        elseif key == keys.down then
            selectedDay = math.min(END_DATE.day, selectedDay + 1)
        elseif key == keys["end"] then
            break
        elseif key == keys.enter then
            local dayStats = stats[("day%02d"):format(selectedDay)]
            local day = days.Day.new(
                selectedDay,
                dayStats.puzzle1,
                dayStats.puzzle2
            )
            day:show()
        end
    end
end

main()