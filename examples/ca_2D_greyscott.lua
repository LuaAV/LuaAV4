--[[

Based on the irreversible reactions
	
	U + 2V -> 3V
	V -> P 

The change in concentration du/dt and dv/dt are:

	Du nabla^2 u - uv^2 + F(1-u)
	Dv nabla^2 v + uv^2 - (F + k)v

Du, Dv, F and k are constants.

Du nabla^2 u and Dv nabla^2 v are diffusion terms, stating that u and v increase according to the Laplacian (variation in gradient). If U is higher in nearby areas, it will increase locally, and vice versa. 

The uv^2 components are the reaction rate, translated from U + 2V -> 3V above.

The F(1-u) is a replenishment term to maintain a steady concentration of U; and (F + k)v is the diminshment term, to prevent over-concentration of V. 

@see http://mrob.com/pub/comp/xmorphia/
@see http://arxiv.org/pdf/patt-sol/9304003.pdf

--]]

local field2D = require "field2D"
win = Window("greyscott", 512, 256)

math.randomseed(os.time())
local floor = math.floor
local sqrt, exp = math.sqrt, math.exp
local min, max = math.min, math.max
local sin, cos = math.sin, math.cos
local pi = math.pi

-- choose the size of the field
local dimx = 256
local dimy = dimx / 2
local xscale = 1/dimx
local yscale = 1/dimy

-- number of timesteps per frame
local steps = 10	

---- PARAMETERS ----
local ru = 0.082	-- rate of diffusion of U
local rv = 0.041	-- rate of diffusion of V
local speed = 1		-- length of a timestep in dt
-- spots:
local k, f = 0.064, 0.035
-- stripes:
local k, f = 0.06, 0.035
-- long stripes:
local k, f = 0.065, 0.056
-- lotus meshes
local k, f = 0.0613, 0.0600
-- dots and stripes:
local k, f = 0.064, 0.04
-- spiral waves
local k, f = 0.0475, 0.0118
-- various
--local k, f = 0.056, 0.098
--local k, f = 0.0550, 0.1020
--local k, f = 0.0523, 0.1100

-- vary k and f over space?
local spatialized = false
local kscale = 0.002
local fscale = 0.004

---- FIELDS ----
-- concentrations of chemicals U and V:
local U = field2D.new(dimx, dimy)
local V = field2D.new(dimx, dimy)

-- rates of change of concentrations of chemicals U and V:
local dU = field2D.new(dimx, dimy)
local dV = field2D.new(dimx, dimy)

---- INITIAL CONDITIONS ----
function reset_circle(d)
	dU:set(0)
	dV:set(0)
	
	for y = 0, dimy-1 do
		for x = 0, dimx-1 do
			-- convert to -1..1 ranges:
			local snx = (x / U.width)*2 - 1
			local sny = (y / U.height)*2 - 1
			local radius = sqrt(snx*snx + sny*sny)
			if radius < d * (0.5 + math.random()) then
				U:set(1, x, y)
				V:set(0, x, y)
			else
				U:set(0, x, y)
				V:set(1, x, y)
			end
		end
	end
end 

function reset_squares(count)
	count = count or 100
	
	U:set(function()
		return math.random()
	end)
	
	for i = 1, count do
		local x0 = math.random(dimx)
		local y0 = math.random(dimy)
		local x1 = x0 + math.random() * math.random(dimx / 10)
		local y1 = y0 + math.random() * math.random(dimx / 10)
		local value = math.random()
		for y = y0, y1 do
			for x = x0, x1 do
				--U:set(value, x, y)
			end
		end
		
		local x0 = math.random(dimx)
		local y0 = math.random(dimy)
		local x1 = x0 + math.random() * math.random(dimx / 10)
		local y1 = y0 + math.random() * math.random(dimx / 10)
		local value = math.random()
		for y = y0, y1 do
			for x = x0, x1 do
				V:set(value, x, y)
			end
		end
	end
end

reset_squares()

function update(dt)
	
	for i = 1, steps do
	
		for y = 0, dimy-1 do
			for x = 0, dimx-1 do
				local u = U:get(x, y)
				local v = V:get(x, y)
				
				-- compute the Laplacians of u and v
				local ddu = U:get(x, y-1) 
						  + U:get(x, y+1) 
						  + U:get(x+1, y) 
						  + U:get(x-1, y)
						  + U:get(x-1, y-1) * 0.5
						  + U:get(x+1, y-1) * 0.5
						  + U:get(x-1, y+1) * 0.5
						  + U:get(x+1, y+1) * 0.5
						  - 6 * u
				local ddv = V:get(x, y-1) 
						  + V:get(x, y+1) 
						  + V:get(x+1, y) 
						  + V:get(x-1, y)
						  + V:get(x-1, y-1) * 0.5
						  + V:get(x+1, y-1) * 0.5
						  + V:get(x-1, y+1) * 0.5
						  + V:get(x+1, y+1) * 0.5
						  - 6 * v
				-- the reaction term:
				local uvv = u*v*v
				
				local ff = f
				local kk = k
				if spatialized then
				
					-- get x, y in -0.5...0.5 range:
					local sx = (x * xscale) - 0.5
					local sy = (y * yscale) - 0.5
				
					kk = k + kscale * sx * 4
					ff = f + fscale * sy * 4
				end
				
				-- rates of change:
				local du = ru*ddu - uvv + ff*(1-u)
				local dv = rv*ddv + uvv - (ff+kk)*v
				
				dU:set(du, x, y)
				dV:set(dv, x, y)
			end
		end
		
		-- apply rates of change:
		for y = 0, dimy-1 do
			for x = 0, dimx-1 do
				local u = U:get(x, y)
				local v = V:get(x, y)
				local du = dU:get(x, y)
				local dv = dV:get(x, y)
				U:set(u + speed * du, x, y)
				V:set(v + speed * dv, x, y)
			end
		end
	end	
	
	if win.frame % 30 == 0 then 
		print("fps", floor(1/dt)) 
		print(string.format("k = %f, f = %f", k, f))
	end
end

local drawmode = "u"

function draw()
	if drawmode == "u" then
		U:drawHueRange(8)
	elseif drawmode == "v" then
		V:drawHueRange(8)
	end
end

function key(e, k)
	if k == "u" then
		drawmode = "u"
	elseif k == "v" then
		drawmode = "v"
	elseif k == "1" then
		-- spots:
		reset_circle(0.5)
		k, f = 0.064, 0.035
	elseif k == "2" then
		-- stripes:
		reset_circle(0.5)
		k, f = 0.06, 0.035
	elseif k == "3" then
		-- long stripes:
		reset_circle(0.5)
		k, f = 0.065, 0.056
	elseif k == "4" then
		-- dots and stripes:
		reset_circle(0.5)
		k, f = 0.064, 0.04
	elseif k == "5" then
		-- spiral waves
		reset_circle(0.5)
		k, f = 0.0475, 0.0118
	elseif k == "r" then
		reset_circle(0.5)
	elseif k == "c" then
		U:set(0)
		V:set(0)
	elseif k == "n" then
		U:set(function() return math.random() end)
		V:set(function() return math.random() < 0.1 and 1 or 0 end)
	elseif k == "m" then
		U:set(function() return 1 end)
		V:set(function() return math.random() < 0.1 and 1 or 0 end)
	elseif k == "q" then
		reset_squares()
	
	elseif k == "s" then
		spatialized = not spatialized
	end
end

local mx, my
function mouse(event, btn, x, y)
	x = x / win.width
	y = y / win.height
	if event == "down" then
		mx, my = x, y
	elseif event == "drag" then
		local dx, dy = x - mx, y - my
		-- adjust k and f:
		k = k - 4 * dx * kscale
		f = f - 4 * dy * fscale
		print(string.format("k = %f, f = %f", k, f))
		mx, my = x, y
	end
end
