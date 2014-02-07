local field2D = require "field2D"
local draw2D = require "draw2D"
local vec2 = require "vec2"

win = Window("stigmergy", 600, 600)
--math.randomseed(os.time())

local dimx = 256
local dimy = dimx
local food = field2D(dimx, dimy)
local food_phero = field2D(dimx, dimy)
local nest_phero = field2D(dimx, dimy)
local phero_decay = 0.995
local agents = {}

local ant_speed = 0.003
local ant_wander = 0.3
local ant_follow = 0.1
local ant_capacity = 1
local ant_sensor_size = 0.01

local nest = vec2(0.5, 0.5)
local nestsize = 0.02

local nestfood = 0
local lostfood = 0
local totalfood = 0

-- antenna locations (relative to body):
local antenna1 = vec2(ant_sensor_size,  ant_sensor_size)
local antenna2 = vec2(ant_sensor_size, -ant_sensor_size)

function food_reset()
	food:set(0)
	totalfood = 0
	
	for i = 1, 40 do
		local x, y = math.random(dimx), math.random(dimy)
		local size = 2
		for x1 = x-size, x+size do
			for y1 = y-size, y+size do
				food:set(1, x1, y1)
				totalfood = totalfood + 1
			end
		end
	end
end

function food_phero_reset() 
	food_phero:set(0)
	nest_phero:set(0)
end

function agents_reset()
	for i = 1, 200 do
		agents[i] = {
			pos = vec2(nest),
			vel = vec2(),
			direction = math.pi * 2 * math.random(),
			scale = 0.1,
			
			-- how much food the ant is carrying:
			food = 0,
		}
	end
end

food_reset()
food_phero_reset()
agents_reset()

-- steer by pheromone concentration:
function sniff_agent_direction(a, phero)
	-- where are my antenna?
	-- rotate & translate into agent view:
	local a1 = a.pos + antenna1:rotatenew(a.direction)
	local a2 = a.pos + antenna2:rotatenew(a.direction)
	-- sample field at antenna positions:
	local p1 = phero:sample(a1.x, a1.y)
	local p2 = phero:sample(a2.x, a2.y)
	-- is there any pheromone near?
	-- (use random factor to avoid over-reliance on pheromone trails)
	local pnear = (p1 + p2) - math.random()
	if pnear > 0 then
		-- turn left or right?
		if p1 > p2 then
			a.direction = a.direction + ant_follow
		else
			a.direction = a.direction - ant_follow
		end
	else
		-- wander randomly
		a.direction = a.direction + ant_wander*(math.random()-0.5)
	end
end

function update()
	-- food_pheromone trails gradually decay:
	food_phero:scale(phero_decay)
	nest_phero:scale(phero_decay)
	
	for i, a in ipairs(agents) do	
		-- move:
		a.pos:add(vec2.fromPolar(ant_speed, a.direction))
		
		-- if out of range?
		if a.pos.x > 1 or a.pos.y > 1 or a.pos.x < 0 or a.pos.y < 0 then
			-- reset agent:
			a.pos:set(nest)
			lostfood = lostfood + a.food
			a.food = 0
			a.direction = math.random() * 2 * math.pi
		end
		
		-- change of goal / direction?
		if a.food > 0 then
			-- are we there yet?
			if a.pos:distance(nest) < nestsize then
				-- drop food and search again:
				nestfood = nestfood + a.food
				a.food = 0
				a.direction = a.direction + math.pi
			else
				-- look for nest:
				sniff_agent_direction(a, nest_phero)
				
				-- say "I came from food"
				food_phero:splat(a.food, a.pos.x, a.pos.y)
				
				-- my own food decays too:
				a.food = a.food * phero_decay
			end
		else
			-- found food??
			local f = food:sample(a.pos.x, a.pos.y)
			if f > 0 then
				-- remove it:
				food:splat(-ant_capacity, a.pos.x, a.pos.y)
				a.food = a.food + ant_capacity
				a.direction = a.direction + math.pi
			else
				-- look for food:
				sniff_agent_direction(a, food_phero)
				
				-- say "I came from the nest":
				nest_phero:splat(ant_capacity, a.pos.x, a.pos.y)
			end
		end		
	end
	
	print(string.format("found %6.1f, lost %6.1f of %f", nestfood, lostfood, totalfood))
end

local showagents = true
local showfield = true

function draw()
	-- fields:
	if showfield then
		field2D.drawRGB(food, food_phero, nest_phero)
	else
		draw2D.color(1,0,0)
		food:draw()
	end	
	
	-- nest:
	draw2D.color(1, 0, 1)
	draw2D.ellipse(nest.x, nest.y, nestsize*2)
	
	-- agents:
	if showagents then
		for i, a in ipairs(agents) do
			draw2D.push()
				draw2D.translate(a.pos.x, a.pos.y)
				draw2D.rotate(a.direction)
				-- body
				draw2D.color(1, a.food / ant_capacity, 0.5)
				draw2D.ellipse(0, 0, 0.006)
				draw2D.ellipse(-0.005, 0, 0.006)
				draw2D.ellipse(-0.01, 0, 0.006)								
				-- sensors:
				draw2D.line(0, 0, antenna1.x, antenna1.y)
				draw2D.line(0, 0, antenna2.x, antenna2.y)
			draw2D.pop()
		end
	end	
end	

function keydown(k)
	if k == "a" then
		showagents = not showagents
	elseif k == "f" then
		showfield = not showfield
	elseif k == "r" then
		food_reset()
		food_phero_reset()
		agents_reset()
	end
end