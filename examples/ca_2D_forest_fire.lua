-- load in the "field2D" library module (from /modules/field2D.lua):
local field2D = require "field2D"
win = Window("forest fire", 512, 512))

-- choose the size of the field
local dimx = win.width/2
local dimy = win.height/2

-- allocate the field
local field = field2D.new(dimx, dimy)

-- create a second field, to store the previous states of the cells:
local field_old = field2D.new(dimx, dimy)

-- three possible states:
local empty = 0
local tree = 0.5
local burning = 1

-- the chance of an empty cell regrowing trees by expansion:
local growth_probability = 1/100
-- the chance of an empty cell regrowing trees by random sporing:
local spore_probability = 1/100000 
-- the chance of lighting striking a cell:
local lightning_probability = 1/100000

function initialize()
	if math.random() < spore_probability then
		return tree
	end
end

-- use this to initialize the field:
field:set(initialize)

-- how to render the scene (toggle fullscreen with the Esc key):
function draw()	
	-- draw the field:
	field:draw()
end

-- the rule for an individual cell (at position x, y) in the field:
function forest_fire(x, y)

	-- check out the neighbors' previous states:
	local N  = field_old:get(x  , y+1)
	local NE = field_old:get(x+1, y+1)
	local E  = field_old:get(x+1, y  )
	local SE = field_old:get(x+1, y-1)
	local S  = field_old:get(x  , y-1)
	local SW = field_old:get(x-1, y-1)
	local W  = field_old:get(x-1, y  )
	local NW = field_old:get(x-1, y+1)
	
	-- true if any neighbor is a tree:
	local neartree = N == tree or E == tree 
				or W == tree or S == tree 
				or NE == tree or SE == tree 
				or NW == tree or SW == tree
	
	-- true if any neighbor is burning:
	local nearburning = N == burning or E == burning 
				or W == burning or S == burning 
				or NE == burning or SE == burning 
				or NW == burning or SW == burning
	
	-- check my own previous state:
	local C = field_old:get(x, y)
	
	if C == empty then
		-- are any neighbors trees?
		if neartree then			
			-- chance of regrowing:
			if math.random() < growth_probability then
				C = tree
			end
		elseif math.random() < spore_probability then
			-- smaller chance of propagation by seeding:
			C = tree
		end
	elseif C == tree then
		-- are any neighbors burning?
		if nearburning then
			-- if any neighbors are burning, start burning too:
			C = burning
		
		elseif math.random() < lightning_probability then		
			-- otherwise, there's a small chance of catching fire due to atmostpheric conditions:
			C = burning
		end
	elseif C == burning then
		-- a burning tree cell becomes an empty cell
		C = empty
	end 
	
	-- return the new state:
	return C
end

-- update the state of the scene (toggle this on and off with spacebar):
function update(dt)
	-- swap field and field_old:
	-- (field now becomes old, and the new field is ready to be written)
	field, field_old = field_old, field
	
	-- apply the game_of_life function to each cell of the field: 
	field:set(forest_fire)
end

-- handle keypress events:
function key(e, k)
	if k == "r" then
		-- apply the coin rule to all cells of the field (randomizes)
		field:set(initialize)
	end
end

-- handle mouse events:
function mouse(event, btn, x, y)
	-- clicking & dragging should draw trees into the field:
	if event == "down" or event == "drag" then
		field:set(tree, x / win.width * field.width, y / win.height * field.height)
	end
end
