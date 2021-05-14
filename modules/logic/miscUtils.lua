miscUtils = {}

function miscUtils.deepcopy(origin)
	local orig_type = type(origin)
    local copy
    if orig_type == 'table' then
        copy = {}
        for origin_key, origin_value in next, origin, nil do
            copy[miscUtils.deepcopy(origin_key)] = miscUtils.deepcopy(origin_value)
        end
        setmetatable(copy, miscUtils.deepcopy(getmetatable(origin)))
    else
        copy = origin
    end
    return copy
end

function miscUtils.deepestCopy(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[miscUtils.deepestCopy(k, s)] = miscUtils.deepestCopy(v, s) end
    return res
  end

function miscUtils.indexValue(table, value)
    local index={}
    for k,v in pairs(table) do
        index[v]=k
    end
    return index[value]
end

function miscUtils.has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function miscUtils.getIndex(tab, val)
    local index = nil
    for i, v in ipairs(tab) do
		if v == val then
			index = i
		end
    end
    return index
end

function miscUtils.removeItem(tab, val)
    table.remove(tab, miscUtils.getIndex(tab, val))
end

function miscUtils.getLength(tab)
    local count = 0
    for _ in pairs(tab) do 
        count = count + 1 
    end
    return count
end

return miscUtils