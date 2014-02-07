-- load in the "field2D" library module (from /modules/field2D.lua):
local field2D = require "field2D"
win = Window("Game of Life", 512, 512)

local bit = require "bit"
local band, bor, bxor = bit.band, bit.bor, bit.bxor
local lshift, rshift, rol = bit.lshift, bit.rshift, bit.rol

local min, max = math.min, math.max
local random = math.random
local srandom = function() return random() * 2 - 1 end

function coin() return random() < 0.5 and 0 or 1 end

-- choose the size of the field
local dim = 128

-- allocate the field
local field = field2D(dim, dim)
local field_old = field2D(dim, dim)

function reset()
	for x = 1, dim-2 do
		for y = 1, dim-2 do
		
			local v = coin()
		
			field_old:set(v, x, y)
			field:set(v, x, y)
		end
	end	
end
reset()

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

function update()
	for x = 1, dim-2 do
		for y = 1, dim-2 do
			local x1 = x/dim
			local y1 = y/dim
		
			local o = field_old:get(x, y) > 0.5 and 1 or 0
			
			local n = field_old:get(x, y+1) > 0.5 and 1 or 0
			local e = field_old:get(x+1, y) > 0.5 and 1 or 0
			local s = field_old:get(x, y-1) > 0.5 and 1 or 0
			local w = field_old:get(x-1, y) > 0.5 and 1 or 0
			local ne = field_old:get(x+1, y+1) > 0.5 and 1 or 0
			local se = field_old:get(x+1, y-1) > 0.5 and 1 or 0
			local sw = field_old:get(x-1, y-1) > 0.5 and 1 or 0
			local nw = field_old:get(x-1, y+1) > 0.5 and 1 or 0
			local c = n+e+s+w+ne+nw+se+sw
			local o1 = rule(o, c, x1, y1) 
			o1 = min(max(o1, 0), 1)
			field:set(o1, x, y)
		end
	end	
	
	field_old, field = field, field_old
end

-- how to render the scene (toggle fullscreen with the Esc key):
function draw()	
	-- draw the field:
	field:draw()
end

-- handle keypress events:
function keydown(k)
	if k == "c" then
		-- set all cells to zero:
		field:clear()
	end
end


-- handle mouse events:
function mouse(event, btn, x, y)
	-- clicking & dragging should draw values into the field:
	if event == "down" or event == "drag" then
		
		-- scale window coords (0..1) up to the size of the field:
		local x = x / win.width * field.width
		local y = y / win.height * field.height
	
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
