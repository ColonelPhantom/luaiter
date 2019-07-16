local unpack = table.unpack or unpack

iterator = {}

function iterator.wrap(...)
    return select('#', ...) == 0, {...}
end
function iterator.wrapfactory(fn)
    return function() return iterator.wrap(fn()) end
end
function iterator.unwrap(fn)
    local eoi, t = fn()
    if eoi then return else return unpack(t) end
end
function iterator.unwrapfactory(fn)
    return function() return iterator.unwrap(fn) end
end
function iterator.fromwrapped(wfn)
    return setmetatable({__iterfn = wfn}, {__call = iterator.unwrapfactory(wfn), __index = iterator})
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
function iterator.nextraw(iter)
    return iter.__iterfn()
end

function iterator.map(iter, mapfn)
    function iterfn()
        local eoi, t = iter:nextraw()
        if eoi then 
            return true, {}
        else
            return false, {mapfn(unpack(t))}
        end
    end
    return iterator.fromwrapped(iterfn)
end
function iterator.filter(iter, filterfn)
    function iterfn()
        local eoi, t
        repeat
            eoi, t = iter:nextraw()
            if eoi then return true, {} end
        until filterfn(unpack(t))
        return false, t
    end
    return iterator.fromwrapped(iterfn)
end
function iterator.collect(iter)
    local tbl = {}
    while true do
        local eoi, t = iter:nextraw()

        if eoi then return tbl end

        if #t <= 1 then table.insert(tbl, unpack(t))
        else table.insert(tbl, t)
        end
    end
end
function iterator.foreach(iter, fn)
    local eoi, t, fnval
    while true do
        eoi, t = iter:nextraw()
        if eoi then return fnval
        else fnval = fn(unpack(t))
        end
    end
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
        if eoi1 then return true, {} end
        local eoi2, t2 = iter2:nextraw()
        if eoi2 then return true, {} end
        iterator.fromarr(t2):foreach(function(val) table.insert(t1, val) end)
        return false, t1
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