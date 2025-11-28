local utils = require("utils")
local days = {}

local DAY_CACHE_PATH = "/.cache/days"

local CHOICES = {
    create = "Create files",
    example = "Run examples",
    real = "Run with real input",
    main = "Back to main menu"
}

local PUZZLE_BASE = [[local puzzle%d = {}

function puzzle%d.solve(input)
    return 0
end

return puzzle%d
]]

---@class Day
---@field day integer
---@field title string?
---@field puzzle1 boolean
---@field puzzle2 boolean
local Day = {day = 0, title = nil, puzzle1 = false, puzzle2 = false}
Day.__index = Day

---Creates a new Day object
---@param dayI integer
---@param puzzle1 boolean
---@param puzzle2 boolean
---@return Day
function Day.new(dayI, puzzle1, puzzle2)
    local day = {}
    setmetatable(day, Day)
    day.day = dayI
    day.puzzle1 = puzzle1
    day.puzzle2 = puzzle2
    return day
end

---Returns the title of this day.
---
---This function looks in the following places, in order:
---1. self.title
---2. Cache directory (DAY_CACHE_PATH)
---3. HTTP request to adventofcode.com
---@return string
function Day:getTitle()
    if self.title then
        return self.title
    end
    local cachePath = DAY_CACHE_PATH .. ("/%02d.txt"):format(self.day)
    if fs.exists(cachePath) then
        local cache = fs.open(cachePath, "r")
        if cache then
            local title = cache.readLine()
            cache.close()
            if title then
                self.title = title
                return title
            end
        end
    end
    fs.makeDir(DAY_CACHE_PATH)
    local res = http.get("https://adventofcode.com/2024/day/" .. self.day)
    local title = "Day " .. self.day
    if res then
        local body = res.readAll() or ""
        local htmlTitle = body:match("%-%-%- (Day %d+: .-) %-%-%-")
        if htmlTitle then
            title = htmlTitle
            self.title = title
            local cache = fs.open(cachePath, "w")
            if cache then
                cache.writeLine(title)
                cache.close()
            end
        end
    end
    return title
end

function Day:srcDir()
    return SRC_PATH .. ("/day%02d"):format(self.day)
end

function Day:examplePath(suffix)
    local filename = ("day%02d"):format(self.day)
    if suffix then
        filename = filename .. "_" .. suffix
    end
    return RES_PATH .. "/examples/" .. filename .. ".txt"
end

function Day:inputPath()
    local filename = ("day%02d"):format(self.day)
    return RES_PATH .. "/inputs/" .. filename .. ".txt"
end


---Creates the files for this day.
---
---This method creates the following files:
---- Script for puzzle 1
---- Script for puzzle 2
---- Example input file
---- Real input file
function Day:createFiles()
    local srcDir = self:srcDir()
    fs.makeDir(srcDir)
    utils.writeFile(srcDir .. "/puzzle1.lua", PUZZLE_BASE:format(1, 1, 1))
    utils.writeFile(srcDir .. "/puzzle2.lua", PUZZLE_BASE:format(2, 2, 2))
    utils.writeFile(self:examplePath(), "")
    utils.writeFile(self:inputPath(), "")
end

function Day:getExampleData(suffix)
    return utils.readFile(self:examplePath(suffix))
end

function Day:getInputData()
    return utils.readFile(self:inputPath())
end

function Day:execPuzzle(puzzleI, data)
    local puzzle = require(self:srcDir() .. "/puzzle" .. puzzleI)
    local t0 = os.epoch("local")
    local result = puzzle.solve(data)
    local t1 = os.epoch("local")
    print(("(Executed in %.3fs)"):format((t1 - t0) / 1000))
    print("Result:", result)
end

function Day:execExample(puzzleI, suffix)
    local data = self:getExampleData(suffix)
    return self:execPuzzle(puzzleI, data)
end

function Day:execReal(puzzleI)
    local data = self:getInputData()
    return self:execPuzzle(puzzleI, data)
end

function Day:choosePuzzle()
    self:printTitle()
    local c = utils.promptChoices({"Puzzle 1", "Puzzle 2", "Back"})
    return c
end

function Day:printTitle()
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.green)
    print(" -*- [ " .. self:getTitle() .. " ] -*-")
    term.setTextColor(colors.white)
end

---Displays this day and prompts the user with possible actions
function Day:show()
    while true do
        self:printTitle()
        if fs.exists(self:srcDir()) then
            local c = utils.promptChoices({CHOICES.example, CHOICES.real, CHOICES.main})
            if c == CHOICES.main then
                return
            end
            local puzzle = self:choosePuzzle()
            if puzzle ~= "Back" then
                local puzzleI = ({
                    ["Puzzle 1"] = 1,
                    ["Puzzle 2"] = 2
                })[puzzle]
                if c == CHOICES.example then
                    self:execExample(puzzleI)
                elseif c == CHOICES.real then
                    self:execReal(puzzleI)
                end
                utils.waitForKey(keys.enter)
            end
        else
            local c = utils.promptChoices({CHOICES.create, CHOICES.main})
            if c == CHOICES.main then
                return
            elseif c == CHOICES.create then
                self:createFiles()
            end
        end
    end
end

days.Day = Day

return days