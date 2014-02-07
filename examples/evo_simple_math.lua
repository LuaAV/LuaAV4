
math.randomseed(os.time())
-- the task: generate a particular number:
local target = math.pi
-- the phenotypic materials: a string of N genes (should be an odd number)
local genome_size = 5

-- chance of mutation:
local mutation_rate = 0.1

-- maximum times to run
local max_generations = 100
-- or required fitness to terminate:
local sufficient_fitness = 1

-- size of population:
local population_size = 10
-- turn this to false if you have large populations!
local show_populations = false

-- Encoding: a genotype is an odd-number sequence of integers in the range 1..8
-- generate a random genotype:
function geno_new()
	local g = {}
	for i = 1, genome_size do
		g[i] = math.random(8)
	end
	return g
end

local operators = { "+", "-", "*", "/", "+", "-", "*", "/" }

-- generate a phenotype from the genotype:
function geno_develop(g)
	local p = {}
	for i, gene in ipairs(g) do
		if i % 2 == 1 then
			p[i] = gene
		else
			p[i] = operators[(gene % 4) + 1]
		end
	end
	return p
end

-- utility to see the phenotype:
function pheno_print(p)
	print(table.concat(p))
end

-- evaluate a phenotype:
function pheno_eval(p)
	-- evaluate as Lua code:
	local f = loadstring("return "..table.concat(p))
	local result = f()
	-- score according to how near it is to the target:
	local err = math.abs(target - result)
	local fitness = 1 / (1 + err)
	return fitness, result
end




local generation = 1
	
-- run the simulation:
function run()
	-- re-initialize:
	generation = 1
	-- create population:
	local pop = {}
	for i = 1, population_size do
		pop[i] = geno_new()
	end
	-- run each generation:
	while true do
		-- develop, evaluate & annotate each candidate:
		for i, g in ipairs(pop) do
			local p = geno_develop(g)
			local fitness, result = pheno_eval(p)
			-- store annotation:
			g.fitness = fitness
			g.result = result
			g.pheno = table.concat(p)
		end
		
		-- sort the population by fitness:
		table.sort(pop, function(a, b)
			return a.fitness > b.fitness
		end)
		
		-- show it:
		if show_populations then
			print("generation", generation, "------------------------")
			for i, g in ipairs(pop) do
				print(i, g.pheno, g.result, g.fitness)
			end
		end
		
		-- terminating condition:
		local best = pop[1]
		if best.fitness >= sufficient_fitness or generation >= max_generations then
			return best
		end
		
		-- else create a new population:
		local newpop = {}
		for i = 1, population_size do
			-- crossover:
			local mum = pop[math.random(i)]
			local dad = pop[math.random(i)]
			local child = {}
			
			-- crossover reproduction:
			local cross = math.random(genome_size)
			for j = 1, cross do
				child[j] = mum[j]
			end
			for j = cross+1, genome_size do
				child[j] = dad[j]
			end
			-- apply mutation:
			for j, gene in ipairs(child) do
				-- mutate?
				if math.random() < mutation_rate then
					-- mutate plus or minus 1:
					gene = gene + (math.random(3)-1)
					-- bring back into 1..8 range:
					gene = (gene % 8) + 1
					-- store:
					child[j] = gene
				end
			end
			
			newpop[i] = child
		end
		-- replace:
		pop = newpop
		
		generation = generation + 1
	end
end

-- run the simulation several times to see how it is sensitive to chance:
for i = 1, 10 do
	local best = run()
	print("best candidate:", best.pheno, "fitness", best.fitness, "result", best.result, "after", generation, "generations")
end