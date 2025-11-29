local utils = require("utils")
local progress = {}

function progress.bar(x, y, width, value, max, fg, bg)
    local fgWidth = utils.round(value * width / max)
    fgWidth = math.max(0, math.min(width, fgWidth))
    paintutils.drawLine(x, y, x + width - 1, y, bg)
    paintutils.drawLine(x, y, x + fgWidth - 1, y, fg)
    term.setBackgroundColor(colors.black)
end

return progress