
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

function ArrDepTimetable:addArrDep(arr, dep)
    assert(dep)
    table.insert(self.arrdeps, {arr = arr, dep = dep})
end 

function ArrDepTimetable:updateArrDep(ind, newArr, newDep)
    assert(ind and newDep)
    assert(self.arrdeps[ind])
    self.arrdeps[ind] = {arr = newArr, dep = newDep}
end 

function ArrDepTimetable:removeArrDep(ind)
    assert(ind)
    assert(self.arrdeps[ind])
    self.arrdeps[ind] = nil
end 

function ArrDepTimetable:absTimeDifference(t1, t2)
    local absDiff = math.abs(t1 - t2)
    return math.min(absDiff, self.period - absDiff)
end

-- @return int? 
function ArrDepTimetable:getDepartureTime(t)
    assert(t)
    local res = {diff = self.period, value = nil}
    for _, arrdep in pairs(self.arrdeps) do
        local arr = arrdep.arr and arrdep.arr or arrdep.dep
        local diff = self:absTimeDifference(arr, t % 3600)
        if (diff < res.diff) then
            res = {diff = diff, value = arrdep.dep}
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