local draw2D = require "draw2D"
local field2D = require "field2D"
local gl = require "gl"
local vec2 = require "vec2"
win = Window("fieldtrails", 512, 512)

-- make each run different:
math.randomseed(os.time())

-- the field
local dimx = 128
local dimy = dimx
local field = field2D(dimx, dimy)
local field_old = field2D(dimx, dimy)

local diffuse_rate = 0.1
local decay_rate = 0.999

function decay(x, y)
	return field:get(x, y) * decay_rate
end

-- create a few agents:
local agents = {}
for i = 1, 4 do
	local a = {
		pos = vec2(),
		vel = vec2(),
		direction = math.pi * 2 * math.random(),
		scale = 0.1,
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
	-- swap fields:
	field, field_old = field_old, field
	-- diffuse field:
	field:diffuse(field_old, diffuse_rate)
	-- decay field:
	field:set(decay)

	for i, a in ipairs(agents) do
		
		-- wander:
		local F = vec2.random(0.1)
		
		-- apply to velocity, with damping and limiting:
		a.vel:lerp(a.vel + F, 0.1)
		a.vel:limit(0.01)
		
		-- integrate velocity to position
		a.pos:add(a.vel)
		-- wrap at edges
		a.pos:mod(1)
		
		-- derive direciton:
		a.direction = a.vel:angle()
		
		-- write to field:
		field:splat(1, a.pos.x, a.pos.y)
	end
end
	
function draw()
	-- draw field in background:
	field:draw()
	-- then draw agents:
	for i, a in ipairs(agents) do
		draw2D.push()
			draw2D.translate(a.pos.x, a.pos.y)
			draw2D.rotate(a.direction)
			draw2D.scale(a.scale, a.scale)
			
			draw2D.color(0, 0.75, 1)
			draw2D.rect(0, 0, 0.1, 0.1)
			draw2D.line(0, 0, -0.2, 0)
		draw2D.pop()
	end
end

function mouse(e, b, x, y)
	if e == "down" or e == "drag" then
		agents[1].pos:set(x, y)
	end
end

function keydown(k)
	if k == "a" then
		reset_agents()
	end
end