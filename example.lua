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
function counterlimit(i, stop)
    i = i - 1
    return function()
        i = i + 1
        if i > stop then return end
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
    return iterator.fromfn(counter):take(n)
        :fold(function(acc, v) return acc*v end, 1)
end
print("Factorial(5)", factorial(5))

print("Take 5 skip 1")
iterator.fromfn(counter(1)):take(5):skip(1):foreach(print)

print("nth(3)", iterator.fromfn(counter(1)):nth(3))

print("Scanfactorial")
iterator.fromfn(counter(1))
        :scan(function(acc, v) return acc*v end, 1)
        :take(5):foreach(print)

-- Benchmark
local iters = 10000000
local tb = os.clock()
print(iterator.fromfn(counter(1)):take(iters):fold(function(acc,v) return acc + 1/v end))
print(string.format("elapsed time (iter): %.2fs\n", os.clock() - tb))
local tb = os.clock()
local acc = 0
for i in counter(1) do
    acc = acc + 1/i 
    if i >= iters then break end 
end
print(acc)
print(string.format("elapsed time (for): %.2fs\n", os.clock() - tb))


print("ZIP")
local itercount = iterator.fromfn(counter(5)):filter(isEven):take(5)
        :zip(iterator.fromfn(counter(-30)))
        :foreach(function(v) print(unpack(v)) end)
-- iterator.fromfn(counter(5)):filter(isEven):map(square):enumerate():foreach(print)
-- local a = {"hello", 3, nil, 42.5, "bye"}
-- local it = iterator.fromarr(a)
-- print(it())
-- print(it())
-- print(it())
-- print(it())
-- print(it())
-- print(it())
