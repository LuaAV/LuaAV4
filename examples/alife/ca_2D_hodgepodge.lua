
-- @see http://www.sciencedirect.com/science/article/pii/016727898990081X#
-- This typically goes through several stages:
-- first a mass pulsing, more or less synchronized with a textured brain-like pattern
-- then circular pulsing pockets begin to appear and grow, with waves pushing to larger regions at different phases
-- then spiral patterns begin to appear and overcome the still growing pulsations
-- the spirals break down under their own advection into smaller spirals while the bigger waves consume the remaining space

-- the crucial parameter to vary these behaviors is sickness_rate

local field2D = require "field2D"
win = Window("hodgepodge", 512, 512)

math.randomseed(os.time())
local floor = math.floor
local min = math.min

-- choose the size of the field
local dimx = win.width
local dimy = win.height

-- allocate the field
local field = field2D.new(dimx, dimy)

-- create a second field, to store the previous states of the cells:
local field_old = field2D.new(dimx, dimy)

local sickness_rate = 0.11
local infection_rate_infected = 1/3
local infection_rate_ill = 1
local initial_infection = 1/255

function initialize()
	return 1 - math.random() * math.random()
end

-- use this to initialize the field:
field:set(initialize)

-- how to render the scene (toggle fullscreen with the Esc key):
function draw()	
	-- draw the field:
	field:draw()
end

-- a cell is infected if the value is greater than zero:
local isinfected = math.ceil
-- a cell is ill if the value is equal or greater than 1:
local isill = math.floor


-- the rule for an individual cell (at position x, y) in the field:
function hodgepodge(x, y)
	
	-- check my own previous state:
	local C = field_old:get(x, y)

	-- check out the neighbors' previous states:
	local N  = field_old:get(x  , y+1)
	local NE = field_old:get(x+1, y+1)
	local E  = field_old:get(x+1, y  )
	local SE = field_old:get(x+1, y-1)
	local S  = field_old:get(x  , y-1)
	local SW = field_old:get(x-1, y-1)
	local W  = field_old:get(x-1, y  )
	local NW = field_old:get(x-1, y+1)
	
	
	if C >= 1 then
		-- all ill cells are healed automatically:
		C = 0
	elseif C > 0 then
		-- infected
		local nearbyinfection = C + N + NE + E + SE + S + SW + W + NW
		local nearbyinfected =   1
							 + 	 isinfected(N) + isinfected(NE) 
							 + 	 isinfected(E) + isinfected(SE) 
							 +   isinfected(S) + isinfected(SW) 
							 +   isinfected(W) + isinfected(NW)
		local averageinfection = nearbyinfection / nearbyinfected
		C = sickness_rate + averageinfection
		C = min(1, C) 
	else
		-- healthy cell:
		
		
		-- number of local infected:
		local nearbyinfected = ( 
							 isinfected(N) + isinfected(NE) 
						 + 	 isinfected(E) + isinfected(SE) 
						 +   isinfected(S) + isinfected(SW) 
						 +   isinfected(W) + isinfected(NW) 
						 )
		-- calculate number of local ill:
		local nearbyill  = ( 
							 isill(N) + isill(NE) 
						 + 	 isill(E) + isill(SE) 
						 +   isill(S) + isill(SW) 
						 +   isill(W) + isill(NW) 
						 )
		
		local influence = floor(nearbyinfected * infection_rate_infected) 
						+ floor(nearbyill * infection_rate_ill)
		
		C = initial_infection * influence
	end
	-- a sick cell gets sicker by a fixed amount, plus extra sickness due to infected neighbours. It cannot get sicker than the limit.
	-- An uninfected cell may catch infection, depending on its neighbours.
	-- At the next 'tick' any ill cells are healed!
	
	-- return the new state:
	return C
end

-- update the state of the scene (toggle this on and off with spacebar):
function update(dt)
	-- swap field and field_old:
	-- (field now becomes old, and the new field is ready to be written)
	field, field_old = field_old, field
	
	-- apply the game_of_life function to each cell of the field: 
	field:set(hodgepodge)
end

-- handle keypress events:
function key(e, k)
	if k == "r" then
		-- apply the coin rule to all cells of the field (randomizes)
		field:set(initialize)
	elseif k == "c" then
		field:clear()
	end
end

-- handle mouse events:
function mouse(event, btn, x, y)
	-- clicking & dragging should draw trees into the field:
	if event == "down" or event == "drag" then
		field:set(math.random(), x / win.width * field.width, y / win.height * field.height)
	end
end
