iterator = {}

table.unpack = table.unpack or unpack

-- Utility functions
function iterator.wrap(...)
    return select('#', ...) == 0, ...
end
function iterator.wrapfactory(fn)
    return function() return iterator.wrap(fn()) end
end
function iterator.unwrap(fn)
    local eoi, t = fn()
    if eoi then return else return t end
end
function iterator.unwrapfactory(fn)
    return function() return iterator.unwrap(fn) end
end

-- Constructors
function iterator.fromwrapped(wfn)
    return setmetatable({nextraw = wfn}, {__call = iterator.unwrapfactory(wfn), __index = iterator})
end
function iterator.fromfn(fn)
    return iterator.fromwrapped(iterator.wrapfactory(fn))
end
function iterator.frompairs(fn, t, key)
    local iterfn = function()
        if t == nil then return end 
        local i,v = fn(t, key)
        key = i
        if key == nil then
            t = nil
            return
        end
        return v
    end
    return iterator.fromfn(iterfn)
end
function iterator.fromtbl(t)
    return iterator.frompairs(pairs(t))
end
function iterator.fromarr(t)
    local arrnext = function(t,i)
        i = i + 1
        local v = t[i]
        if i <= #t or v ~= nil then
            return i,v
        end
    end
    return iterator.frompairs(arrnext, t, 0)
end

-- Utility functions
function iterator.map(iter, mapfn)
    local function iterfn()
        local eoi, t = iter:nextraw()
        if eoi then 
            return true, {}
        else
            return false, mapfn(t)
        end
    end
    return iterator.fromwrapped(iterfn)
end
function iterator.filter(iter, filterfn)
    local function iterfn()
        local eoi, t
        repeat
            eoi, t = iter:nextraw()
            if eoi then return true, {} end
        until filterfn(t)
        return false, t
    end
    return iterator.fromwrapped(iterfn)
end
function iterator.collect(iter)
    local tbl = {}
    while true do
        local eoi, t = iter:nextraw()
        if eoi then return tbl end
        table.insert(tbl, t)
    end
end
function iterator.foreach(iter, fn)
    local eoi, t, fnval
    while true do
        eoi, t = iter:nextraw()
        if eoi then return fnval
        else fnval = fn(t)
        end
    end
end
function iterator.fold(iter, fn, acc)
    local eoi, t
    acc = acc or 0
    while true do
        eoi, t = iter:nextraw()
        if eoi then return acc
        else acc = fn(acc, t)
        end
    end
end
function iterator.scan(iter, fn, acc)
    acc = acc or 0
    return iter:map(function(...)
        acc = fn(acc, ...)
        return acc
    end)
end
function iterator.enumerate(iter)
    local i = 0
    local counter = function()
        i = i + 1
        return i
    end
    return iterator.fromfn(counter):zip(iter)
end
function iterator.zip(iter1, iter2)
    local function zipfn()
        local eoi1, t1 = iter1:nextraw()
        if eoi1 then return true, nil end
        local eoi2, t2 = iter2:nextraw()
        if eoi2 then return true, nil end
        return false, {t1, t2}
    end
    return iterator.fromwrapped(zipfn)
end
function iterator.chain(iter1, iter2)
    local eoi = false
    local function chainfn()
        if not eoi then
            eoi1, t1 = iter1:nextraw()
            if eoi1 then eoi = true else return false, t1 end
        end
        return iter2:nextraw()
    end
    return iterator.fromwrapped(chainfn)
end
function iterator.take(iter, count)
    local function takefn()
        if count <= 0 then return true, {} end
        count = count - 1
        return iter:nextraw()
    end
    return iterator.fromwrapped(takefn)
end
function iterator.skip(iter, count)
    for i=1,count do
        iter()
    end
    return iter
end
function iterator.nth(iter, count)
    for i = 1,count - 1 do
        iter()
    end
    return iter()
end