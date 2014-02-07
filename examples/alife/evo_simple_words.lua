math.randomseed(os.time())
-- the task: generate a particular string:
local target = "colorless green ideas sleep furiously"
-- the phenotypic materials: a string of N genes
local genome_size = #target

-- chance of mutation:
local mutation_rate = 0.02
-- size of a mutation (how many steps in either direction it can go):
local mutation_range = 5

-- size of population:
local population_size = 20
-- turn this to false if you have large populations!
local show_populations = true

-- Encoding: a genotype is a sequence of letters
local encoding = { " ", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z" }

local gene_range = #encoding

-- generate a random genotype:
function geno_new()
	local g = {}
	for i = 1, genome_size do
		g[i] = math.random(gene_range)
	end
	return g
end


-- generate a phenotype from the genotype:
function geno_develop(g)
	local p = {}
	for i, gene in ipairs(g) do
		p[i] = encoding[gene]
	end
	return p
end

-- utility to see the phenotype:
function pheno_print(p)
	print(table.concat(p))
end

-- evaluate a phenotype:
function pheno_eval(p)
	local result = table.concat(p)
	-- score according to how near it is to the target:
	local err = 0
	for i, letter in ipairs(p) do	
		if letter ~= target:sub(i, i) then
			err = err + 1
		end
	end
	local fitness = 1 / (1 + err)
	return fitness
end

local pop = {}
	
-- run the simulation:
function initialize()
	-- re-initialize:
	generation = 1
	pop = {}
	-- create population:
	for i = 1, population_size do
		pop[i] = geno_new()
	end
end

initialize()

-- run each generation:
function regenerate()
	-- develop, evaluate & annotate each candidate:
	for i, g in ipairs(pop) do
		local p = geno_develop(g)
		local fitness = pheno_eval(p)
		-- store annotation:
		g.fitness = fitness
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
			print(i, g.pheno, "fitness:", g.fitness)
		end
	end
	
	-- terminating condition:
	local best = pop[1]
	print("gen:", generation, "best:", best.pheno, "fitness", best.fitness)
		
	-- create a new population:
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
				gene = gene + (math.random(mutation_range*2+1)-mutation_range)
				-- bring back into 1..8 range:
				gene = (gene % gene_range) + 1
				-- store:
				child[j] = gene
			end
		end
		-- TODO: other kinds of mutation: shuffling, reversing, etc.
		newpop[i] = child
	end
	-- replace:
	pop = newpop
	
	generation = generation + 1
end

function key(k)
	if k == "r" then
		-- reset:
		initialize()
	end
end

function update(dt)
	regenerate()
end
