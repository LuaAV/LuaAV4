local field2D = require "field2D"
local draw2D = require "draw2D"
local vec2 = require "vec2"

win = Window("flowdir", 500, 500)
--math.randomseed(os.time())


local dimx = 128
local dimy = dimx
local field = field2D.new(dimx, dimy)

function field_reset()
	field:set(function() return math.random() end)
	field:diffuse(field, 1)
	field:normalize()
end
field_reset()

function draw_agent_boxily(a)
	draw2D.push()
		draw2D.translate(a.pos.x, a.pos.y)
		draw2D.rotate(a.direction)
		draw2D.scale(a.scale, a.scale)
		
		draw2D.color(1, 1., 0.5)
		draw2D.rect(0, 0, 0.1, 0.1)
		draw2D.line(0, 0, -0.2, 0)
	draw2D.pop()
end

local agents = {}
function reset_agents()
	for i = 1, 2000 do
		agents[i] = {
			pos = vec2(math.random(), math.random()),
			vel = vec2(),
			direction = math.pi * 2 * math.random(),
			scale = 0.1,
		}
	end
end
reset_agents()

function update()
	for i, a in ipairs(agents) do
		local c = field:sample(a.pos.x, a.pos.y)
		-- introduce noise:
		--c = c + (math.random() - 0.5)*0.2
		-- feedback to field:
		--field:update(c, a.pos.x, a.pos.y)
		
		-- convert to direction (radians):
		a.direction = c * math.pi * 2
		-- apply movement:
		a.vel = vec2.fromPolar(0.01, a.direction)
		-- locomotion:
		a.pos:add(a.vel)
		-- boundary:
		a.pos:mod(1) 
	end
end

function draw()
	field:draw()
	for i, a in ipairs(agents) do
		draw_agent_boxily(a)
	end
end	

function key(e, k)
	if k == "r" then
		reset_agents()
	end
end