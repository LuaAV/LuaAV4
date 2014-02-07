local draw2D = require "draw2D"
local vec2 = require "vec2"

win = Window()

-- start pattern:
local str = "F"

-- production rules:
local rules = {
	F = "F+F--F+F",
}

-- apply production rules:
function apply_production_rules(s)
	local res = {}
	for i = 1, #s do
		local c = s:sub(i, i)
		if rules[c] then
			res[#res+1] = rules[c]
		else
			res[#res+1] = c
		end
	end
	s = table.concat(res)
	print(s)
	return s
end

-- turtle graphics:
local startpos = vec2(0.1, 0.1)
local startdir = vec2(0.01, 0)

function turtle_new()
	return {
		p = startpos,
		d = startdir,
		a = math.pi / 3,
	}
end

function turtle_copy(t)
	return {
		p = t.p:copy(),
		d = t.d:copy(),
		a = t.a * 2/3,
	}
end

function drawturtle(t, str)
	local i = 1
	while i <= #str do
		local c = str:sub(i, i)
		if c == "F" then
			-- move & draw turtle:
			local p2 = t.p + t.d
			draw2D.line(t.p.x, t.p.y, p2.x, p2.y)
			t.p = p2
		elseif c == "+" then
			-- turn turtle:
			t.d:rotate( t.a)
		elseif c == "-" then
			-- turn turtle:
			t.d:rotate(-t.a)
		-- push/pop machine:
		elseif c == "[" then
			-- create a copy of the turtle:
			local turtle1 = turtle_copy(t)
			local str1 = str:sub(i+1)
			i = i + drawturtle(turtle1, str1)
		elseif c == "]" then
			return i
		end
		i = i + 1
	end
	return i
end

function draw()
	-- reset turtle:
	local turtle = turtle_new()
	-- and draw it:
	drawturtle(turtle, str)
end


function key(e, k)
	if e == "down" then
		str = apply_production_rules(str)
	end
end
