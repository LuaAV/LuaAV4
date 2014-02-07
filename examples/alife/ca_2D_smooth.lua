--[[

An implementation of SmoothLife

Largely inspired by:

Stephan Rafler. Generalization of Conway's "Game of Life" to a continuous domain - SmoothLife. 
http://arxiv.org/pdf/1111.1567v2.pdf

Uses continuous-valued cells (in the 0..1 range)
With a continous notion of self and neighborhood (using anti-aliased disk and ring kernels)
And a continous transition function (using sigmoid functions)
TODO: continous time by interpreting transition as a rate of change

--]]

local field2D = require "field2D"
win = Window("Smooth Life")

math.randomseed(os.time())
local floor = math.floor
local sqrt, exp = math.sqrt, math.exp
local min, max = math.min, math.max
local sin, cos = math.sin, math.cos
local pi = math.pi

-- choose the size of the field
local dimx = 200
local dimy = dimx * 3/4 -- (with a 4:3 aspect ratio)

-- allocate the field
local field = field2D.new(dimx, dimy)

-- create a second field, to store the previous states of the cells:
local field_old = field2D.new(dimx, dimy)


---- PARAMETERS ----
--[[

-- inner radius (boundary of self)
local r1 = 0.7
-- outer radius (boundary of neighborhood)
local r2 = 2

-- min & max for birth:
local bmin, bmax = 0.27, 0.36
-- min & max for survival:
local lmin, lmax = 0.2, 0.48

-- smooth sigmoid transitions:
local a1 = 0.05
local a2 = 0.15

--]]

local dt = 1

-- inner radius (boundary of self)
local r1 = 2
-- outer radius (boundary of neighborhood)
local r2 = 4

-- min & max for birth:
local bmin, bmax = 0.278, 0.365
-- min & max for survival:
local lmin, lmax = 0.267, 0.445

-- smooth sigmoid transitions:
local a1 = 0.028
local a2 = 0.147


-- inner radius (boundary of self)
local r1 = 1 --0.5
-- outer radius (boundary of neighborhood)
local r2 = 3 --1.5

-- min & max for birth:
local bmin, bmax = 0.27, 0.3
-- min & max for survival:
local lmin, lmax = 0.26, 0.35

-- smooth sigmoid transitions:
local sharp_birth = 0.1
local sharp_death = 0.02
local sharp_current = 0.02

dt = 0.3

-- inner radius (boundary of self)
local r1 = 1
-- outer radius (boundary of neighborhood)
local r2 = 2.5

-- min & max for birth:
local bmin, bmax = 0.27, 0.325
-- min & max for survival:
local lmin, lmax = 0.26, 0.6


-- smooth sigmoid transitions:
local sharp_birth = 0.002
local sharp_death = sharp_birth
local sharp_current = 0.2

dt = 0.25

---- KERNELS ----
-- the processing is made much faster by pre-computing the self and neighborhood cell offsets & scaling factors for the inner disk and outer ring:

function createKernels(r1, r2)
	-- pre-compute the kernel cells:
	local k1 = {}
	local k2 = {}
	
	-- force integer offsets:
	local rmin = math.floor(-r2)
	local rmax = math.ceil(r2)
	
	for x1 = rmin, rmax do
		for y1 = rmin, rmax do
			local distance = sqrt(x1*x1 + y1*y1)
			if distance < (r1 + 0.5) then
				local alias = 1
				if distance > r1 then
					alias = 1 - (distance - r1)
				end
				table.insert(k1, { x1, y1, alias })
			end
			if distance > (r1 - 0.5) and distance < (r2 + 0.5) then
				local alias = 1
				if distance > r2 then
					alias = 1 - (distance - r2)
				elseif distance < r1 then
					alias = 1 - (r1 - distance)
				end
				table.insert(k2, { x1, y1, alias })
			end
		end
	end
	
	local innersize = #k1
	local outersize = #k2
	
	-- also pre-scale all kernel elements down by kernel size
	-- (i.e. normalize the kernel to sum to 1)
	-- so that the kernels produce normalized (0..1) results when integrated:
	for i, v in ipairs(k1) do v[3] = v[3] / innersize end
	for i, v in ipairs(k2) do v[3] = v[3] / outersize end
	
	
	print("the inner disk (self):")
	for i, v in ipairs(k1) do 
		print(string.format("x = %d, y = %d, anti-alias weight = %f", unpack(v)))
	end
	
	print("the outer ring (neighborhood):")
	for i, v in ipairs(k2) do 
		print(string.format("x = %d, y = %d, anti-alias weight = %f", unpack(v)))
	end
	
	
	-- this is how the kernels get used:
	local inner = function(x, y)
		local concentration = 0
		for i = 1, innersize do
			local v = k1[i]
			concentration = concentration + field_old:get(x + v[1], y + v[2]) * v[3]
		end
		return concentration
	end
	
	local outer = function(x, y)
		local concentration = 0
		for i = 1, outersize do
			local v = k2[i]
			concentration = concentration + field_old:get(x + v[1], y + v[2]) * v[3]
		end
		return concentration
	end
	
	return inner, outer
end

local concentration_inner, concentration_outer = createKernels(r1, r2)

---- TRANSITION FUNCTION ----
-- the transition function is also smooth, constructed out of several sigmoid functions:

function s1(x, a, alpha)
	return 1 / (1 + exp((a - x)*4/alpha))
end

-- assumes b > a:
function s2(x, a, b, alpha)
	return s1(x, a, alpha) * (1 - s1(x, b, alpha))
end

-- linear interp between x and y according to current state m:
-- (y when m is >> 0.5, x when m is << 0.5)
-- (smooth in the region between defined by a1)
function sm(x, y, m, alpha)
	local current = 1 / (1 + exp((0.5 - m)*4/alpha))
	return x + current * (y - x)
end

function transition(outer, inner)
	-- if we are dead:
	local birth = s2(outer, bmin, bmax, sharp_birth)
	-- if we are alive:
	local death = s2(outer, lmin, lmax, sharp_death) - 1
	-- mix between these according to current state:
	return sm(birth, death, inner, sharp_current)
end

---- INITIAL CONDITIONS ----

function initialize(x, y)
	local nx = x/field.width
	local ny = y/field.height
	
	 return math.random() * math.random()
	 --+ 0.5 * (transition(nx, ny))
	--return nx * ny
end

-- use this to initialize the field:
field:set(initialize)

---- AUTOMATON ----
-- here the kernels & transition rules are computed per cell:

function evaluate(x, y)
	-- get concentrations of inner (self) and outer (neighborhood) regions:
	local inner = concentration_inner(x, y)
	local outer = concentration_outer(x, y)
	
	-- old state:
	local C0 = field_old:get(x, y)
	
	-- new state:
	local C1 = transition(outer, inner, bmin, bmax, lmin, lmax, a1, a2)
	
	
	-- apply gradually (interpret as rate of change):
	C1 = C0 + dt * (C1 - inner)
	
	-- clip
	C1 = max(min(C1, 1), 0)
	
	globalmax = globalmax and max(globalmax, C) or C
	globalmin = globalmin and min(globalmin, C) or C
	
	return C1
end


-- update the state of the scene (toggle this on and off with spacebar):
function update(dt)
	---[[
	-- swap field and field_old:
	-- (field now becomes old, and the new field is ready to be written)
	field, field_old = field_old, field
	
	globalmax = nil
	globalmin = nil
	
	-- run the simulation:
	field:set(evaluate)
	--]]
	
	--[[
	-- restart if it all dies away:
	if globalmax < 0.1 or globalmin > 0.9 then
		field:set(initialize)
	end
	--]]
end


-- how to render the scene (toggle fullscreen with the Esc key):
function draw()	
	-- draw the field:
	field:draw()
end

-- handle keypress events:
function key(e, k)
	if k == "r" then
		-- apply the coin rule to all cells of the field (randomizes)
		field:set(initialize)
	elseif k == "c" then
		field:clear()
	elseif k == "t" then
		field:set(function(x, y)
			return 0.5 + 0.5 * transition(x / field.width, y / field.height)
		end)
	end
end
