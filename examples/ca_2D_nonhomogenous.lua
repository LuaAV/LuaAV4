-- load in the "field2D" library module (from /modules/field2D.lua):
local field2D = require "field2D"
win = Window("non-homogeneous CA", 512, 512)

-- choose the size of the field
local dimx = 128
local dimy = dimx

-- allocate the field
local field = field2D.new(dimx, dimy)

-- create a second field, to store the previous states of the cells:
local field_old = field2D.new(dimx, dimy)

-- create a function to return either 0 or 1
-- with a 50% chance of either (like flipping a coin)
function coin() 
	if math.random() < 0.5 then 
		return 0
	else
		return 1
	end
end

local min, max = math.min, math.max
local random = math.random
function srandom() return random() * 2 - 1 end

-- use this to initialize the field with random values:
-- (applies 'coin' to each cell of the field)
field:set(coin)

-- how to render the scene (toggle fullscreen with the Esc key):
function draw()	
	-- draw the field:
	field:draw()
end

function rule(o, c, x, y)
	x = x + srandom() * 0.1
	y = y + srandom() * 0.1
	local b1 = 2.5 --1 + x*2
	local b2 = 1.5 --1 + x*2
	local t1 = 3.5 --4 - x*2
	local t2 = 3.5 --4 - y*2
	if o < y then
		if c > b1 and c < t1 then	-- c == 3
			return 1
		else
			return o
		end
	else
		if c < b2 or c > t2 then
			return 0
		else
			return o
		end
	end
end

function step(old, new)
	for x = 1, dimx-2 do
		for y = 1, dimy-2 do
			local x1 = x/dimx
			local y1 = y/dimy
		
			local o = old:get(x, y)
			
			local n = old:get(x, y+1)
			local e = old:get(x+1, y)
			local s = old:get(x, y-1)
			local w = old:get(x-1, y)
			local ne = old:get(x+1, y+1)
			local se = old:get(x+1, y-1)
			local sw = old:get(x-1, y-1)
			local nw = old:get(x-1, y+1)
			local c = n+e+s+w+ne+nw+se+sw
			local o1 = rule(o, c, x1, y1) + srandom() * x1 * 0.1
			o1 = min(max(o1, 0), 1)
			--print(o, c, o1)
			new:set(o1, x, y)
		end
	end	
end

-- update the state of the scene (toggle this on and off with spacebar):
function update(dt)
	-- apply the rule function to each cell of the field: 
	step(field_old, field)
	
	-- swap field and field_old:
	-- (field now becomes old, and the new field is ready to be written)
	field, field_old = field_old, field
end

-- handle keypress events:
function key(e, k)
	if k == "c" then
		-- set all cells to zero:
		field:clear()
	elseif k == "r" then
		-- apply the coin rule to all cells of the field (randomizes)
		field:set(coin)
	end
end


-- handle mouse events:
function mouse(event, btn, x, y)
	x = x / win.width
	y = y / win.height
	-- clicking & dragging should draw values into the field:
	if event == "down" or event == "drag" then
		
		-- scale window coords (0..1) up to the size of the field:
		local x = x * field.width
		local y = y * field.height
	
		-- spread the updates over a wide area:
		for i = 1, 10 do
			-- pick a random cell near to the mouse position:
			local span = 3
			local fx = x + math.random(span) - math.random(span)
			local fy = y + math.random(span) - math.random(span)
			
			-- set this cell to either 0 or 1:
			field:set(coin(), fx, fy)
		end
	end
end
