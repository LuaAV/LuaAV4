local concat = table.concat
local format = string.format

-- used by conflat()
-- appends items to the rope
local function conflat_impl(rope, v, sep, ext, first)
	if type(v) == "table" then
		for i, e in ipairs(v) do 
			-- insert appropriate separator:
			if i == 1 then 
				rope[#rope+1] = first 
			else
				rope[#rope+1] = sep 
			end
			-- recurse to insert the value:
			conflat_impl(rope, e, sep and sep .. ext, ext, ext)
		end
	elseif type(v) == "function" then
		conflat_impl(rope, v(), sep, ext, first)
	elseif v ~= "nil" then
		rope[#rope+1] = tostring(v)
	end
end

--- Return a string concatenation of all elements in v
-- Similar to table.concat, however conflat also recurses to all nested tables
-- and calls tostring() on all non-table values
-- Any nested functions will also be invoked, and conflat called on their results.
-- @param v the item to concat (e.g. a list)
-- @sep a separator character between items (optional)
-- @ext an extension to the separator applied for nested sublists (optional)
-- @return string
local function conflat(v, sep, ext)
	local rope = {}
	conflat_impl(rope, v, sep, ext)
	return concat(rope)
end


--- Generate a template-filling function based on a template string
-- The template source can contain various template substitution items, indicated by the "$" character followed by a valid Lua variable name, e.g. "$foo", "$_x1", etc. 
-- A template item can optionally be terminated using "{}", in order to distinguish the item name from plain text. E.g. "$foo{}plain" defines the item "foo" followed by the string "plain".  
-- The returned function takes a Lua table as an argument. All substitution item names index corresponding fields in this table to find their data. If the data value is a table, util.conflat() is used to convert this to a string.
-- If a template item is preceded by a newline and whitespace, the newline and whitespace are repeated for all items substituted (via the argument to conflat()).
-- @param source string template source
-- @return function to apply a model
local function template(source)
	return function(dict)
		-- ugh. the pattern grabs:
		-- (optional newline)(optional whitespace)$(varname)optional{}
		return (source:gsub("([\n]*)([ \t]*)%$([%a_][%w_]*)[{}]*", function(nl, ext, name)
			local sep = nl .. ext	-- put back what we took out
			-- automatic indentation only happens if newline is found:
			if #nl > 0 then
				return sep .. conflat(dict[name], sep, ext)
			else
				return sep .. conflat(dict[name])
			end
		end))
	end
end

return template