-- parse Lua code:

-- import the fellas
local lpeg = require 'lpeg'

-- aliasing...
local Cs, V, P = lpeg.Cs, lpeg.V, lpeg.P
local S = lpeg.S

local keywords = {
	["and"]=true,       ["break"]=true,     ["do"]=true,        ["else"]=true,      ["elseif"]=true, 
	["end"]=true,       ["false"]=true,     ["for"]=true,       ["function"]=true,  ["if"]=true, 
	["in"]=true,        ["local"]=true,     ["nil"]=true,       ["not"]=true,       ["or"]=true, 
	["repeat"]=true,    ["return"]=true,    ["then"]=true,      ["true"]=true,      ["until"]=true,     ["while"]=true,
}
	
local symbols =
	P"+"+      P"-"+      P"*"+      P"/"+      P"%"+      P"^"+      P"#"+ 
	P"=="+     P"~="+     P"<="+     P">="+     P"<"+      P">"+      P"="+ 
	P"("+      P")"+      P"{"+      P"}"+      P"P"+      P"]"+ 
	P";"+      P":"+      P"+ "+      P"..."+      P".."+     P"."

function err (msg)
	return function (subject, i)
			local line = lines(string.sub(subject,1,i))
			error('Lexical error in line '..line..', near "'
				..(subject:sub(i-10,i)):gsub('\n','EOL')..'": '..msg, 0)
	end
end

-- LONG BRACKETS
local long_brackets = #(P'[' * P'='^0 * P'[') * function (subject, i1)
		local level = _G.assert( subject:match('^%[(=*)%[', i1) )
		local _, i2 = subject:find(']'..level..']', i1, true)  -- true = plain "find substring"
		return (i2 and (i2+1)) or error('unfinished long brackets')(subject, i1)
end
local multi  = P'--' * long_brackets
local single = P'--' * (1 - P'\n')^0
local doc = P'---' * (1 - P'\n')^0

local AZ = lpeg.R('__','az','AZ','\127\255') 
local N = lpeg.R'09'

local Str1 = P'"' * ( (P'\\' * 1) + (1 - (S'"\n\r\f')) )^0 * (P'"' + err'unfinished string')
local Str2 = P"'" * ( (P'\\' * 1) + (1 - (S"'\n\r\f")) )^0 * (P"'" + err'unfinished string')
local Str3 = P"[[" * (1 - P"]]")^0 * P"]]"

local int = N^1
local float = (N^1 * P'.' * N^0) 
			+ (P'.' * N^1)
local num = float + int
local hex = P'0x' * int
local exp = num * S'eE' * S'+-'^-1 * N^1
local number = hex + exp + num
-- TODO: support for hex constants etc.

local SYMBOL = (symbols)
local NUMBER = (#(N + (P'.' * N)) * number)
local IDENTIFIER = (AZ * (AZ+N+".")^0)
local STRING = (Str1 + Str2 + Str3)
local DOC = doc
local COMMENT = (multi + single)
local BANG = (P'#!' * (P(1)-'\n')^0 * '\n')


local function sub(handlers)

	local TERM = COMMENT / handlers.COMMENT
				+ STRING / handlers.STRING
				+ SYMBOL / handlers.SYMBOL
				+ NUMBER / handlers.NUMBER
				+ IDENTIFIER / handlers.IDENTIFIER
				+ BANG / handlers.BANG
	
	local patt = lpeg.Cs((TERM + lpeg.C(1))^0) --Cs( (COMMENT + STRING + ID + NUMBER + KEYWORD + 1)^0 )

	return function(subject)
		return patt:match(subject)
	end
end

return {
	keywords = keywords,
	symbols = symbols,
	
	sub = sub,
}