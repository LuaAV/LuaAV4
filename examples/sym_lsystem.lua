local draw2D = require "draw2D"
local vec2 = require "vec2"

win = Window(nil, 400, 400)

-- alphabet:
-- F: forward drawing a line
-- J: jump forward (without drawing)
-- c, a: turn clockwise/anticlockwise
-- [ ] : push / pop the turtle


function apply_productions(str, rules)
	-- create a string to collect the result:
	local result = ""
	for i = 1, #str do
		local c = string.sub(str, i, i)
		-- find the rule for c:
		local rule = rules[c]
		-- if no rule found, pass-through:
		if rule == nil then
			rule = c
		end
		-- accumulate transformation to result:
		result = result .. rule
	end
	return result -- newly rewritten string
end

-- production rules:
local P = {
	F = "F[FF[cFF]F[aFF]]F",
}

-- start symbol (axiom):
local S = "F"

local rotation_angle = math.pi / 4

function turtle_interpret(str, pos, vel)
	--print("begin interpreting", str)
	local i = 1
	
	local r = (math.random() - 0.5) * 0.1
	
	while i <= #str do
	--for i = 1, #str do
		local c = string.sub(str, i, i)
		if c == "J" then
			pos = pos + vel
		elseif c == "F" then
			-- move forward:
			local newpos = pos + vel
			-- draw as we go:
			draw2D.line(pos.x, pos.y, newpos.x, newpos.y)
			-- update position:
			pos = newpos			
		elseif c == "c" then
			vel:rotate(-rotation_angle +r)
		elseif c == "a" then
			vel:rotate( rotation_angle +r)
		elseif c == "[" then
			-- push turtle:
			local newstr = string.sub(str, i+1, #str)
			i = i + turtle_interpret(newstr, pos:copy(), vel:copy() * 0.9)
			
		elseif c == "]" then
			-- pop turtle:			
			return i
		end
		i = i + 1
	end
end

function draw()
	-- turtle state:
	local pos = vec2(0.5, 0.)
	local vel = vec2(0.0, 0.01)	-- AKA direction
	
	draw2D.color(1, 1, 1)
	turtle_interpret(S, pos, vel)
end

function key(e, k)
	if k == "a" then
		S = apply_productions(S, P)
		--print(S)
	end
end

function mouse(e, b, x, y)
	--rotation_angle = x
end