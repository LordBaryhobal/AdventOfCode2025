package.path = "/aoc/src/lib/?.lua;" .. package.path
require("aoc")
local json = require("json")
local utils = require("utils")
local buffer = require("buffer")
local stats = json.loads(utils.readFile(RES_PATH .. "/stats.json")) or {}
local readmePath = ROOT_PATH .. "/README.md"
local outBuf = buffer.Buffer.new()

local function insertInReadme()
    local body = utils.readFile(readmePath) or ""
    local tagStart = "<!-- calendar-start -->"
    local tagEnd = "<!-- calendar-end -->"
    body = body:gsub(
        tagStart:gsub("%-", "%%-") .. ".-" .. tagEnd:gsub("%-", "%%-"),
        tagStart .. "\n" .. outBuf:tostring() .. tagEnd
    )
    utils.writeFile(readmePath, body, true)
end

local totalStars = 0
for _, s in pairs(stats) do
    if s.puzzle1 then totalStars = totalStars + 1 end
    if s.puzzle2 then totalStars = totalStars + 1 end
end

local startTS = 1764543600

local startDate = os.date("*t", startTS)
local firstWeekday = (startDate.wday + 5) % 7
local padding = {x=3, y=1}

local dayNames = {
    "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"
}

local day = -firstWeekday + 1

local rowSep = "+"
local padRow = "|"
for _ = 1, 7 do
    rowSep = rowSep .. string.rep("-", padding.x * 2 + 3) .. "+"
    padRow = padRow .. string.rep(" ", padding.x * 2 + 3) .. "|"
end

local function printRow(cells, cellWidth, padding)
    local xPad = string.rep(" ", padding.x)
    local height = 0
    for _, cell in ipairs(cells) do
        height = math.max(height, type(cell) == "string" and 1 or #cell)
    end

    for i = -padding.y + 1, height + padding.y do
        write("|")
        for _, cell in ipairs(cells) do
            local text = cell[i] or ""
            if type(cell) == "string" and i == 1 then
                text = cell
            end
            local pad = cellWidth - #text
            local lPad = math.ceil(pad / 2)
            local rPad = pad - lPad
            write(xPad .. string.rep(" ", lPad))
            if i > 1 and i <= height then
                term.setTextColor(colors.orange)
            end
            write(text)
            term.setTextColor(colors.white)
            write(string.rep(" ", rPad) .. xPad .. "|")
        end
        print()
    end
    print(rowSep)
end

term.clear()
term.setCursorPos(1, 1)
term.setTextColor(colors.white)

print(("Stars: %d/24"):format(totalStars, 24))
outBuf:print(("#### Stars: %d/24\n"):format(totalStars, 24))

print(rowSep)
printRow(dayNames, 3, padding)

outBuf:print("|" .. table.concat(dayNames, "|") .. "|")
for _ = 1, 7 do
    outBuf:write("|:-:")
end
outBuf:print("|")

while day < 12 do
    local row = {}
    local outRow = {}
    for _ = 1, 7 do
        if day < 1 or day > 12 then
            table.insert(row, "")
            table.insert(outRow, "")
        else
            local dayStats = stats[("day%02d"):format(day)]
            local stars = 0
            if dayStats.puzzle1 then stars = stars + 1 end
            if dayStats.puzzle2 then stars = stars + 1 end
            local cell = {
                tostring(day),
                string.rep("\x04", stars, " ")
            }
            table.insert(row, cell)
            cell = {
                tostring(day),
                string.rep(":star:", stars, "")
            }
            table.insert(outRow, table.concat(cell, "<br>"))
        end
        day = day + 1
    end
    printRow(row, 3, padding)
    outBuf:print("|" .. table.concat(outRow, "|") .. "|")
end

insertInReadme()

---@diagnostic disable-next-line: undefined-field
term.screenshot()
os.sleep(2)