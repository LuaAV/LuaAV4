local draw2D = require "draw2D"
local vec2 = require "vec2"

win = Window(nil, 800, 200)

math.randomseed(os.time())


local alphabet = {
	"F", -- "F" means move forward drawing a line
	"F",
	"+", -- "+" means turn clockwise
	"-", -- "-" means turn anticlockwise
	"S", -- rotate with sine oscillator
	"C", -- rotate with cosine oscillator (double freq)
	"|", -- mirror symmetry
	"*", -- scaling up
	"/", -- scaling down
	"[", -- start branch
	"]", -- end branch
}

local genome_size = 60
local genome_range = #alphabet
local population_size = 8
local mutation_rate = 0.01
local t = 0

function genome_make()
	local g = {}
	for i = 1, genome_size do
		g[i] = math.random(genome_range)
	end
	return g
end

function develop(geno)
	local pheno = {
		geno = geno,
		fitness = 0,
	}
	local body = ""
	for i, g in ipairs(geno) do
		body = body .. alphabet[g]
	end
	pheno.body = body
	print(body)
	return pheno
end

local pop = {}
function reset_population()
	for i = 1, population_size do
		local geno = genome_make()
		pop[i] = develop(geno)
	end
end
reset_population()

function regenerate()
	table.sort(pop, function(a, b)
		return a.fitness > b.fitness
	end)	
	
	local newpop = {}
	for i = 1, population_size do
		local child = {}
		local parent = pop[math.random(i)]
	
		for j, gene in ipairs(parent.geno) do
			if math.random() < mutation_rate * i then
				gene = math.random(genome_range)
			end
			child[j] = gene
		end
		
		newpop[i] = develop(child)
	end
	pop = newpop
end


function turtle_interpret(body)
	--print(body)
	local pushes = 0
	local rotate_angle = math.pi/10
	for i = 1, #body do
		local c = body:sub(i, i)
		if c == "F" then
			draw2D.line(0, 0, 1, 0)
			draw2D.translate(1, 0)
		elseif c == "+" then
			draw2D.rotate(rotate_angle)		
		elseif c == "-" then
			draw2D.rotate(-rotate_angle)
		elseif c == "S" then
			draw2D.rotate(rotate_angle * math.sin(t * 0.1))
		elseif c == "C" then
			draw2D.rotate(rotate_angle * math.cos(t * 0.2))
		elseif c == "*" then
			draw2D.scale(1.5)
		elseif c == "/" then
			draw2D.scale(0.5)
		elseif c == "[" then
			draw2D.push()
			pushes = pushes + 1
		elseif c == "]" then
			if pushes > 0 then
				draw2D.pop()
				pushes = pushes - 1
			end
		elseif c == "|" then
			-- mirror around Y axis
			-- draw rest of string twice
			-- (one of them is mirrored)
			draw2D.push()
			draw2D.scale(1, -1)
			turtle_interpret(body:sub(i+1, #body))
			draw2D.pop()
		else
			--print("WTF")
		end
	end
	for i = 1, pushes do
		draw2D.pop()
	end
end

function draw()
	t = t + 1
	for i, pheno in ipairs(pop) do
		local offset = (i-0.5) / #pop
		draw2D.push()
			draw2D.color(1, pheno.fitness, 0)
			draw2D.translate(offset, 0.1)
			draw2D.rotate(math.pi/2)
			draw2D.scale(0.02, 0.01)
			turtle_interpret(pheno.body)
		draw2D.pop()
	end
end

function mouse(event, button, x, y)
	local choice = math.ceil(x/win.width*8)
	local pheno = pop[choice]
	if pheno then
		if event == "down" then
			pheno.fitness = pheno.fitness + 0.25
		end
	end
	-- 
end

function key(e, k)
	if k == "r" then
		reset_population()
	elseif k == "g" then
		regenerate()
	end	
end


