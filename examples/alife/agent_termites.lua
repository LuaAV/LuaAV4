local field2D = require "field2D"
local draw2D = require "draw2D"

win = Window("termites", 512, 512)

math.randomseed(os.time())

local dimx = 200
local dimy = dimx * 3/4
local chips = field2D(dimx, dimy)

-- try running this at 1000:
local iterations = 1
-- about 50-100 works well:
local numtermites = 1

-- initialize woodchips:
chips:set(function()
	if math.random() < 0.3 then 
		return 0.5
	else
		return 0
	end
end)

-- create agents:
local termites = {}

for i = 1, numtermites do
	local t = {
		x = math.random(dimx),
		y = math.random(dimy),
		direction = math.random() * math.pi * 2,
		chip = 0,
	}
	
	termites[#termites+1] = t
end

function update()
	for j = 1, iterations do
		for i, self in ipairs(termites) do
			
			local speed = 1
			local x = self.x + speed * math.cos(self.direction)
			local y = self.y + speed * math.sin(self.direction)
			-- wrap at limits:
			x = (x % dimx)
			y = (y % dimy)
			
			-- is this location occupied by a woodchip?
			local chip = chips:get(x, y)
			if chip > 0 then
				-- was I carrying?
				if self.chip > 0 then
					-- drop my chip where I currently am:
					chips:set(self.chip, self.x, self.y)
					self.chip = 0
					-- turn around:
					self.direction = self.direction + math.pi
				else
					-- pick it up:
					self.chip = chip
					chips:set(0, x, y)
					-- and move there (since it is now unoccupied):
					self.x = x
					self.y = y
					-- random turn:
					self.direction = self.direction + (math.random() - 0.5)
				end
			else
				-- move there
				self.x = x
				self.y = y
				-- random turn:
				self.direction = self.direction + (math.random() - 0.5)
			end
			
		end
	end
end

function draw()
	-- draw the chips:
	draw2D.color(1, 1, 1)
	chips:draw()
	
	---[[
	draw2D.scale(1/dimx, 1/dimy)
	
	-- draw the agents:
	for i, termite in ipairs(termites) do
		draw2D.push()
		draw2D.translate(termite.x, termite.y)
		if termite.chip > 0 then
			draw2D.color(1, 1, 0)
		else
			draw2D.color(1, 0, 0)
		end
		draw2D.rect(0, 0, 2)
		draw2D.pop()
	end
	--]]
end

