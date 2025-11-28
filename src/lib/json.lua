local json = {}

json.null = {}

local function trim(str)
    return string.gsub(str, "^%s+", "")
end

local function startswith(str, prefix)
    return str:sub(1, prefix:len()) == prefix
end

local function endswith(str, suffix)
    return str:sub(str:len() - suffix:len() + 1) == suffix
end

local function errFactory(prefix)
    return function (message)
        print(prefix .. ": " .. message)
    end
end

local function ifNil(test, ifNil, ifNotNil)
    if test == nil then
        return ifNil
    end
    return ifNotNil
end

local function parseObj(data)
    local printErr = errFactory("Error while parsing object")
    local obj = {}
    local c = ""
    local key = ""
    local keyEnd, value
    local l = -1
    while true do
        if data:len() == l then
            printErr("infinite loop")
            return data, nil
        end
        l = data:len()
        data = trim(data)
        if data:len() == 0 then
            printErr("incomplete object")
            return data, nil
        end
        c = data:sub(1, 1)
        data = data:sub(2)
        if c == "}" then
            break
        end
        if c ~= '"' then
            printErr("key must be a string")
            return data, nil
        end
        keyEnd = data:find('"')
        if not keyEnd then
            printErr("unclosed key")
            return data, nil
        end
        key = data:sub(1, keyEnd - 1)
        data = trim(data:sub(keyEnd + 1))
        c = data:sub(1, 1)
        if c ~= ":" then
            printErr("missing colon after key")
            return data, nil
        end
        data = data:sub(2)
        data, value = json.parse(data)
        if value == nil then
            printErr("malformed value")
            return data, nil
        end
        data = trim(data)
        obj[key] = value

        c = data:sub(1, 1)
        if c == "," then
            data = trim(data:sub(2))
        else
            if data:sub(1, 1) ~= "}" then
                printErr("missing comma")
                return data, nil
            end
            data = trim(data:sub(2))
            break
        end
    end
    return data, obj
end

local function parseList(data)
    local printErr = errFactory("Error while parsing array")
    local list = {}
    local c
    local value
    while true do
        data = trim(data)
        if data:len() == 0 then
            printErr("incomplete array")
            return data, nil
        end
        c = data:sub(1, 1)
        if c == "]" then
            data = data:sub(2)
            break
        end
        data, value = json.parse(data)
        if value == nil then
            printErr("malformed value")
            return data, nil
        end
        data = trim(data)
        list[#list + 1] = value

        c = data:sub(1, 1)
        if c == "," then
            data = trim(data:sub(2))
        else
            if data:sub(1, 1) ~= "]" then
                printErr("missing comma")
                return data, nil
            end
            data = trim(data:sub(2))
            break
        end
    end
    return data, list
end

local function parseString(data)
    local printErr = errFactory("Error while parsing string")
    local str = ""
    local c = ""
    local escape = false
    local escapeMap = {
        b = "\b",
        f = "\f",
        n = "\n",
        r = "\r",
        t = "\t"
    }

    while data:len() ~= 0 do
        c = data:sub(1, 1)
        data = data:sub(2)
        if c == '"' and not escape then
            return data, str
        end
        if escape then
            str = str .. (escapeMap[c] or c)
            escape = false
        else
            if c == "\\" then
                escape = true
            else
                str = str .. c
            end
        end
    end
    printErr("unclosed string")
    return data, nil
end

function json.parse(data)
    data = data:gsub("^%s+", "")
    if data:len() == 0 then
        printError("Empty JSON")
        return data, nil
    end
    local c = data:sub(1, 1)
    local data2 = data:sub(2)
    if c == "{" then
        return parseObj(data2)
    elseif c == "[" then
        return parseList(data2)
    elseif startswith(data, "true") then
        return data:sub(5), true
    elseif startswith(data, "false") then
        return data:sub(6), false
    elseif startswith(data, "null") then
        return data:sub(5), json.null
    elseif c == '"' then
        return parseString(data2)
    end
    
    local m = data:match("^-?%d+%.?%d*[eE]?[+-]?%d*")
    if m then
        data = data:sub(m:len() + 1)
        return data, tonumber(m)
    else
        printError("Malformed JSON")
        return data, nil
    end
end

function json.loads(data)
    local remaining, res = json.parse(data)
    if res == nil then
        printError("An error occured")
    end
    if remaining:len() ~= 0 then
        print("Extra characters: " .. remaining)
    end
    return res
end

local function kind(obj)
    if type(obj) ~= "table" then
        return type(obj)
    end
    local i = 1
    for _ in pairs(obj) do
        if obj[i] ~= nil then
            i = i + 1
        else
            return "table"
        end
    end
    if i == 1 then
        return "table"
    end
    return "array"
end

local function escapeStr(str)
    local in_char  = {'\\', '"', '/', '\b', '\f', '\n', '\r', '\t'}
    local out_char = {'\\', '"', '/',  'b',  'f',  'n',  'r',  't'}
    for i, c in ipairs(in_char) do
        str = str:gsub(c, '\\' .. out_char[i])
    end
    return str
end

function json.dumps(data, indent, sortKeys, depth)
    if data == json.null then
        return "null"
    end

    local t = kind(data)
    if t == "string" then
        return '"' .. escapeStr(data) .. '"'
    elseif t == "number" or t == "boolean" then
        return tostring(data)
    end

    depth = depth or 0
    local spaces = ""
    if indent ~= nil then
        spaces = string.rep(" ", indent * depth)
    end
    local res = ""

    if t == "array" then
        res = res .. "[" .. ifNil(indent, "", "\n")
        for i, val in ipairs(data) do
            if i > 1 then
                res = res .. "," .. ifNil(indent, " ", "\n")
            end
            res = res .. spaces .. string.rep(" ", indent or 0)
            res = res .. json.dumps(val, indent, sortKeys, depth + 1)
        end
        res = res .. ifNil(indent, "", "\n") .. spaces .. "]"
    elseif t == "table" then
        res = res .. "{" .. ifNil(indent, "", "\n")
        local first = true
        local keys = {}
        for k, _ in pairs(data) do
            table.insert(keys, k)
        end
        if sortKeys then
            table.sort(keys)
        end
        for _, k in ipairs(keys) do
            local v = data[k]
            if not first then
                res = res .. "," .. ifNil(indent, " ", "\n")
            end
            first = false
            res = res .. spaces .. string.rep(" ", indent or 0)
            res = res .. '"' .. escapeStr(k) .. '": '
            res = res .. json.dumps(v, indent, sortKeys, depth + 1)
        end
        res = res .. ifNil(indent, "", "\n") .. spaces .. "}"
    end

    return res
end

return json