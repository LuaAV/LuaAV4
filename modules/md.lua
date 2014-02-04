
local format = string.format

-- sudo luarocks install lunamark
-- http://jggithub.io/lunamark/doc/
local lunamark = require "lunamark"

-- sudo luarocks install lua-discount
-- http://asbradbury.org/projects/lua-discount/
local discount = require("discount")

local markdown = require "markdown"


-- a map of variable names to their documentation URLs:
local docurl = require "docurl"

local luaparser = require "luaparser"

-- replace non-alphanum chars with underscore:
local function safe(name)	
	return name:lower():gsub("[^%w]", "_")
end

local lua2md = luaparser.sub({
	SYMBOL = function (c) 
		return '<span class="symbol">'..c..'</span>'
	end,

	NUMBER = function (c) 
		return '<span class="number">'..c..'</span>'
	end,

	IDENTIFIER = function (c) 
		if luaparser.keywords[c] then
			return '<span class="keyword">'..c..'</span>'
		elseif docurl[c] then
			return '<span class="global"><a href="'..docurl[c]..'" target="_blank">'..c..'</a></span>'
		else
			return '<span class="identifier">'..c..'</span>'
		end
	end,

	STRING = function (c) 
		return '<span class="string">'..c..'</span>'
	end,
	
	COMMENT =  function (c) 
		return '<span class="comment">'..c..'</span>'
	end,

	BANG = function (c) 
		return '<span class="bang">'..c..'</span>'
	end,
})

local function formatcode(lang, subject)
	if subject then
		return "<pre>"..lua2md(subject).."</pre>"
	else
		return lua2md(lang)
	end
end

local function precode(str)
	str = str:gsub("```(%w*)\n([^`]+)```", formatcode) 
	str = str:gsub("```([^`]+)```", formatcode) 
	return str
end

return function(str)
	-- DOESN'T SUPPORT MANY COMMON MD EXTENSIONS
	--return markdown(str)
	
	local links = {}
	
	-- insert <a name> links for all titles:
	str = str:gsub("\n(#+)%s*([^\n]+)", function(h, title)
		local aname = safe(title)
		local res = format('\n%s <a name="%s"></a>%s', 
			h, aname, title)
		-- append to list of links in this page
		links[#links+1] = {
			aname = aname,
			title = title,
		}
		return res
	end)
	
	-- parse github-style ```<lang>  ``` sections:
	str = str:gsub("```(%w*)\n([^`]+)```", formatcode) 
	-- and then inline ```code``` sections:
	str = str:gsub("```([^`]+)```", formatcode) 
	
	return discount(str), links
	
	--[[
	-- CURRENTLY BROKEN BECAUSE COSMO GRAMMAR DOESN'T WORK
	local opts = {}
	local writer = lunamark.writer.html.new(opts)
	local parse = lunamark.reader.markdown.new(writer, opts)
	return parse(str)
	--]]
end	