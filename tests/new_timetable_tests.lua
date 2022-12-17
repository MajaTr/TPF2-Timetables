package.loaded["celmi/timetables/timetable_helper"] = {}

local ArrDepTimetable = require ".res.scripts.celmi.timetables.arrdep_timetable"

local timetableTests = {}

timetableTests[#timetableTests + 1] = function()
    
    local tests_with_periods = {
        {period = 3600, tests = {
            {0,0,0},
            {5,5,0},
            {59,60,3599},
            {60,59,1},
            {10,5,5},
            {0,5,3595},
            {3300,300,3000},
            {600,2400,1800}
        }}, 
        {period = 10, tests = {
            {9, 0, 9},
            {0, 9, 1},
            {2, 8, 4},
            {2, 7, 5},
            {2, 6, 6},
            {6, 2, 4}
        }}
    }
    local i = 1
    for _,test_with_period in pairs(tests_with_periods) do
        local timetable = ArrDepTimetable:new(test_with_period.period)
        for _,test in pairs(test_with_period.tests) do 
            local x = timetable:timeDiff(test[1], test[2])
            assert(x == test[3], 
                string.format("test %d: Difference between %d and %d in period %d should be %d, got %d", 
                    i, test[1], test[2], test_with_period.period, test[3], x))
            i = i+1
        end
    end 
end


timetableTests[#timetableTests + 1] = function()
    local makeTimetable = function (period, arrdeps) 
        local timetable = ArrDepTimetable:new(period)
        for _, v in pairs(arrdeps) do 
            timetable:addArrDep(v[1], v[2])
        end

        return timetable
    end

    local tests_with_periods = {
        {period = 60, tests = {
            {{{30, 59}, {0, 9}}, 20, 59},
            {{{30, 59}, {0, 11}}, 80, 11},
            {{{30, 59}, {0, 11}}, 58, 59},
            {{{30, 59}, {0, 11}}, 61, 11},
            {{{58, 2}, {3, 4}}, 1, 2},
            {{{1, 2}, {nil, 5}}, 63, 2},
            {{{1, 2}, {nil, 5}}, 4, 5},
        }}, 
        {period = 13, tests = {
            {{}, 5, nil},
            {{{nil,2}}, 5, 2},
            {{{nil,11}, {nil, 3}}, 13, 11},
            {{{nil,11}, {nil, 3}, {nil, 1}}, 0, 1},
            {{{nil,0}, {nil, 3}, {nil, 1}}, 0, 0},
        }}
    }

    local i = 1
    for _,test_with_period in pairs(tests_with_periods) do
        for _,test in pairs(test_with_period.tests) do 
            local timetable = makeTimetable(test_with_period.period, test[1])
            local x = timetable:getDepartureTime(test[2])
            if test[3] then 
                assert(x, string.format("test %d: The departure time should be %d, not nil", i, test[3])) 
                assert(x == test[3], 
                    string.format("test %d: The departure time should be %d, got %d", i, test[3], x))
            else
                assert(x == test[3], string.format("test %d: The departure time should be nil", i)) 
            end 
            i = i+1
        end
    end 
end

return {
    test = function()
        for k,v in pairs(timetableTests) do
            print("Running test: " .. tostring(k))
            v()
        end
    end
}
