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
    return choices[c]
end

return utils
