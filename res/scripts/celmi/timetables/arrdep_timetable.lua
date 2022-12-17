
--[[
ArrDepTimetable = {
    period :: int, 
    arrdeps = {{arr :: int?, dep :: int}*}
}
--]]

local ArrDepTimetable = {} 
ArrDepTimetable.__index = ArrDepTimetable

function ArrDepTimetable:new(period) 
    assert(period)
    return setmetatable({period = period, arrdeps = {}}, self)
end

function ArrDepTimetable:assertInBounds(ts)
    for _,t in pairs(ts) do
        assert(0 <= t and t < self.period)
    end
end

function ArrDepTimetable:addArrDep(arr, dep)
    assert(dep)
    self:assertInBounds({arr, dep})
    table.insert(self.arrdeps, {arr = arr, dep = dep})
end 

function ArrDepTimetable:updateArrDep(ind, newArr, newDep)
    assert(ind and newDep)
    assert(self.arrdeps[ind])
    self:assertInBounds({newArr, newDep})
    self.arrdeps[ind] = {arr = newArr, dep = newDep}
end 

function ArrDepTimetable:removeArrDep(ind)
    assert(ind)
    assert(self.arrdeps[ind])
    self.arrdeps[ind] = nil
end 

function ArrDepTimetable:timeDiff(t1, t2)
    self:assertInBounds({t1, t2})
    return (t1 + self.period - t2) % self.period
end

function ArrDepTimetable:inInterval(t, l, r)
    assert(t and l and r) 
    self:assertInBounds({t, l, r})

    local tonumber = function(value)
        return value and 1 or 0
    end
    local score = tonumber(l <= t) + tonumber(t <= r) + tonumber(l <= r) 
    return (score % 2 == 1)
end 

function ArrDepTimetable:positionInInterval(t, l, r)
    assert(t and l and r) 
    self:assertInBounds({t, l, r})
    if self:inInterval(t, l, r) then 
        return {inside = true}
    else 
        local after = self:timeDiff(t, r) 
        local before = self:timeDiff(l, t) 
        return (after < before) and {after = after} or {before = before}
    end 
end 

-- @return int? 
function ArrDepTimetable:getDepartureTime(t)
    assert(t)
    local t = t % self.period 
    local res = {score = nil, value = nil}
    
    for _, arrdep in pairs(self.arrdeps) do
        local arr = arrdep.arr and arrdep.arr or arrdep.dep
        local dep = arrdep.dep 
        local pos = self:positionInInterval(t, arr, dep)
        local k, v = next(pos)
        if k == "inside" then 
            return dep 
        elseif (res.score == nil) or (v < res.score) then 
            res.score = v
            res.value = dep
        end
    end

    return res.value
end

function ArrDepTimetable:fromOld(old_arrdeps)
    local timetable = ArrDepTimetable:new(60 * 60)
    for _,v in ipairs(old_arrdeps) do 
        local arr = v[1] * 60 + v[2] 
        local dep = v[3] * 60 + v[4] 
        timetable:addArrDep(arr, dep)
    end 
    return timetable
end 

return ArrDepTimetable