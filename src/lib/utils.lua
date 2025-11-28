local utils = {}

function utils.promptChoices(choices)
    local c = 1
    local ox, oy = term.getCursorPos()
    while true do
        term.setCursorPos(ox, oy)
        for i, choice in ipairs(choices) do
            if i == c then
                term.setTextColor(colors.white)
            else
                term.setTextColor(colors.lightGray)
            end
            print(choice)
        end
        local event, key, is_held = os.pullEvent("key")
        if key == keys.up then
            c = math.max(1, c - 1)
        elseif key == keys.down then
            c = math.min(#choices, c + 1)
        elseif key == keys.enter then
            break
        end
    end
    term.setTextColor(colors.white)
    return choices[c]
end

function utils.readFile(path)
    if not fs.exists(path) then
        printError("File " .. path .. " not found")
        return nil
    end
    local file = fs.open(path, "r")
    if not file then
        printError("Could not open file")
        return nil
    end
    local data = file.readAll()
    file.close()
    return data
end

function utils.waitForKey(targetKey)
    if targetKey then
        print("Press " .. keys.getName(targetKey):upper() .. " to continue")
    else
        print("Press any key to continue")
    end
    while true do
        local event, key, is_held = os.pullEvent("key")
        if not targetKey or key == targetKey then
            break
        end
    end
end

return utils
