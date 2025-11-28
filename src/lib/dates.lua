local dates = {}

---Checks whether date2 is after date1
---@param date1 any
---@param date2 any
---@return boolean
function dates.isAfter(date1, date2)
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
function dates.isBefore(date1, date2)
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

function dates.isInDateRange(startDate, targetDate, endDate)
    return not (
        dates.isBefore(startDate, targetDate) or
        dates.isAfter(endDate, targetDate)
    )
end

return dates