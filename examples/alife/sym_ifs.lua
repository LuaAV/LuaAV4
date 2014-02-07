local draw2D = require "draw2D"
local vec2 = require "vec2"
win = Window()

-- create a few possible transformations:
-- (each one is a translate, rotate, scale sequence)
local f1 = function(p) return p:add(vec2(0, 0.2)):rotate(0.4):mul(0.3) end
local f2 = function(p) return p:add(vec2(0, 0.2)):rotate(-0.4):mul(0.3) end
local f3 = function(p) return p:add(vec2(0, 0.6)):rotate(0.05):mul(0.6) end

-- store these in a list:
local transforms = {
	f1, 
	f2,  
	f3, f3, f3,	-- give greater bias to rule 3
}

-- Iterated functional systems:
-- iterate many times:
--		pick a random point
-- 		iterate many times:
-- 			pick a transformation at random (according to weights)
-- 			modify the point by the transformation
--		plot the point
function plot()
	-- draw many points:
	for i = 1, 1000 do
		-- pick a random point (anywhere at all!)
		local p = vec2(math.random(), math.random())
		-- for a number of iterations (at least 100)
		for j = 1, 100 + math.random(1000) do
			-- pick a random rule
			local rule = transforms[math.random(#transforms)]
			-- apply to the point
			p = rule(p)
		end
		-- draw the result
		draw2D.point(p.x, p.y)
	end
end

function draw()
	draw2D.translate(0.5, 0.0)
	plot()
end



