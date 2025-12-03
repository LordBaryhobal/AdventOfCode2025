local json = require("json")
local utils = require("utils")
local days = {}

local DAY_CACHE_PATH = CACHE_PATH .. "/days"

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
---@field results table
local Day = {day = 0, title = nil, puzzle1 = false, puzzle2 = false, results={}}
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
    day:loadResults()
    return day
end

function Day:cacheDir()
    return DAY_CACHE_PATH .. ("/%02d"):format(self.day)
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
    local cachePath = self:cacheDir() .. "/name.txt"
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
    fs.makeDir(self:cacheDir())
    local res = http.get("https://adventofcode.com/2025/day/" .. self.day)
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

function Day:getResultKey(real, puzzle, suffix)
    local key = ""
    if real then
        key = "input"
    else
        key = "example"
        if suffix then
            key = key .. "_" .. suffix
        end
    end
    key = key .. "-" .. puzzle
    return key
end

function Day:execPuzzle(puzzleI, data, resultKey)
    local path = self:srcDir() .. "/puzzle" .. puzzleI
    package.loaded[path] = nil
    local puzzle = require(path)
    local t0 = os.epoch("local")
    local result = puzzle.solve(data)
    local t1 = os.epoch("local")
    print(("(Executed in %.3fs)"):format((t1 - t0) / 1000))
    print(("Result: %.0f"):format(result))
    self.results[resultKey] = result
    self:saveResults()
end

function Day:execExample(puzzleI, suffix)
    local data = self:getExampleData(suffix)
    return self:execPuzzle(puzzleI, data, self:getResultKey(false, puzzleI, suffix))
end

function Day:execReal(puzzleI)
    local data = self:getInputData()
    return self:execPuzzle(puzzleI, data, self:getResultKey(true, puzzleI))
end

function Day:choosePuzzle(real)
    self:printTitle()
    local choices = {
        {"Puzzle 1", 1},
        {"Puzzle 2", 2},
        "Back"
    }
    local res1 = self.results[self:getResultKey(real, 1)]
    local res2 = self.results[self:getResultKey(real, 2)]
    if res1 then choices[1][1] = choices[1][1] .. (" - %s"):format(res1) end
    if res2 then choices[2][1] = choices[2][1] .. (" - %s"):format(res2) end
    local c = utils.promptChoices(choices)
    return c
end

function Day:menuStars()
    local solvedTxt = function (b)
        if b then
            return "solved"
        end
        return "unsolved"
    end
    local c0 = 1
    while true do
        self:printTitle()
        local choices = {
            {"Mark puzzle 1 as " .. solvedTxt(not self.puzzle1), 1},
            {"Mark puzzle 2 as " .. solvedTxt(not self.puzzle2), 2},
            "Back"
        }
        local c = utils.promptChoices(choices, c0)
        if c == "Back" then
            return
        end
        c0 = c
        if c == 1 then
            self.puzzle1 = not self.puzzle1
        elseif c == 2 then
            self.puzzle2 = not self.puzzle2
        end
        self:saveStats()
    end
end

function Day:saveStats()
    local path = RES_PATH .. "/stats.json"
    local content = utils.readFile(path) or "{}"
    local data = json.loads(content) or {}
    data[("day%02d"):format(self.day)] = {
        puzzle1=self.puzzle1,
        puzzle2=self.puzzle2,
    }
    content = json.dumps(data, 4, true)
    utils.writeFile(path, content, true)
end

function Day:loadResults()
    local path = self:cacheDir() .. "/results.json"
    local results = {}
    if fs.exists(path) then
        local data = utils.readFile(path)
        local r = json.loads(data)
        if type(r) == "table" then
            results = r
        end
    end
    self.results = results
end

function Day:saveResults()
    local data = json.dumps(self.results)
    fs.makeDir(self:cacheDir())
    local path = self:cacheDir() .. "/results.json"
    utils.writeFile(path, data, true)
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
            local c = utils.promptChoices({
                {"Run examples", "examples"},
                {"Run with real input", "inputs"},
                {"Mark solved", "stars"},
                {"Back to main menu", "main"}
            })
            if c == "main" then
                return
            elseif c == "stars" then
                self:menuStars()
            else
                local puzzle = self:choosePuzzle(c == "inputs")
                if puzzle ~= "Back" then
                    if c == "examples" then
                        self:execExample(puzzle)
                    elseif c == "inputs" then
                        self:execReal(puzzle)
                    end
                    utils.waitForKey(keys.enter)
                end
            end
        else
            local c = utils.promptChoices({
                {"Create files", "create"},
                {"Back to main menu", "main"}
            })
            if c == "main" then
                return
            elseif c == "create" then
                self:createFiles()
            end
        end
    end
end

days.Day = Day

return days