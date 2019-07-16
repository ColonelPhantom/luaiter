require "iterator"

function square(i)
    return i*i
end
function isEven(i)
    return i % 2 == 0
end

function printret(...)
    print(...)
    return ...
end

function counter(i)
    i = i - 1
    return function()
        i = i + 1
        return i
    end
end

function accumulator(start)
    start = start or 0
    return function(v)
        start = start + v
        return start
    end
end

-- local iterator1 = iterator.fromfn(counter(-1)):take(2)
-- iterator1:foreach(print)

function factorial(n)
    local i = 0
    local counter = function()
        i = i + 1
        return i
    end
    local result = 1
    return iterator.fromfn(function() i=i+1 return i end):take(n)
        :foreach(function(v) result = v * result return result end)
end
print(factorial(5))

-- local itercount = iterator.fromfn(counter(5)):filter(isEven)
--         :zip(iterator.fromfn(counter(-30)))
--         :foreach(print)
-- iterator.fromfn(counter(5)):filter(isEven):map(square):enumerate():foreach(print)
-- local a = {"hello", 3, nil, 42.5, "bye"}
-- local it = iterator.fromarr(a)
-- print(it())
-- print(it())
-- print(it())
-- print(it())
-- print(it())
-- print(it())
