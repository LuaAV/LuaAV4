local draw2D = require "draw2D"
local gl = require "gl"
local vec2 = require "vec2"
local win = Window()

-- make each run different:
math.randomseed(os.time())

-- a useful function: generate random number between -1 and 1:
local function srandom() return math.random() * 2 - 1 end

local numboids = 100
local viewrange = 0.1
local closerange = viewrange * 0.25
local copyfactor = 10
local centerfactor = 0.02
local avoidfactor = 10
local smooth = 0.1
local speed = 0.003


-- a place to hold the active boids:
local boids = {}

for i = 1, numboids do
	local b = {
		-- current boid position:
		pos = vec2(math.random(), math.random()),
		-- current boid velocity (absolute coordinates):
		vel = vec2(speed * srandom(), speed * srandom()),
		
		-- total influence on velocity (absolute coordinates):
		influence = vec2(),
		-- components of influence (retained for smoothing over time):
		copy = vec2(),
		avoid = vec2(),
		center = vec2(),
		
		-- current direction (used for rendering and wandering):
		direction = math.pi * i / numboids, 
		-- each boid may vary slightly in speed:
		speed = speed * (1 + 0.1*srandom()),
		
		-- relative positions of neighbors:
		relatives = {},
	}
	boids[#boids+1] = b
end

function update(dt)	

	-- apply movement in a separate step 
	-- (to avoid artifacts from sequential order updates)
	for i, self in ipairs(boids) do
		-- make velocity gradually similar to influence:
		self.vel:lerp(self.influence, smooth)
		
		-- accumulate velocity onto position (integration):
		self.pos:add(self.vel)
		
		-- stay in world:
		self.pos:mod(1)
		
		-- derive current heading from velocity (for rendering)
		local r, t = self.vel:polar()
		self.direction = t
	end	

	
	-- update sensors in a separate step
	-- (to avoid artifacts from sequential order updates)
	for i, self in ipairs(boids) do
		-- the influences of nearby boids:
		-- move away from any boids that are too close
		local avoid = vec2()
		-- move in the same way as most boids we can see
		local copy = vec2()
		-- move toward the hightest boid density we can see
		local center = vec2()
		-- which boids we can see:
		local relatives = {}	
		-- iterate all boids to determine which other boids we can see:
		for j, near in ipairs(boids) do
			-- don't compare ourself:
			if near ~= self then
				-- get boid position relative to us:
				local rel = near.pos - self.pos
				-- shift the relative position into the [-0.5, 0.5] range
				-- (this is essential because of the toroidal world space)
				rel:relativewrap()
				-- in front or behind? (assuming self.vel is also our direction of view)
				-- positive dot product implies acute angle (i.e. in front of us)
				local dot = self.vel:dot(rel)
				if dot > 0 then
					-- is the neighbor close enough?
					local distance = rel:length()
					if distance < viewrange then
						-- yes, this is a visible neighbor.
						-- store in relatives (for rendering purposes):
						relatives[#relatives+1] = rel
						-- accumulate current center and copy influences:
						center:add(rel)
						copy:add(near.vel)
						-- if the neigbhor is too near, 
						local close = (closerange/distance) - 1
						if close > 0 then
							-- apply to avoidance influence (negative)
							avoid:sub(rel * close)
						end
					end
				end
			end
		end	
		-- store list of neighbors in the boid for rendering purposes:
		self.relatives = relatives 	
		
		-- do I have any visible neighbors?
		local num_near = #relatives
		if num_near > 0 then
			-- apply the avoidance weight
			avoid:mul(avoidfactor)
			-- scale the copy influence (divide num_near for average; scale by weight)
			copy:mul(copyfactor / num_near)
			-- get the average center influece:
			center:mul(1 / num_near)
			-- then normalize (we only care about direction) and scale by weight:
			center:normalize():mul(centerfactor)
			
			-- smooth these influences over time (not essential, but a lot nicer):
			self.avoid:lerp(avoid, smooth)
			self.center:lerp(center, smooth) 
			self.copy:lerp(copy, smooth)
			
			-- determine the total 'influence':
			self.influence = (self.copy + self.avoid + self.center)
			-- constrain it to the current speed:
			self.influence:normalize():mul(self.speed)
			
		else
			-- nobody in view, so wander freely:
			self.direction = self.direction + 0.1 * srandom()
			self.influence = vec2.fromPolar(self.speed, self.direction)
		end
	end	
	--]]
end

local showneighbors = true
local showinfluences = true
local showview = true

function draw()	
	draw2D.blend()
	draw2D.color(0, 0.3, 0)
	
	-- draw lines between boids and the neighbors they can see:
	if showneighbors then
		for i, self in ipairs(boids) do
			for j, p in ipairs(self.relatives) do
				draw2D.color(0.7, 0, 0.7)
				draw2D.line(self.pos.x, self.pos.y, self.pos.x + p.x, self.pos.y + p.y)	
			end
		end	
	end
	
	-- draw the boids:
	for i, self in ipairs(boids) do
		draw2D.push()
		draw2D.translate(self.pos.x, self.pos.y)
		
		-- show the current influences of this boid:
		if showinfluences and #self.relatives > 0 then
			-- avoid
			draw2D.color(1, 0, 0)
			draw2D.line(0, 0, self.avoid.x, self.avoid.y)			
			
			-- copy
			draw2D.color(1, 1, 0)
			draw2D.line(0, 0, self.copy.x, self.copy.y)	
			
			-- center
			draw2D.color(0, 1, 1)
			draw2D.line(0, 0, self.center.x, self.center.y)	
			
			-- total influence
			draw2D.color(0, 1, 0)
			draw2D.line(0, 0, self.influence.x, self.influence.y)	
		end
		
		draw2D.rotate(self.direction)
		-- draw view:
		if showview then
			draw2D.color(1, 1, 1, 0.1)
			draw2D.arc(0, 0, -math.pi/2, math.pi/2, viewrange)
		end
		
		draw2D.scale(0.01)
		-- draw body:
		draw2D.color(1, 1, 1)
		draw2D.line(1, 0, -2, 0)
		draw2D.rect(0.5, 0, 1)
		
		draw2D.pop()
	end	
end

function key(e, k)
	if e == "down" then
		if k == "i" then
			showinfluences = not showinfluences
		elseif k == "n" then
			showneighbors = not showneighbors
		elseif k == "v" then
			showview = not showview
		end
	end
end