local draw2D = require "draw2D"
local field2D = require "field2D"
local gl = require "gl"
local vec2 = require "vec2"
win = Window("chemotaxis", 512, 512)

-- make each run different:
math.randomseed(os.time())

-- the field
local dimx = 64
local dimy = dimx
local sugar = field2D(dimx, dimy)

-- where sugar comes:
local sugar_center = vec2(0.5, 0.5)

function initialize_sugar(x, y)
	-- convert x,y to vector in 0..1 range:
	local p = vec2(x/dimx, y/dimy)
	-- get relative position from center:
	local rel = p - sugar_center
	-- wrap in toroidal space:
	rel:add(0.5):mod(1):sub(0.5)
	-- calculate distance:
	local d = rel:length()
	-- invert:
	return 1 - d*2
end

function reset_sugar()
	sugar_center:set(math.random(), math.random())
	sugar:set(initialize_sugar)
end

reset_sugar()

-- create a few agents:
local agents = {}
for i = 1, 50 do
	local a = {
		pos = vec2(),
		vel = vec2(),
		direction = math.pi * 2 * math.random(),
		scale = 0.1,
		
		s_old = 0,
		happy = true,
	}
	agents[i] = a
end

function reset_agents()
	for i, a in ipairs(agents) do
		a.pos:randomize()
	end
end

reset_agents()

function update()
	for i, a in ipairs(agents) do
		-- read local field:
		local s_local = sugar:sample(a.pos.x, a.pos.y)	
		-- agents are happy if life is getting better:
		a.happy = s_local > a.s_old
		-- store for next update:
		a.s_old = s_local
		
		-- compare with previous:
		if a.happy then
			-- life is getting better, keep going
		else
			-- life is getting worlse, tumble about
			-- create a random force
			local F = vec2.random()
			-- apply to velocity, with damping and limiting:
			a.vel:add(F)
			a.vel:limit(0.01)
		end
		
		-- integrate velocity to position
		a.pos:add(a.vel)
		-- wrap at edges
		a.pos:mod(1)
		
		-- derive direciton:
		a.direction = a.vel:angle()
	end
end
	
function draw()
	-- draw field in background:
	draw2D.color(1, 1, 1)
	sugar:draw()
	-- then draw agents:
	for i, a in ipairs(agents) do
		draw2D.push()
			draw2D.translate(a.pos.x, a.pos.y)
			draw2D.rotate(a.direction)
			draw2D.scale(a.scale, a.scale)
			
			if a.happy then
				draw2D.color(0, 1, 0.5)
			else
				draw2D.color(0, 0.5, 1)
			end
			draw2D.rect(0, 0, 0.1, 0.1)
			draw2D.line(0, 0, -0.2, 0)
		draw2D.pop()
	end
end

function key(e, k)
	if e == "down" then
		if k == "a" then
			reset_agents()
		elseif k == "s" then
			reset_sugar()
		end
	end
end