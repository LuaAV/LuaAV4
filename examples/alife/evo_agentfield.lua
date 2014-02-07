local field2D = require "field2D"
local vec2 = require "vec2"
local draw2D = require "draw2D"

math.randomseed(os.time())

win = Window(nil, 400, 400)

-- number of genes in a genome:
local genome_size = 8
-- number of different values a gene can take:
local gene_range = 9

local mutation_rate = 0.01

local generation_length = 300

-- convert a number in the range 1..8 to the range -1..1
function gene_to_signed(gene)
	local s = ((gene-1)/(gene_range-1))*2-1
	return s * math.abs(s)
end

function genome_make()
	local g = {}
	for i = 1, genome_size do
		g[i] = math.random(gene_range)
	end
	return g
end

function genome_print(g)
	print( "{" .. table.concat(g, ",") .. "}" )
end

function genome_copy(g)
	return { unpack(g) }
end

function genome_mutate(g, rate)
	for i = 1, #g do
		if math.random() < rate then
			if math.random() < 0.5 then
				g[i] = g[i] + 1
			else
				g[i] = g[i] - 1
			end
			g[i] = ((g[i] - 1) % gene_range) + 1
		end
	end
end

function genome_develop(g)
	local a = {
		-- store the genome inside:
		genome = g,
		
		pos = vec2(math.random(), math.random()),
		direction = math.pi * 2 * math.random(),	
		
		food = 0,
	}
	
	-- interpret the genome:
	a.scale = 0.02
	
	a.motor_avg = g[1] * 0.1
	a.motor_inv = g[2] * 0.1
	a.motor_diff = gene_to_signed(g[3])
	a.motor_noise = gene_to_signed(g[4])
	
	a.rotor_avg = gene_to_signed(g[5])
	a.rotor_inv = gene_to_signed(g[6])
	a.rotor_diff = gene_to_signed(g[7])
	a.rotor_noise = gene_to_signed(g[8])
	
	return a
end

-- initialize the environment
local dim = 200
local food = field2D(dim, dim)
local food_old = field2D(dim, dim)

function food_initialize()
	-- refill the food:
	food:set(function() return math.random() end)
	for i = 1, 10 do
		food, food_old = food_old, food
		food:diffuse(food_old, 10)
	end
	food:normalize()
end
food_initialize()

-- initialize the population:
local pop = {}
for i = 1, 100 do
	local g = genome_make()
	pop[i] = genome_develop(g)
end

function agent_eval(a)
	a.fitness = a.food / generation_length
end

-- evolve the population:
local generation = 1
function regenerate()
	-- evaluate all agents:
	local totalfitness = 0
	for i, a in ipairs(pop) do
		agent_eval(a)
		totalfitness = totalfitness + a.fitness
	end
	print("generation", generation, "average fitness:", totalfitness / #pop)
	
	-- sort the population by fitness:
	table.sort(pop, function(a, b)
		return a.fitness > b.fitness
	end)
	
	-- use this to create a new population:
	local newpop = {}
	for i = 1, #pop do
		-- choose a random parent
		-- (biased to higher fitness)
		local mum = pop[math.random(i)]
		local g = genome_copy(mum.genome)
		
		genome_mutate(g, mutation_rate)
		
		newpop[i] = genome_develop(g)
	end
	-- replace the population:
	pop = newpop
	
	-- refill the food:
	food_initialize()
	
	generation = generation + 1
end

local frame = 0

function update(dt)
	frame = frame + 1
	
	if frame >= generation_length then
		frame = 0
		regenerate()
	end

	for i, a in ipairs(pop) do
	
		-- eat locally:
		local f = food:sample(a.pos.x, a.pos.y)
		-- move from field to self:
		food:splat(-f, a.pos.x, a.pos.y)
		a.food = a.food + f
		
		-- figure out the sensors:
		local antenna1 = a.pos + vec2(1, 1):rotate(a.direction):mul(a.scale)
		local antenna2 = a.pos + vec2(1, -1):rotate(a.direction):mul(a.scale)
		local sensor1 = food:sample(antenna1.x, antenna1.y)
		local sensor2 = food:sample(antenna2.x, antenna2.y)
		local avg = (sensor1 + sensor2) / 2
		local inv = 1 / avg
		local diff = sensor1 - sensor2
		local noise = math.random()
		
		-- drive the motor and the rotor according to sum and diff:
		
		local motor = a.motor_avg * avg 
				    + a.motor_inv * inv 
				    + a.motor_diff * diff 
				    + a.motor_noise * noise
		local rotor = a.rotor_avg * avg 
				    + a.rotor_inv * inv 
					+ a.rotor_diff * diff 
					+ a.rotor_noise * noise
		
		local speed = motor * dt * 0.1
		local turn = rotor * 0.1
		
		a.direction = a.direction + turn
		a.vel = vec2.fromPolar(speed, a.direction)
		
		
		a.pos:add(a.vel)
		a.pos:mod(1)
	end
end

function draw()
	draw2D.color(0.1, 1, 1)
	food:draw()

	for i, a in ipairs(pop) do
		draw2D.push()
			draw2D.translate(a.pos.x, a.pos.y)
			draw2D.rotate(a.direction)
			draw2D.scale(a.scale)
			draw2D.color(1, 0.5, 0.5)
			draw2D.ellipse(0, 0, 1)
			draw2D.line(0, 0, 1, 1)
			draw2D.line(0, 0, 1, -1)
			draw2D.rect(-0.7, 0, 0.5, 0.5)
			draw2D.color(0, 0, 0)
			draw2D.ellipse(0.2, 0.2, 0.2)
			draw2D.ellipse(0.2, -0.2, 0.2)
		draw2D.pop()
	end
end

function key(e, k)
	if k == "r" then
		regenerate()
	end
end



