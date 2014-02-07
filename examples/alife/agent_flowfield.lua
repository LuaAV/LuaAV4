local field2D = require "field2D"
local draw2D = require "draw2D"
local vec2 = require "vec2"

win = Window("flowfield", 600, 600)
math.randomseed(os.time())

local dimx = 128
local dimy = dimx
-- flow field in X and Y components:
local fx = field2D.new(dimx, dimy)
local fy = field2D.new(dimx, dimy)
local fx_old = field2D.new(dimx, dimy)
local fy_old = field2D.new(dimx, dimy)

function field_reset()
	fx:set(function() return math.random()*2-1 end)
	fy:set(function() return math.random()*2-1 end)
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
	for i = 1, 200 do
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
	
	---[[
	-- swap fields:
	fx, fx_old = fx_old, fx
	fy, fy_old = fy_old, fy
	-- diffuse fields:
	fx:diffuse(fx_old, 0.001)
	fy:diffuse(fy_old, 0.001)
	--]]
	
	-- read field
	for i, a in ipairs(agents) do
		local x = fx:sample(a.pos.x, a.pos.y)
		local y = fy:sample(a.pos.x, a.pos.y)
		local c = vec2(x, y):angle()
		-- introduce noise:
		c = c + (math.random() - 0.5)*0.5
		a.direction = c
		
		-- apply movement:
		a.vel = vec2.fromPolar(0.01, a.direction)
		-- locomotion:
		a.pos:add(a.vel)
		-- boundary:
		a.pos:mod(1) 
	end
	
	-- update field
	for i, a in ipairs(agents) do	
		
		-- feedback to field:
		local x = math.cos(a.direction)
		local y = math.sin(a.direction)
		fx:update(x, a.pos.x, a.pos.y)
		fy:update(y, a.pos.x, a.pos.y)
	end
end

function draw()
	local gl = require "gl"
	gl.LineWidth(0.5)

	draw2D.color(1, 1, 1)
	field2D.drawFlow(fx, fy)
	
	for i, a in ipairs(agents) do
		draw_agent_boxily(a)
	end
end	

function key(e, k)
	print(e, k)
	if k == "r" then
		reset_agents()
	end
end