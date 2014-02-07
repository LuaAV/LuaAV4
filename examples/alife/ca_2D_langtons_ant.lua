-- load in the "field2D" library module (from /modules/field2D.lua):
local field2D = require "field2D"

local win = Window("Langton's Ant")

-- choose the size of the field
local dimx = win.width
local dimy = win.height

-- allocate the field
local field = field2D.new(dimx, dimy)
field:set(1)

-- starting position:
local antx = dimx/2
local anty = dimy/2
local direction = 0 

-- how to render the scene (toggle fullscreen with the Esc key):
function draw()	
	-- draw the field:
	field:draw()
end

-- try turning this up to 10, then 100, then 1000... 
local speed = 1

-- update the state of the scene (toggle this on and off with spacebar):
function update(dt)

	for i = 1, speed do
	
		-- apply the rule:
		local state = field:get(antx, anty)
		if state == 1 then
			direction = (direction + 1) % 4
			field:set(0, antx, anty)
		else
			direction = (direction - 1) % 4
			field:set(1, antx, anty)
		end
		
		-- move the ant:
		if direction == 0 then
			-- North
			anty = (anty + 1) % field.height
		elseif direction == 1 then
			-- West
			antx = (antx - 1) % field.width
		elseif direction == 2 then
			-- South
			anty = (anty - 1) % field.height
		else
			-- East
			antx = (antx + 1) % field.width
		end
	end	
end

-- handle keypress events:
function key(e, k)
	if k == "r" then
		-- apply the coin rule to all cells of the field (randomizes)
		field:set(1)
	end
end

-- handle mouse events:
function mouse(event, btn, x, y)
	-- clicking & dragging should draw trees into the field:
	if event == "down" or event == "drag" then
		field:set(0, x / win.width * field.width, y / win.height * field.height)
	end
end
