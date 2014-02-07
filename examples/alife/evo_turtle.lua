local draw2D = require "draw2D"
local vec2 = require "vec2"

math.randomseed(os.time())

win = Window(nil, 800, 400)

-- alphabet:
-- F: forward drawing a line
-- J: jump forward (without drawing)
-- +, -: turn clockwise/anticlockwise
-- [ ] : push / pop the turtle
-- *, /: change scale
-- |: mirror
-- t, s: sin/cos

local cmds = {
	"F", "+", "-", "[", "]", "*", "/", "|", "t", "s",
}

local genome_range = #cmds
local genome_size = 60
local shuffle_rate = 0.02
local mutation_rate = 0.1 / genome_size
local popsize = 8
local t = 0

function genome_make()
	local g = {}
	for i = 1, genome_size do
		g[i] = math.random(genome_range)
	end
	return g
end

function develop(geno)
	local p = {}
	for i, g in ipairs(geno) do
		p[i] = cmds[g]
	end
	return {
		geno = geno,
		str = table.concat(p),
		fitness = 0,
	}
end


local pop = {}
function reset()
	for i = 1, popsize do
		local geno = genome_make()
		pop[i] = develop(geno)
	end
end
reset()

function turtle_interpret(str)
	local len = #str
	local stack = 1
	local angle = math.pi/8
	local scalar = 1.5
	
	for i = 1, len do
		local c = str:sub(i, i)
		if c == "F" then	
			draw2D.line(0, 0, 1, 0)
			draw2D.translate(1, 0)
		elseif c == "-" then
			draw2D.rotate(-angle)
		elseif c == "+" then
			draw2D.rotate(angle)
		elseif c == "t" then
			draw2D.rotate(angle * math.sin(t * 0.01))
		elseif c == "c" then
			draw2D.rotate(angle * math.cos(t * 0.01))
		elseif c == "*" then
			draw2D.scale(scalar)
		elseif c == "/" then
			draw2D.scale(1/scalar)
		elseif c == "[" then
			draw2D.push()
			stack = stack + 1
		elseif c == "]" then
			if stack > 1 then
				draw2D.pop()
				stack = stack - 1
			end
		elseif c == "|" then
			draw2D.push()
			turtle_interpret(str:sub(i+1))
			draw2D.pop()
			draw2D.scale(1, -1)
		end
	end
	-- pop any leftover stack:
	while stack > 1 do
		draw2D.pop()
		stack = stack - 1
	end
end

local selected = nil

function mouse(e, b, x, y)
	local choice = math.ceil(x/win.width * #pop)
	selected = pop[choice]
	if selected then
		if e == "down" then
			selected.fitness = selected.fitness + 0.2
		else
			selected.fitness = selected.fitness + 0.02
		end
	end
end

function regenerate()

	table.sort(pop, function(a, b)
		return a.fitness > b.fitness
	end)

	local newpop = {}
	for i, pheno in ipairs(pop) do
		local child = {}
		local mum = pop[math.random(i)]
		local dad = pop[math.random(#pop)]
		local xover = math.random(genome_size)
		
		for j = 1, xover do
			child[j] = mum.geno[j]
		end
		for j = xover+1, genome_size do
			child[j] = dad.geno[j]
		end
		
		-- mutate:
		for j, gene in ipairs(child) do
			if math.random() < mutation_rate * i then
				child[j] = math.random(genome_range)
			end
		end
		
		-- copy error:
		if math.random() < mutation_rate * i then
			local shuffled = {}
			local shift = math.random(genome_size)
			for j, g in ipairs(child) do
				shuffled[j] = child[((j + shift) % genome_size) + 1]
			end 
			child = shuffled
		end
		
		newpop[i] = develop(child)
	end
	pop = newpop
end

function key(e, k)
	if k == "r" then
		reset()
	else
		regenerate()
	end
end

function draw()
	t = t + 1
	local popsize = #pop
	local popstep = 1/popsize	
	for i, pheno in ipairs(pop) do
		draw2D.push()
			draw2D.translate((i-0.5)/popsize, 0.1)
			draw2D.scale(1/50)
			
			if pheno == selected then
				draw2D.color(1, pheno.fitness, 1)
			else
				draw2D.color(0.5, pheno.fitness, 0)
			end
			
			draw2D.rotate(math.pi/2)
			turtle_interpret(pheno.str)
		draw2D.pop()
	end
end