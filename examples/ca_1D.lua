local field2D = require "field2D"
win = Window("CA rule 30", 512, 512))

-- allocate a 2D array:
local field = field2D.new(256, 256)

-- render it continually:
function draw()
	field:draw()
end

-- we will update one row at a time, reading from the past and writing to the future:
local future = 0
local past = 1

function reset()
	field:set(function(x, y)
		if y == past then
			return math.random(2) - 1
		else
			return 0
		end
	end)
end

-- call it now:
reset()

-- several possible transition rules
-- return new state in terms of Current, East and West states:

-- AKA the 'traffic' rule
function transition_rule_184(C, E, W)
	if C == 1 and E == 0 then
		C = 0
	elseif C == 0 and W == 1 then
		C = 1
	end
	return C
end

function transition_rule_110(C, E, W)
	if C == 1 and W == 1 and E == 1 then
		C = 0
	elseif C == 0 and E == 1 then
		C = 1
	end
	return C
end

function transition_rule_30(C, E, W)
	if C == 1 and W == 1 then
		C = 0
	elseif C == 0 then
		if W == 1 and E == 0 then
			C = 1
		elseif W == 0 and E == 1 then
			C = 1
		end
	end
	return C
end

-- apply one of these rules:
function update()
	-- for each cell in the row:
	for x = 0, field.width do
		 -- my old state:
		 local C = field:get(x, past)
		 -- my neighbor's old states:
		 local E = field:get(x - 1, past)
		 local W = field:get(x + 1, past)
		 
		 -- apply the chosen rule:
		 C = transition_rule_30(C, E, W)
		 
		 -- put this state into the future:
		 field:set(C, x, future)
	end
	
	-- now the future becomes the past:
	past = future
	-- and we get a new future:
	-- (modulo available memory)
	future = (past - 1) % field.height
end

-- reset:
function key(e, key)
	reset()
end
