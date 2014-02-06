local g = require "draw2D"
win = Window()

local lightx = 0.5
local lighty = 0.45

local vehicle = {
	x = 0.5, 
	y = 0.5,
	angle = 0,
	
	sensor_left = 0,
	sensor_left_x = 0.02,
	sensor_left_y =  0.02,
	
	sensor_right = 0,
	sensor_right_x = 0.02,
	sensor_right_y = -0.02,
	
	motor_left = 0.,
	motor_right = 0.,
}

function vehicle:update(dt)
	
	-- rotation is difference of wheels
	self.angle = self.angle + dt * (self.motor_left - self.motor_right) * 60
	-- forward movement is average of wheels
	local speed = dt * (self.motor_right + self.motor_left) * 0.5
	self.x = self.x + speed * math.cos(self.angle)
	self.y = self.y + speed * math.sin(self.angle)
	
	-- keep in world:
	self.x = self.x % 1
	self.y = self.y % 1
	
	-- get actual sensor locations:
	local sensitivity = 0.05
	
	local cosx = self.sensor_left_x * math.cos(self.angle)
	local siny = self.sensor_left_y * math.sin(self.angle)
	local sinx = self.sensor_left_x * math.sin(self.angle)
	local cosy = self.sensor_left_y * math.cos(self.angle)
	local sx = self.x + cosx + siny
	local sy = self.y + sinx - cosy
	--g.line(lightx, lighty, sx, sy)
	local rx = lightx - sx
	local ry = lighty - sy
	self.sensor_left = sensitivity / (sensitivity + (rx*rx + ry*ry))	

	local cosx = self.sensor_right_x * math.cos(self.angle)
	local siny = self.sensor_right_y * math.sin(self.angle)
	local sinx = self.sensor_right_x * math.sin(self.angle)
	local cosy = self.sensor_right_y * math.cos(self.angle)
	local sx = self.x + cosx + siny
	local sy = self.y + sinx - cosy
	--g.line(lightx, lighty, sx, sy)
	local rx = lightx - sx
	local ry = lighty - sy
	self.sensor_right = sensitivity / (sensitivity + (rx*rx + ry*ry))

		
	-- update motors:
	self.motor_left = self.sensor_right
	self.motor_right = self.sensor_left
end

function vehicle:draw()
	g.push()
	
	g.translate(self.x, self.y)
	g.rotate(self.angle)
	
	-- body
	g.color(1, 0, 0)
	g.rect(0, 0, 0.04, 0.03)
	-- wheels
	local c = self.motor_left
	g.color(0.25, c, 1-c)
	g.rect(-0.01, -0.02, 0.03, 0.005)
	local c = self.motor_right
	g.color(0.25, c, 1-c)
	g.rect(-0.01,  0.02, 0.03, 0.005)
	-- sensors
	local c = self.sensor_left
	g.color(c, c, 1-c)
	g.ellipse(self.sensor_left_x, self.sensor_left_y, 0.005)
	local c = self.sensor_right
	g.color(c, c, 1-c)
	g.ellipse(self.sensor_right_x, self.sensor_right_y, 0.005)
	
	g.pop()
end


local t = 0
function update(dt)
	t = t + dt
	
	vehicle:update(dt)
	
end


function draw()
	g.bounds(0, 0, 1, 1)
	
	vehicle:draw()
	
	g.push()
	g.color(1, 1, 0)
	g.ellipse(lightx, lighty, 0.01)
	g.pop()
	
end

function mouse(event, btn, x, y)
	if event == "down" or event == "drag" then
		lightx = x / win.width
		lighty = y / win.height
	end
end