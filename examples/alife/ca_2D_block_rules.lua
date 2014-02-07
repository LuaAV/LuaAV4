-- load in the "field2D" library module (from /modules/field2D.lua):
local field2D = require "field2D"
win = Window("CA block rules", 512, 512))

-- choose the size of the field
local dimx = win.width/2
local dimy = win.height/2

-- allocate the field
local field = field2D.new(dimx, dimy)

math.randomseed(os.time())

-- create a function to return either 0 or 1
function initialize() 
	if math.random() < 0.001 then 
		return 1
	else
		return 0
	end
end

field:set(initialize)

-- many different block rule possibilities:

function bbm (NW, NE, SE, SW)
	if NW == 1 and NE == 0 and SE == 0 and SW == 0 then 
		-- state 1 -> state 8:
		return 0, 0, 1, 0 
	elseif NW == 0 and NE == 1 and SE == 0 and SW == 0 then 
		-- state 2 -> state 4:
		return 0, 0, 0, 1 
	elseif NW == 0 and NE == 0 and SE == 0 and SW == 1 then 
		-- state 4 -> state 2:
		return 0, 1, 0, 0 
	elseif NW == 0 and NE == 1 and SE == 0 and SW == 1 then 
		-- state 6 -> state 9:
		return 1, 0, 1, 0 
	elseif NW == 0 and NE == 0 and SE == 1 and SW == 0 then 
		-- state 8 -> state 1:
		return 1, 0, 0, 0 
	elseif NW == 1 and NE == 0 and SE == 1 and SW == 0 then 
		-- state 9 -> state 6:
		return 0, 1, 0, 1 
	else
		-- no change:
		return NW, NE, SE, SW 
	end
end

function bouncegas (NW, NE, SE, SW)
	if NW == 1 and NE == 0 and SE == 0 and SW == 0 then 
		-- state 1 -> state 8:
		return 0, 0, 1, 0 
	elseif NW == 0 and NE == 1 and SE == 0 and SW == 0 then 
		-- state 2 -> state 4:
		return 0, 0, 0, 1 
	elseif NW == 0 and NE == 0 and SE == 0 and SW == 1 then 
		-- state 4 -> state 2:
		return 0, 1, 0, 0 
	elseif NW == 0 and NE == 1 and SE == 0 and SW == 1 then 
		-- state 6 -> state 9:
		return 1, 0, 1, 0 
	elseif NW == 1 and NE == 1 and SE == 0 and SW == 1 then 
		-- state 7 -> state 14:
		return 0, 1, 1, 1 
	elseif NW == 0 and NE == 0 and SE == 1 and SW == 0 then 
		-- state 8 -> state 1:
		return 1, 0, 0, 0 
	elseif NW == 1 and NE == 0 and SE == 1 and SW == 0 then 
		-- state 9 -> state 6:
		return 0, 1, 0, 1 
	elseif NW == 1 and NE == 1 and SE == 1 and SW == 0 then 
		-- state 11 -> state 13:
		return 1, 0, 1, 1 
	elseif NW == 1 and NE == 0 and SE == 1 and SW == 1 then 
		-- state 13 -> state 11:
		return 1, 1, 1, 0 
	elseif NW == 0 and NE == 1 and SE == 1 and SW == 1 then 
		-- state 14 -> state 7:
		return 1, 1, 0, 1 
	else
		-- no change:
		return NW, NE, SE, SW 
	end
end

function bouncegas2 (NW, NE, SE, SW)
	if NW == 1 and NE == 0 and SE == 0 and SW == 0 then 
		-- state 1 -> state 8:
		return 0, 0, 1, 0 
	elseif NW == 0 and NE == 1 and SE == 0 and SW == 0 then 
		-- state 2 -> state 4:
		return 0, 0, 0, 1 
	elseif NW == 1 and NE == 1 and SE == 0 and SW == 0 then 
		-- state 3 -> state 12:
		return 0, 0, 1, 1 
	elseif NW == 0 and NE == 0 and SE == 0 and SW == 1 then 
		-- state 4 -> state 2:
		return 0, 1, 0, 0 
	elseif NW == 1 and NE == 0 and SE == 0 and SW == 1 then 
		-- state 5 -> state 10:
		return 0, 1, 1, 0 
	elseif NW == 0 and NE == 1 and SE == 0 and SW == 1 then 
		-- state 6 -> state 9:
		return 1, 0, 1, 0 
	elseif NW == 0 and NE == 0 and SE == 1 and SW == 0 then 
		-- state 8 -> state 1:
		return 1, 0, 0, 0 
	elseif NW == 1 and NE == 0 and SE == 1 and SW == 0 then 
		-- state 9 -> state 6:
		return 0, 1, 0, 1 
	elseif NW == 0 and NE == 1 and SE == 1 and SW == 0 then 
		-- state 10 -> state 5:
		return 1, 0, 0, 1 
	elseif NW == 0 and NE == 0 and SE == 1 and SW == 1 then 
		-- state 12 -> state 3:
		return 1, 1, 0, 0 
	else
		-- no change:
		return NW, NE, SE, SW 
	end
end

function critters (NW, NE, SE, SW)
	if NW == 0 and NE == 0 and SE == 0 and SW == 0 then 
		-- state 0 -> state 15:
		return 1, 1, 1, 1 
	elseif NW == 1 and NE == 0 and SE == 0 and SW == 0 then 
		-- state 1 -> state 14:
		return 0, 1, 1, 1 
	elseif NW == 0 and NE == 1 and SE == 0 and SW == 0 then 
		-- state 2 -> state 13:
		return 1, 0, 1, 1 
	elseif NW == 0 and NE == 0 and SE == 0 and SW == 1 then 
		-- state 4 -> state 11:
		return 1, 1, 1, 0 
	elseif NW == 1 and NE == 1 and SE == 0 and SW == 1 then 
		-- state 7 -> state 1:
		return 1, 0, 0, 0 
	elseif NW == 0 and NE == 0 and SE == 1 and SW == 0 then 
		-- state 8 -> state 7:
		return 1, 1, 0, 1 
	elseif NW == 1 and NE == 1 and SE == 1 and SW == 0 then 
		-- state 11 -> state 2:
		return 0, 1, 0, 0 
	elseif NW == 1 and NE == 0 and SE == 1 and SW == 1 then 
		-- state 13 -> state 4:
		return 0, 0, 0, 1 
	elseif NW == 0 and NE == 1 and SE == 1 and SW == 1 then 
		-- state 14 -> state 8:
		return 0, 0, 1, 0 
	elseif NW == 1 and NE == 1 and SE == 1 and SW == 1 then 
		-- state 15 -> state 0:
		return 0, 0, 0, 0 
	else
		-- no change:
		return NW, NE, SE, SW 
	end
end

function hppgas (NW, NE, SE, SW)
	if NW == 1 and NE == 0 and SE == 0 and SW == 0 then 
		-- state 1 -> state 8:
		return 0, 0, 1, 0 
	elseif NW == 0 and NE == 1 and SE == 0 and SW == 0 then 
		-- state 2 -> state 4:
		return 0, 0, 0, 1 
	elseif NW == 1 and NE == 1 and SE == 0 and SW == 0 then 
		-- state 3 -> state 12:
		return 0, 0, 1, 1 
	elseif NW == 0 and NE == 0 and SE == 0 and SW == 1 then 
		-- state 4 -> state 2:
		return 0, 1, 0, 0 
	elseif NW == 1 and NE == 0 and SE == 0 and SW == 1 then 
		-- state 5 -> state 10:
		return 0, 1, 1, 0 
	elseif NW == 0 and NE == 1 and SE == 0 and SW == 1 then 
		-- state 6 -> state 9:
		return 1, 0, 1, 0 
	elseif NW == 1 and NE == 1 and SE == 0 and SW == 1 then 
		-- state 7 -> state 14:
		return 0, 1, 1, 1 
	elseif NW == 0 and NE == 0 and SE == 1 and SW == 0 then 
		-- state 8 -> state 1:
		return 1, 0, 0, 0 
	elseif NW == 1 and NE == 0 and SE == 1 and SW == 0 then 
		-- state 9 -> state 6:
		return 0, 1, 0, 1 
	elseif NW == 0 and NE == 1 and SE == 1 and SW == 0 then 
		-- state 10 -> state 5:
		return 1, 0, 0, 1 
	elseif NW == 1 and NE == 1 and SE == 1 and SW == 0 then 
		-- state 11 -> state 13:
		return 1, 0, 1, 1 
	elseif NW == 0 and NE == 0 and SE == 1 and SW == 1 then 
		-- state 12 -> state 3:
		return 1, 1, 0, 0 
	elseif NW == 1 and NE == 0 and SE == 1 and SW == 1 then 
		-- state 13 -> state 11:
		return 1, 1, 1, 0 
	elseif NW == 0 and NE == 1 and SE == 1 and SW == 1 then 
		-- state 14 -> state 7:
		return 1, 1, 0, 1 
	else
		-- no change:
		return NW, NE, SE, SW 
	end
end

function rotations (NW, NE, SE, SW)
	if NW == 1 and NE == 0 and SE == 0 and SW == 0 then 
		-- state 1 -> state 2:
		return 0, 1, 0, 0 
	elseif NW == 0 and NE == 1 and SE == 0 and SW == 0 then 
		-- state 2 -> state 8:
		return 0, 0, 1, 0 
	elseif NW == 1 and NE == 1 and SE == 0 and SW == 0 then 
		-- state 3 -> state 12:
		return 0, 0, 1, 1 
	elseif NW == 0 and NE == 0 and SE == 0 and SW == 1 then 
		-- state 4 -> state 1:
		return 1, 0, 0, 0 
	elseif NW == 1 and NE == 0 and SE == 0 and SW == 1 then 
		-- state 5 -> state 10:
		return 0, 1, 1, 0 
	elseif NW == 0 and NE == 1 and SE == 0 and SW == 1 then 
		-- state 6 -> state 9:
		return 1, 0, 1, 0 
	elseif NW == 1 and NE == 1 and SE == 0 and SW == 1 then 
		-- state 7 -> state 11:
		return 1, 1, 1, 0 
	elseif NW == 0 and NE == 0 and SE == 1 and SW == 0 then 
		-- state 8 -> state 4:
		return 0, 0, 0, 1 
	elseif NW == 1 and NE == 0 and SE == 1 and SW == 0 then 
		-- state 9 -> state 6:
		return 0, 1, 0, 1 
	elseif NW == 0 and NE == 1 and SE == 1 and SW == 0 then 
		-- state 10 -> state 5:
		return 1, 0, 0, 1 
	elseif NW == 1 and NE == 1 and SE == 1 and SW == 0 then 
		-- state 11 -> state 14:
		return 0, 1, 1, 1 
	elseif NW == 0 and NE == 0 and SE == 1 and SW == 1 then 
		-- state 12 -> state 3:
		return 1, 1, 0, 0 
	elseif NW == 1 and NE == 0 and SE == 1 and SW == 1 then 
		-- state 13 -> state 7:
		return 1, 1, 0, 1 
	elseif NW == 0 and NE == 1 and SE == 1 and SW == 1 then 
		-- state 14 -> state 13:
		return 1, 0, 1, 1 
	else
		-- no change:
		return NW, NE, SE, SW 
	end
end

function rotations2 (NW, NE, SE, SW)
	if NW == 1 and NE == 0 and SE == 0 and SW == 0 then 
		-- state 1 -> state 2:
		return 0, 1, 0, 0 
	elseif NW == 0 and NE == 1 and SE == 0 and SW == 0 then 
		-- state 2 -> state 8:
		return 0, 0, 1, 0 
	elseif NW == 1 and NE == 1 and SE == 0 and SW == 0 then 
		-- state 3 -> state 12:
		return 0, 0, 1, 1 
	elseif NW == 0 and NE == 0 and SE == 0 and SW == 1 then 
		-- state 4 -> state 1:
		return 1, 0, 0, 0 
	elseif NW == 1 and NE == 0 and SE == 0 and SW == 1 then 
		-- state 5 -> state 10:
		return 0, 1, 1, 0 
	elseif NW == 0 and NE == 1 and SE == 0 and SW == 1 then 
		-- state 6 -> state 9:
		return 1, 0, 1, 0 
	elseif NW == 1 and NE == 1 and SE == 0 and SW == 1 then 
		-- state 7 -> state 13:
		return 1, 0, 1, 1 
	elseif NW == 0 and NE == 0 and SE == 1 and SW == 0 then 
		-- state 8 -> state 4:
		return 0, 0, 0, 1 
	elseif NW == 1 and NE == 0 and SE == 1 and SW == 0 then 
		-- state 9 -> state 6:
		return 0, 1, 0, 1 
	elseif NW == 0 and NE == 1 and SE == 1 and SW == 0 then 
		-- state 10 -> state 5:
		return 1, 0, 0, 1 
	elseif NW == 1 and NE == 1 and SE == 1 and SW == 0 then 
		-- state 11 -> state 7:
		return 1, 1, 0, 1 
	elseif NW == 0 and NE == 0 and SE == 1 and SW == 1 then 
		-- state 12 -> state 3:
		return 1, 1, 0, 0 
	elseif NW == 1 and NE == 0 and SE == 1 and SW == 1 then 
		-- state 13 -> state 14:
		return 0, 1, 1, 1 
	elseif NW == 0 and NE == 1 and SE == 1 and SW == 1 then 
		-- state 14 -> state 11:
		return 1, 1, 1, 0 
	else
		-- no change:
		return NW, NE, SE, SW 
	end
end

function rotations3 (NW, NE, SE, SW)
	if NW == 1 and NE == 0 and SE == 0 and SW == 0 then 
		-- state 1 -> state 4:
		return 0, 0, 0, 1 
	elseif NW == 0 and NE == 1 and SE == 0 and SW == 0 then 
		-- state 2 -> state 1:
		return 1, 0, 0, 0 
	elseif NW == 1 and NE == 1 and SE == 0 and SW == 0 then 
		-- state 3 -> state 10:
		return 0, 1, 1, 0 
	elseif NW == 0 and NE == 0 and SE == 0 and SW == 1 then 
		-- state 4 -> state 8:
		return 0, 0, 1, 0 
	elseif NW == 1 and NE == 0 and SE == 0 and SW == 1 then 
		-- state 5 -> state 3:
		return 1, 1, 0, 0 
	elseif NW == 0 and NE == 1 and SE == 0 and SW == 1 then 
		-- state 6 -> state 9:
		return 1, 0, 1, 0 
	elseif NW == 1 and NE == 1 and SE == 0 and SW == 1 then 
		-- state 7 -> state 11:
		return 1, 1, 1, 0 
	elseif NW == 0 and NE == 0 and SE == 1 and SW == 0 then 
		-- state 8 -> state 2:
		return 0, 1, 0, 0 
	elseif NW == 1 and NE == 0 and SE == 1 and SW == 0 then 
		-- state 9 -> state 6:
		return 0, 1, 0, 1 
	elseif NW == 0 and NE == 1 and SE == 1 and SW == 0 then 
		-- state 10 -> state 12:
		return 0, 0, 1, 1 
	elseif NW == 1 and NE == 1 and SE == 1 and SW == 0 then 
		-- state 11 -> state 14:
		return 0, 1, 1, 1 
	elseif NW == 0 and NE == 0 and SE == 1 and SW == 1 then 
		-- state 12 -> state 5:
		return 1, 0, 0, 1 
	elseif NW == 1 and NE == 0 and SE == 1 and SW == 1 then 
		-- state 13 -> state 7:
		return 1, 1, 0, 1 
	elseif NW == 0 and NE == 1 and SE == 1 and SW == 1 then 
		-- state 14 -> state 13:
		return 1, 0, 1, 1 
	else
		-- no change:
		return NW, NE, SE, SW 
	end
end

function rotations4 (NW, NE, SE, SW)
	if NW == 1 and NE == 0 and SE == 0 and SW == 0 then 
		-- state 1 -> state 4:
		return 0, 0, 0, 1 
	elseif NW == 0 and NE == 1 and SE == 0 and SW == 0 then 
		-- state 2 -> state 1:
		return 1, 0, 0, 0 
	elseif NW == 1 and NE == 1 and SE == 0 and SW == 0 then 
		-- state 3 -> state 12:
		return 0, 0, 1, 1 
	elseif NW == 0 and NE == 0 and SE == 0 and SW == 1 then 
		-- state 4 -> state 8:
		return 0, 0, 1, 0 
	elseif NW == 1 and NE == 0 and SE == 0 and SW == 1 then 
		-- state 5 -> state 10:
		return 0, 1, 1, 0 
	elseif NW == 1 and NE == 1 and SE == 0 and SW == 1 then 
		-- state 7 -> state 14:
		return 0, 1, 1, 1 
	elseif NW == 0 and NE == 0 and SE == 1 and SW == 0 then 
		-- state 8 -> state 2:
		return 0, 1, 0, 0 
	elseif NW == 0 and NE == 1 and SE == 1 and SW == 0 then 
		-- state 10 -> state 5:
		return 1, 0, 0, 1 
	elseif NW == 1 and NE == 1 and SE == 1 and SW == 0 then 
		-- state 11 -> state 13:
		return 1, 0, 1, 1 
	elseif NW == 0 and NE == 0 and SE == 1 and SW == 1 then 
		-- state 12 -> state 3:
		return 1, 1, 0, 0 
	elseif NW == 1 and NE == 0 and SE == 1 and SW == 1 then 
		-- state 13 -> state 11:
		return 1, 1, 1, 0 
	elseif NW == 0 and NE == 1 and SE == 1 and SW == 1 then 
		-- state 14 -> state 7:
		return 1, 1, 0, 1 
	else
		-- no change:
		return NW, NE, SE, SW 
	end
end

function sand (NW, NE, SE, SW)
	if NW == 1 and NE == 0 and SE == 0 and SW == 0 then 
		-- state 1 -> state 4:
		return 0, 0, 0, 1 
	elseif NW == 0 and NE == 1 and SE == 0 and SW == 0 then 
		-- state 2 -> state 8:
		return 0, 0, 1, 0 
	elseif NW == 1 and NE == 1 and SE == 0 and SW == 0 then 
		-- state 3 -> state 12:
		return 0, 0, 1, 1 
	elseif NW == 1 and NE == 0 and SE == 0 and SW == 1 then 
		-- state 5 -> state 12:
		return 0, 0, 1, 1 
	elseif NW == 0 and NE == 1 and SE == 0 and SW == 1 then 
		-- state 6 -> state 12:
		return 0, 0, 1, 1 
	elseif NW == 1 and NE == 1 and SE == 0 and SW == 1 then 
		-- state 7 -> state 13:
		return 1, 0, 1, 1 
	elseif NW == 1 and NE == 0 and SE == 1 and SW == 0 then 
		-- state 9 -> state 12:
		return 0, 0, 1, 1 
	elseif NW == 0 and NE == 1 and SE == 1 and SW == 0 then 
		-- state 10 -> state 12:
		return 0, 0, 1, 1 
	elseif NW == 1 and NE == 1 and SE == 1 and SW == 0 then 
		-- state 11 -> state 14:
		return 0, 1, 1, 1 
	else
		-- no change:
		return NW, NE, SE, SW 
	end
end

function stringthing (NW, NE, SE, SW)
	if NW == 1 and NE == 1 and SE == 0 and SW == 0 then 
		-- state 3 -> state 12:
		return 0, 0, 1, 1 
	elseif NW == 1 and NE == 0 and SE == 0 and SW == 1 then 
		-- state 5 -> state 10:
		return 0, 1, 1, 0 
	elseif NW == 0 and NE == 1 and SE == 0 and SW == 1 then 
		-- state 6 -> state 9:
		return 1, 0, 1, 0 
	elseif NW == 1 and NE == 0 and SE == 1 and SW == 0 then 
		-- state 9 -> state 6:
		return 0, 1, 0, 1 
	elseif NW == 0 and NE == 1 and SE == 1 and SW == 0 then 
		-- state 10 -> state 5:
		return 1, 0, 0, 1 
	elseif NW == 0 and NE == 0 and SE == 1 and SW == 1 then 
		-- state 12 -> state 3:
		return 1, 1, 0, 0 
	else
		-- no change:
		return NW, NE, SE, SW 
	end
end

function stringthing2 (NW, NE, SE, SW)
	if NW == 1 and NE == 1 and SE == 0 and SW == 0 then 
		-- state 3 -> state 12:
		return 0, 0, 1, 1 
	elseif NW == 1 and NE == 0 and SE == 0 and SW == 1 then 
		-- state 5 -> state 10:
		return 0, 1, 1, 0 
	elseif NW == 0 and NE == 1 and SE == 1 and SW == 0 then 
		-- state 10 -> state 5:
		return 1, 0, 0, 1 
	elseif NW == 0 and NE == 0 and SE == 1 and SW == 1 then 
		-- state 12 -> state 3:
		return 1, 1, 0, 0 
	else
		-- no change:
		return NW, NE, SE, SW 
	end
end

function swapondialog (NW, NE, SE, SW)
	if NW == 1 and NE == 0 and SE == 0 and SW == 0 then 
		-- state 1 -> state 8:
		return 0, 0, 1, 0 
	elseif NW == 0 and NE == 1 and SE == 0 and SW == 0 then 
		-- state 2 -> state 4:
		return 0, 0, 0, 1 
	elseif NW == 1 and NE == 1 and SE == 0 and SW == 0 then 
		-- state 3 -> state 12:
		return 0, 0, 1, 1 
	elseif NW == 0 and NE == 0 and SE == 0 and SW == 1 then 
		-- state 4 -> state 2:
		return 0, 1, 0, 0 
	elseif NW == 1 and NE == 0 and SE == 0 and SW == 1 then 
		-- state 5 -> state 10:
		return 0, 1, 1, 0 
	elseif NW == 1 and NE == 1 and SE == 0 and SW == 1 then 
		-- state 7 -> state 14:
		return 0, 1, 1, 1 
	elseif NW == 0 and NE == 0 and SE == 1 and SW == 0 then 
		-- state 8 -> state 1:
		return 1, 0, 0, 0 
	elseif NW == 0 and NE == 1 and SE == 1 and SW == 0 then 
		-- state 10 -> state 5:
		return 1, 0, 0, 1 
	elseif NW == 1 and NE == 1 and SE == 1 and SW == 0 then 
		-- state 11 -> state 13:
		return 1, 0, 1, 1 
	elseif NW == 0 and NE == 0 and SE == 1 and SW == 1 then 
		-- state 12 -> state 3:
		return 1, 1, 0, 0 
	elseif NW == 1 and NE == 0 and SE == 1 and SW == 1 then 
		-- state 13 -> state 11:
		return 1, 1, 1, 0 
	elseif NW == 0 and NE == 1 and SE == 1 and SW == 1 then 
		-- state 14 -> state 7:
		return 1, 1, 0, 1 
	else
		-- no change:
		return NW, NE, SE, SW 
	end
end

function tron (NW, NE, SE, SW)
	if NW == 0 and NE == 0 and SE == 0 and SW == 0 then 
		-- state 0 -> state 15:
		return 1, 1, 1, 1 
	elseif NW == 1 and NE == 1 and SE == 1 and SW == 1 then 
		-- state 15 -> state 0:
		return 0, 0, 0, 0 
	else
		-- no change:
		return NW, NE, SE, SW 
	end
end

--rule = bbm; boundaryvalue = 1
rule = critters; boundaryvalue = 1
--rule = stringthing; boundaryvalue = 1
--rule = stringthing2; boundaryvalue = 1
--rule = tron; boundaryvalue = 0

-- update the state of the scene (toggle this on and off with spacebar):
function update(dt)
	
	-- perform even-index blocks:
	for x = 0, field.width-1, 2 do
		for y = 0, field.height-1, 2 do
			local NW = field:get(x  , y  ) 
			local NE = field:get(x+1, y  ) 
			local SE = field:get(x+1, y+1) 
			local SW = field:get(x  , y+1) 
			
			NW, NE, SE, SW = rule(NW, NE, SE, SW)
			
			field:set(NW, x  , y  ) 
			field:set(NE, x+1, y  ) 
			field:set(SE, x+1, y+1) 
			field:set(SW, x  , y+1)
		end
	end
	
	-- perform odd-index blocks:
	for x = 1, field.width-1, 2 do
		for y = 1, field.height-1, 2 do
			local NW = field:get(x  , y  ) 
			local NE = field:get(x+1, y  ) 
			local SE = field:get(x+1, y+1) 
			local SW = field:get(x  , y+1) 
			
			NW, NE, SE, SW = rule(NW, NE, SE, SW)
			
			field:set(NW, x  , y  ) 
			field:set(NE, x+1, y  ) 
			field:set(SE, x+1, y+1) 
			field:set(SW, x  , y+1)
		end
	end
	
	-- apply boundary:
	for x = 0, field.width-1 do
		field:set(boundaryvalue, x, 0)
		field:set(boundaryvalue, x, field.height-1)
	end
	for y = 0, field.height-1 do
		field:set(boundaryvalue, 0, y)
		field:set(boundaryvalue, field.width - 1, y)
	end
end

-- how to render the scene (toggle fullscreen with the Esc key):
function draw()	
	-- draw the field:
	field:draw()
end

function key(e, key)
	if key == "c" then
		field:set(clear)
	elseif key == "r" then
		field:set(initialize)
	end
end

function mouse(e, b, x, y)
	if e == "down" or e == "drag" then
		field:set(1, x / win.width * field.width, y / win.height * field.height)
	end
end


-- how I generated these rules:
--[[

function makerule(rule, name)
	local states = { 
	[0]={ 0, 0, 0, 0 }, { 1, 0, 0, 0 }, { 0, 1, 0, 0 }, { 1, 1, 0, 0 },
		{ 0, 0, 0, 1 }, { 1, 0, 0, 1 }, { 0, 1, 0, 1 }, { 1, 1, 0, 1 },
		{ 0, 0, 1, 0 }, { 1, 0, 1, 0 }, { 0, 1, 1, 0 }, { 1, 1, 1, 0 },
		{ 0, 0, 1, 1 }, { 1, 0, 1, 1 }, { 0, 1, 1, 1 }, { 1, 1, 1, 1 },
	}
	
	local code = {
		string.format("\nfunction %s (NW, NE, SE, SW)\n\t", name)
	}
	local i = 0
	for state in rule:gmatch("(%d+)") do
		input, output = states[tonumber(i)], states[tonumber(state)]
		
		if input ~= output then
			
			local condition = string.format("NW == %s and NE == %s and SE == %s and SW == %s", unpack(input))
			local result = string.format("%s, %s, %s, %s", unpack(output))
			
			code[#code+1] = string.format("if %s then \n\t\t-- state %d -> state %d:\n\t\treturn %s \n\telse", condition, i, state, result)
		end
		i = i + 1
	end
	code[#code+1] = "\n\t\t-- no change:\n\t\treturn NW, NE, SE, SW \n\tend\nend"
	print( table.concat(code) )
end

-- see http://psoup.math.wisc.edu/mcell/rullex_marg.html
makerule("0;8;4;3;2;5;9;7; 1;6;10;11;12;13;14;15", "bbm")
makerule("0;8;4;3;2;5;9;14; 1;6;10;13;12;11;7;15", "bouncegas")
makerule("0;8;4;12;2;10;9; 7;1;6;5;11;3;13;14;15", "bouncegas2")
makerule("15;14;13;3;11;5; 6;1;7;9;10;2;12;4;8;0", "critters")
makerule("0;8;4;12;2;10;9; 14;1;6;5;13;3;11;7;15", "hppgas")
makerule("0;2;8;12;1;10;9; 11;4;6;5;14;3;7;13;15", "rotations")
makerule("0;2;8;12;1;10;9; 13;4;6;5;7;3;14;11;15", "rotations2")
makerule("0;4;1;10;8;3;9;11; 2;6;12;14;5;7;13;15", "rotations3")
makerule("0;4;1;12;8;10;6;14; 2;9;5;13;3;11;7;15", "rotations4")
makerule("0;4;8;12;4;12;12;13; 8;12;12;14;12;13;14;15", "sand")
makerule("0;1;2;12;4;10;9;7;8; 6;5;11;3;13;14;15", "stringthing")
makerule("0;1;2;12;4;10;6;7;8; 9;5;11;3;13;14;15", "stringthing2")
makerule("0;8;4;12;2;10;6;14; 1;9;5;13;3;11;7;15", "swapondialog")
makerule("15;1;2;3;4;5;6;7;8; 9;10;11;12;13;14;0", "tron")
--]]