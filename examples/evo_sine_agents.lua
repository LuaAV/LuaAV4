win = Window()

-- create a population:
-- count is population size
-- len is the number of genes
-- range is the number of possible gene values
function pop_make(count, len, range)
	local pop = {}
	for i = 1, count do
		local g = {}
		for i = 1, len do
			g[i] = math.random(range)
		end
		-- an as-yet-undeveloped invidual:
		-- only has genotype information
		pop[i] = {
			geno = g,
		}	
	end
	return pop
end

function pop_print(pop)
	for i, p in ipairs(pop) do
		print(i, table.concat(p.geno, ","), p.fitness)
	end	
end

-- develop is a function to fill a phenotype according to the genotype
function pop_develop(pop, develop)	
	-- develop the population:
	for i, p in ipairs(pop) do
		develop(p, p.geno)	
	end
end

-- evaluate is a function mapping phenotype to fitness score
function pop_evaluate(pop, evaluate)	
	-- assign fitness scores:
	for i, p in ipairs(pop) do
		p.fitness = evaluate(p)
	end
end

-- mutation rate is chance of a gene mutating
-- mutation size is the amount it can change by
-- genome range is the number of valid gene values
function pop_generate(pop, mutation_rate, mutation_size, genome_size, genome_range)	
	-- sort population by fitness:
	table.sort(pop, function(a, b)
		return a.fitness > b.fitness
	end)
	
	pop_print(pop)
	print("best fitness:", pop[1].fitness)
	
	-- reproduce
	local newpop = {}
	for i, p in ipairs(pop) do
		local child = {}
		local parent1 = pop[math.random(i)].geno
		local parent2 = pop[math.random(i)].geno
		
		-- inherit
		local cross = math.random(genome_size)
		for j = 1, cross do
			child[j] = parent1[j]
		end
		for j = cross, genome_size do
			child[j] = parent2[j]
		end	
		
		for j, gene in ipairs(child) do
			if math.random() < mutation_rate then
				gene = gene + math.random(mutation_size * 2 + 1) - mutation_size
				gene = ((gene - 1) % genome_range) + 1
			end
			child[j] = gene
		end
		
		newpop[i] = {
			geno = child,
		}
	end
	return newpop
end

--------------------------------------------------------------------------------
local vec2 = require "vec2"
local draw2D = require "draw2D"

local goal = vec2(0.75, 0.75)

local population_size = 100
local lifespan = 100

local genome_size = 24
local genome_range = 999

local mutation_rate = 0.1 / genome_size
local mutation_size = math.ceil(genome_range / 10)

function develop(p, g)
	-- everybody starts at the same condition:
	p.pos = vec2(0.25, 0.25)
	p.direction = 0
	p.fitness = 0
	
	-- genes are used:
	p.a1 = g[1] / genome_range
	p.a2 = g[2] / genome_range
	p.a3 = g[3] / genome_range
	p.a4 = g[4] / genome_range
	p.a5 = g[5] / genome_range
	p.a6 = g[6] / genome_range
	p.a7 = g[7] / genome_range
	p.a8 = g[8] / genome_range
	
	p.p1 = g[9] / genome_range
	p.p2 = g[10] / genome_range
	p.p3 = g[11] / genome_range
	p.p4 = g[12] / genome_range	
	p.p5 = g[13] / genome_range
	p.p6 = g[14] / genome_range
	p.p7 = g[15] / genome_range
	p.p8 = g[16] / genome_range
	
	p.f1 = g[17] * 10 / genome_range
	p.f2 = g[18] * 10 / genome_range
	p.f3 = g[19] * 10 / genome_range
	p.f4 = g[20] * 10 / genome_range
	p.f5 = g[21] * 10 / genome_range
	p.f6 = g[22] * 10 / genome_range
	p.f7 = g[23] * 10 / genome_range
	p.f8 = g[24] * 10 / genome_range
end

function animate(p, step)
	local t = step / lifespan
	
	local turn = 
		p.a1 * (math.sin(math.pi * 2 * (p.p1 + t * p.f1))) +
		p.a2 * (math.sin(math.pi * 2 * (p.p2 + t * p.f2))) +
		p.a3 * (math.sin(math.pi * 2 * (p.p3 + t * p.f3))) +
		p.a4 * (math.sin(math.pi * 2 * (p.p4 + t * p.f4))) +
		p.a5 * (math.sin(math.pi * 2 * (p.p5 + t * p.f5))) +
		p.a6 * (math.sin(math.pi * 2 * (p.p6 + t * p.f6))) +
		p.a7 * (math.sin(math.pi * 2 * (p.p7 + t * p.f7))) +
		p.a8 * (math.sin(math.pi * 2 * (p.p8 + t * p.f8)))
	p.direction = p.direction + 0.2 * turn
	
	p.pos:add(vec2.fromPolar(0.01, p.direction))
	p.pos:mod(1)
	
	-- evaluate fitness according to how close it is to the goal:
	local dist = (goal - p.pos):length() 
	local fit = 1/dist
	-- give more emphasis to later steps:
	--fit = fit * t
	
	p.fitness = p.fitness + fit
	
end


-- seed population:
local pop = pop_make(population_size, genome_size, genome_range)
pop_develop(pop, develop)


local step = 1
function update()
	for i, p in ipairs(pop) do
		animate(p, step)
	end
	
	step = step + 1
	if step >= lifespan then
		step = 1
		pop = pop_generate(pop, mutation_rate, mutation_size, genome_size, genome_range)
		pop_develop(pop, develop)
	end
end

function draw()
	
	-- draw goal:
	draw2D.color(1, 1, 0)
	draw2D.circle(goal.x, goal.y, 0.01)

	for i, p in ipairs(pop) do
		draw2D.push()
			draw2D.translate(p.pos.x, p.pos.y)
			draw2D.rotate(p.direction)
			draw2D.scale(1/40)
			draw2D.color(1, 1, 1)
			draw2D.circle(0, 0, 1)
			draw2D.color(0, 0, 0)
			draw2D.circle(0.2, 0.2, 0.1)
			draw2D.circle(0.2,-0.2, 0.1)
			
		draw2D.pop()
	end
end



