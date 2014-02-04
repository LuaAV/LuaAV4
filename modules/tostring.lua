local old_tostring = tostring
local concat = table.concat
local format = string.format
local floor = math.floor
local table_tostring
local keywords = {
	["and"] = true,       
	["break"] = true,     
	["do"] = true,        
	["else"] = true,      
	["elseif"] = true,
    ["end"] = true,       
    ["false"] = true,     
    ["for"] = true,       
    ["function"] = true,  
    ["if"] = true,
    ["in"] = true,        
    ["local"] = true,     
    ["nil"] = true,       
    ["not"] = true,       
    ["or"] = true,
    ["repeat"] = true,    
    ["return"] = true,    
    ["then"] = true,      
    ["true"] = true,      
    ["until"] = true,     
    ["while"] = true,
}

local varpat = "^[%a_][%w_]*$"
local function isvalidluavariablename(k)
	return type(k) == "string" and (k:match("^[%a_][%w_]*$") ~= nil) and not keywords[k]
end

local function isinteger(n)
	return type(n) == "number" and n == floor(n)
end


local function dict_keylist_sorter(a, b)
	local ta,tb = type(a), type(b)
	if ta == tb then
		return a < b
	else 
		return ta > tb
	end
end


local function dict_keylist_only(t, n)
	local res = {}
	for k, v in pairs(t) do
		-- skip if k is an integer from 1..n (array portion)
		if not (isinteger(k) and k > 0 and k < n) then
			res[#res+1] = k
		end
	end
	table.sort(res, dict_keylist_sorter)
	return res
end

local function dict_keylist(t)
	local res = {}
	for k, v in pairs(t) do
		res[#res+1] = k
	end
	table.sort(res, dict_keylist_sorter)
	return res
end

local function dict_keystr(k, ind)
	if isvalidluavariablename(k) then	
		return k
	elseif isinteger(k) then
		return format("%d", k)
	else
		return format("[%q]", k)
	end
end	

local function dict_valstr(v, ind, memo)
	if type(v) == "string" then	-- TODO: and no invalid chars!
		return format("%q", v)
	elseif type(v) == "table" then
		return table_tostring(v, ind, memo)
	else
		return old_tostring(v)
	end
end	

local function list_tostring(t, ind, ind1)
	
end

-- TODO: handle multiple references without error (but not recursion)
-- TODO: handle recursion without error
-- TODO: handle functions, etc.

table_tostring = function(t, ind, memo)
	if type(t) == "table" then
		-- memoization to trap multiple refs/recursion
		if memo[t] then 
			error("multiple references not supported") 
		end
		memo[t] = true
		-- build up the result list:
		local len = #ind
		local res = {}
		-- grab the array portion:
		for i, v in ipairs(t) do
			local s = table_tostring(v, ind, memo)
			res[i] = s
			len = len + #s + 2
		end
		local n = #res
		if n > 8 then
			-- too many to make sense of as a simple list;
			-- prefix them with index numbers:
			for i = 1, n do
				res[i] = format("[%d]=%s", i, res[i])
			end
			-- force the table to be printed multi-line:
			len = math.huge		
		end
		-- grab the dict portion:
		local keys = dict_keylist_only(t, n)
		local dres = {}
		local dlen = 0
		for i, k in ipairs(keys) do
			local s = format("%s=%s",
				dict_keystr(k, ind1),
				dict_valstr(t[k], ind1, memo)
			)
			res[#res+1] = s
			len = len + #s + 2
		end
		-- format as string:
		local ind1 = ind .. "  "
		local sep
		local pre, post
		-- print short tables on one line:
		if len > 64 then
			return format("{\n%s%s\n%s}", ind1, concat(res, ",\n"..ind1), ind)
		else
			return format("{ %s }", concat(res, ", "))
		end
		return format("{%s%s%s}", pre, concat(res, sep), post)
	else
		return old_tostring(t)
	end	
end

--- Return a pretty-formatted string representation of a table
-- Array portion is printed after dict portion.
-- Keys are sorted alphanumerically.
-- Could also be used as a replacement of the global tostring()
-- @param t the value (e.g. table) to print
-- @return string
local function tostring(t)
	return table_tostring(t, "", {})
end

return tostring