package.loaded["celmi/timetables/timetable_helper"] = {}

local timetable = require ".res.scripts.celmi.timetables.timetable"

local timetableTests = {}

timetableTests[#timetableTests + 1] = function()
    local x = { testfield = 0 }
    timetable.setTimetableObject(x)
    local y = timetable.getTimetableObject()
    assert(x.testfield == y.testfield, "Error while setting and retriving the same object from the timetable")
end

timetableTests[#timetableTests + 1] = function()
    timetable.setTimetableObject({})
    local x = timetable.getTimeDifference(0,0)
    assert(x == 0, "Difference between same time should be 0")
    x = timetable.getTimeDifference(5,5)
    assert(x == 0, "Difference between same time should be 0")
    x = timetable.getTimeDifference(59,60)
    assert(x == 1, "Difference between 2 times should be 1")
    x = timetable.getTimeDifference(60,59)
    assert(x == 1, "Difference between 2 times should be 1")
    x = timetable.getTimeDifference(10,5)
    assert(x == 5, "Difference between 2 times should be 5")
    x = timetable.getTimeDifference(0,5)
    assert(x == 5, "Difference between 2 times should be 5")
    x = timetable.getTimeDifference(3300,300)
    assert(x == 600, "Difference between 2 times should be 600")
    x = timetable.getTimeDifference(600,2400)
    assert(x == 1800, "Difference between 2 times should be 1800")
end

timetableTests[#timetableTests + 1] = function()
    timetable.setTimetableObject({})
    local x = timetable.getNextConstraint({{30,0,59,0},{9,0,59,0} },1200)
    assert(x[1] == 30 and x[2] == 0 and x[3] == 59 and x[4] == 0, "should choose the closest time constraint")
    x = timetable.getNextConstraint({{30,0,59,0},{11,0,59,0} },1200)
    assert(x[1] == 11 and x[2] == 0 and x[3] == 59 and x[4] == 0, "should choose the closest time constraint")
    x = timetable.getNextConstraint({{51,0,0,0},{50,0,59,0} },1200)
    assert(x[1] == 51 and x[2] == 0 and x[3] == 0 and x[4] == 0, "should choose the closest time constraint")
    x = timetable.getNextConstraint({{51,0,0,0},{49,0,1,0} },1200)
    assert(x[1] == 51 and x[2] == 0 and x[3] == 0 and x[4] == 0, "should choose the closest time constraint")
    x = timetable.getNextConstraint({{0,59,1,0},{1,30,1,30} },60)
    assert(x[1] == 0 and x[2] == 59 and x[3] == 1 and x[4] == 0, "should choose the closest time constraint")
    x = timetable.getNextConstraint({},1200)
    assert(x == nil, "should return nil")
end


timetableTests[#timetableTests + 1] = function()
    timetable.setTimetableObject({})
    local x = timetable.beforeDepature({29,0,30,0}, ((29 * 60) + 30), {{29,0,30,0},{39,0,40,0}})
    assert(x, "should be defore departure")
    x = timetable.beforeDepature({29,0,30,0}, ((24 * 60) + 30), {{29,0,30,0},{39,0,40,0}})
    assert(x, "should be defore departure")
    x = timetable.beforeDepature({29,0,30,0}, ((46 * 60) + 30), {{29,0,30,0},{39,0,40,0}})
    assert(x, "should be defore departure")
    x = timetable.beforeDepature({29,0,30,0}, ((31 * 60) + 30), {{29,0,30,0},{39,0,40,0}})
    assert(not x, "should be after departure")
    x = timetable.beforeDepature({29,0,30,0}, ((34 * 60) + 30), {{29,0,30,0},{39,0,40,0}})
    assert(not x, "should be after departure")
    x = timetable.beforeDepature({45,0,46,0}, ((45 * 60) + 30), {{45,0,46,0},{10,0,11,0}})
    assert(x, "should be defore departure")
    x = timetable.beforeDepature({45,0,46,0}, ((46 * 60) + 30), {{45,0,46,0},{10,0,11,0}})
    assert(not x, "should be after departure")
    x = timetable.beforeDepature({45,0,46,0}, ((1 * 60) + 30), {{45,0,46,0},{10,0,11,0}})
    assert(not x, "should be after departure")
    x = timetable.beforeDepature({45,0,46,0}, ((9 * 60) + 30), {{45,0,46,0},{10,0,11,0}})
    assert(not x, "should be after departure")
    x = timetable.beforeDepature({45,0,46,0}, ((11 * 60) + 30), {{45,0,46,0},{10,0,11,0}})
    assert(x, "should be defore departure")
    x = timetable.beforeDepature({30,0,31,0}, ((29 * 60) ), {{30,0,31,0}})
    assert(x, "should be defore departure")
    x = timetable.beforeDepature({30,0,31,0}, ((31 * 60) + 1 ), {{30,0,31,0}})
    assert(not x, "should be after departure")
    x = timetable.beforeDepature({30,0,31,0}, ((37 * 60) + 1 ), {{30,0,31,0}})
    assert(not x, "should be after departure")
end

timetableTests[#timetableTests + 1] = function()
    timetable.setTimetableObject({})
    local x = timetable.getTimeUntilNextConstraint({29,0,_,_}, {{29,0,_,_},{39,0,_,_}})
    assert(x == 10*60, "time to closest constraint should be 10 min instead of ".. x)
    x = timetable.getTimeUntilNextConstraint({29,30,_,_}, {{29,30,_,_},{30,0,_,_}})
    assert(x == 30, "time to closest constraint should be 30 sec instead of ".. x)
    x = timetable.getTimeUntilNextConstraint({29,30,_,_}, {{29,30,_,_},{30,35,_,_}})
    assert(x == 65, "time to closest constraint should be 65 sec instead of ".. x)
    x = timetable.getTimeUntilNextConstraint({30,00,_,_}, {{30,00,_,_},{25,0,_,_}})
    assert(x == 55*60, "time to closest constraint should be 55 min instead of ".. x)
    x = timetable.getTimeUntilNextConstraint({55,00,_,_}, {{55,00,_,_},{1,0,_,_}})
    assert(x == 6*60, "time to closest constraint should be 55 min instead of ".. x)
    x = timetable.getTimeUntilNextConstraint({55,00,_,_}, {{55,00,_,_},{1,0,_,_},{54,0,_,_}})
    assert(x == 6*60, "time to closest constraint should be 55 min instead of ".. x)
    x = timetable.getTimeUntilNextConstraint({55,00,_,_}, {{55,00,_,_},{1,30,_,_},{1,0,_,_},{54,0,_,_}})
    assert(x == 6*60, "time to closest constraint should be 55 min instead of ".. x)
    x = timetable.getTimeUntilNextConstraint({1,00,_,_}, {{55,00,_,_},{1,0,_,_},{54,0,_,_}})
    assert(x == 53*60, "time to closest constraint should be 55 min instead of ".. x)
    x = timetable.getTimeUntilNextConstraint({1,30,_,_}, {{55,00,_,_},{1,30,_,_},{54,0,_,_}})
    assert(x == 52*60 + 30, "time to closest constraint should be 55 min instead of ".. x)
end

timetableTests[#timetableTests + 1] = function()
    timetable.setTimetableObject({
        ["Line 1"] = { 
            stations = { 
                ["Station 1"] = {
                     conditions = {
                         ArrDep = {
                            {59, 30, 1, 0}
                        }
                    }
                }
            }
        }
    })

    timetable.clonePeriodically("Line 1", "Station 1", 10)
    local x = timetable.getTimetableObject()["Line 1"].stations["Station 1"].conditions.ArrDep
 
    assert(table.concat(x[1], " ")  == "59 30 1 0", "failure to clone with period 10, got " .. table.concat(x[1], " ") )
    assert(table.concat(x[2], " ")  == "9 30 11 0", "failure to clone with period 10, got " .. table.concat(x[2], " ") )
    assert(table.concat(x[6], " ")  == "49 30 51 0", "failure to clone with period 10, got " .. table.concat(x[6], " ") )
    assert(#x == 6, "failure to clone with period 10, got table of length " .. #x )

    timetable.clonePeriodically("Line 1", "Station 1", 15)
    local x = timetable.getTimetableObject()["Line 1"].stations["Station 1"].conditions.ArrDep
    assert(table.concat(x[1], " ")  == "59 30 1 0", "failure to clone with period 15, got " .. table.concat(x[1], " ") )
    assert(table.concat(x[2], " ")  == "9 30 11 0", "failure to clone with period 15, got " .. table.concat(x[2], " ") )
    assert(table.concat(x[3], " ")  == "14 30 16 0", "failure to clone with period 15, got " .. table.concat(x[3], " ") )
    assert(table.concat(x[4], " ")  == "24 30 26 0", "failure to clone with period 15, got " .. table.concat(x[4], " ") )
    assert(table.concat(x[8], " ")  == "54 30 56 0", "failure to clone with period 15, got " .. table.concat(x[8], " ") )
    assert(#x == 8, "failure to clone with period 15, got table of length " .. #x )
end 

return {
    test = function()
        for k,v in pairs(timetableTests) do
            print("Running test: " .. tostring(k))
            v()
        end
    end
}
