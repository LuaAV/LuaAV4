local field2D = require "field2D"
win = Window("GP")
local dimx, dimy = 200, 150
local image = field2D(dimx, dimy)

math.randomseed(os.time())

-- set of basic operators:

-- leaf ops:
local nilary = {
	"x", "y", "rand",
}

-- monadic
local monadic = {
	"log", "sin", "cos", "sqrt", "sqr", "exp", "neg", 
}

-- diadic
local diadic = {
	"rand2", "mod", "pow", "avg", "min", "max", "add", "sub", "mul", "div",
}

function operate(op, a, b, x, y)
	-- nilary:
	if op == "x" then	
		return x
	elseif op == "y" then
		return y
	elseif op == "rand" then
		return math.random()
	-- monadic
	elseif op == "log" then
		return math.log(math.abs(a))
	elseif op == "sin" then
		return math.sin(a)
	elseif op == "cos" then
		return math.cos(a)
	elseif op == "sqrt" then
		return math.sqrt(math.abs(a))
	elseif op == "sqr" then
		return a * a
	elseif op == "exp" then
		return math.exp(a)
	elseif op == "neg" then
		return -a
	-- diadic
	elseif op == "add" then
		return a + b
	elseif op == "sub" then
		return a - b
	elseif op == "mul" then
		return a * b
	elseif op == "div" then
		if b == 0 then 
			return 0 
		else
			return a / b
		end
	elseif op == "pow" then
		return math.pow(a, b)
	elseif op == "min" then
		return math.min(a, b)
	elseif op == "max" then
		return math.max(a, b)
	elseif op == "avg" then
		return (a + b) / 2
	elseif op == "mod" then
		return a % b
	elseif op == "rand2" then
		return math.random(a, b)
	end
end

function tree(depth)
	if depth > 2 then
		return {
			op = diadic[math.random(#diadic)],
			tree(depth-1),
			tree(depth-2),
		}
	elseif depth > 1 then
		return {
			op = monadic[math.random(#monadic)],
			tree(depth-1),
		}
	else
		-- leaf node:
		local choice = math.random(3)
		if choice == 1 then 
			return { op = "x" }
		elseif choice == 2 then 
			return { op = "y" }
		else
			return math.random()
		end
	end	
end

function eval(t, x, y)
	if type(t) == "table" then
		local op = t.op
		local a = eval(t[1], x, y)
		local b = eval(t[2], x, y)
		return operate(op, a, b, x, y)
	else
		return t
	end
end

local t = tree(6)
image:set(render)

function render(x, y)
	return eval(t, x/dimx, y/dimy) % 1
end

function key(e, k)
	t = tree(6)
	--print(util.table_tostring(t))
	image:set(render)
end

function draw()
	image:draw()
end

