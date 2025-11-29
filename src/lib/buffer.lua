local buffer = {}

---@class Buffer
local Buffer = {_buf=""}
Buffer.__index = Buffer

---Creates a new buffer
---@param str string?
---@return Buffer
function Buffer.new(str)
    local buf = {}
    buf._buf = str or ""
    setmetatable(buf, Buffer)
    return buf
end

function Buffer:tostring()
    return self._buf
end

function Buffer:clear()
    self._buf = ""
end

function Buffer:write(text)
    self._buf = self._buf .. (text or "")
end

function Buffer:print(text)
    self:write((text or "") .. "\n")
end

buffer.Buffer = Buffer

return buffer