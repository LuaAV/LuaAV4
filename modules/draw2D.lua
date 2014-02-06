--- Draw2D: simple drawing primitives for 2D graphics
-- @module draw2D

local gl = require "gl"
local GL = gl
local displaylist = require "displaylist"

local texture = require "texture"
	
local pi = math.pi
local twopi = pi * 2
local halfpi = pi/2
local rad2deg = 180/pi
local sin, cos = math.sin, math.cos

local draw2D = {}

--- Define the coordinate space of the window
-- @param left the X-coordinate value of the left edge of the window (default -1)
-- @param bottom the Y-coordinate value of the bottom edge of the window (default -1)
-- @param right the X-coordinate value of the right edge of the window (default 1)
-- @param top the Y-coordinate value of the top edge of the window (default 1)
function draw2D.bounds(left, bottom, right, top)
	gl.MatrixMode(gl.PROJECTION)
	gl.LoadIdentity()
	gl.Ortho(left or -1, right or 1, bottom or -1, top or 1, -1, 1)
	gl.MatrixMode(gl.MODELVIEW)
end

--- Enable or disable blending
-- call blend(false) to disable blending
-- @param mode blend mode (optional, default true)
function draw2D.blend(mode)
	if mode == false then
		gl.Disable(gl.BLEND)
		gl.Enable(gl.DEPTH_TEST)
	else	
		-- assumes additive:
		gl.Enable(gl.BLEND)
		gl.BlendEquationSeparate(gl.FUNC_ADD, gl.FUNC_ADD)
		gl.BlendFuncSeparate(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA, gl.ONE, gl.ZERO)
		gl.Disable(gl.DEPTH_TEST)
	end
end

--- Store the current transformation until the next pop()
-- Caches the current transform matrix into the matrix stack, and pushes a new copy of the matrix onto the top.
-- Note that the stack is limited in size (typically 32 items). 
function draw2D.push() 
	gl.PushMatrix()
end

--- Restore the transformation from the previous push()
-- Discards the current transformation matrix and restores the previous matrix from the matrix stack.
function draw2D.pop() 
	gl.PopMatrix()
end

--- Move the coordinate system origin to x, y 
-- (modifies the transformation matrix)
-- @param x coordinate of new origin
-- @param y coordinate of new origin
function draw2D.translate(x, y)
	gl.Translate(x, y, 0)
end

--- Scale the coordinate system
-- (modifies the transformation matrix)
-- @param x horizontal factor
-- @param y vertical factor
function draw2D.scale(x, y)
	gl.Scale(x, y or x, 1)
end

--- Rotate the coordinate system around the origin
-- (modifies the transformation matrix)
-- @param a the angle (in radians) to rotate
function draw2D.rotate(a)
	gl.Rotate(a * rad2deg, 0, 0, 1)
end

--- Draw a point at position x,y
-- @param x coordinate of center (optional, defaults to 0)
-- @param y coordinate of center (optional, defaults to 0)
function draw2D.point(x, y)	
	x = x or 0
	y = y or 0
	gl.Begin(GL.POINTS)
		gl.Vertex2d(x, y)
	gl.End()
end

--- Draw a line from x1,y1 to x2,y2
-- @param x1 start coordinate
-- @param y1 start coordinate
-- @param x2 end coordinate (optional, defaults to 0)
-- @param y2 end coordinate (optional, defaults to 0)
function draw2D.line(x1, y1, x2, y2)	
	x2 = x2 or 0
	y2 = y2 or 0
	gl.Begin(GL.LINES)
		gl.Vertex2d(x1, y1)
		gl.Vertex2d(x2, y2)
	gl.End()
end

--- Draw a rectangle at the point (x, y) with width w and height h
-- @param x coordinate of center (optional, defaults to 0)
-- @param y coordinate of center (optional, defaults to 0)
-- @param w width (optional, defaults to 1)
-- @param h height (optional, defaults to 1)
function draw2D.rect(x, y, w, h)
	x = x or 0
	y = y or 0
	w = w or 1
	h = h or w
	local w2 = w/2
	local h2 = h/2
	local x1 = x - w2
	local y1 = y - h2
	local x2 = x + w2
	local y2 = y + h2
	gl.Begin(GL.QUADS)
		gl.TexCoord( 0,  0)
		gl.Vertex2d(x1, y1)
		gl.TexCoord( 1,  0)
		gl.Vertex2d(x2, y1)
		gl.TexCoord( 1,  1)
		gl.Vertex2d(x2, y2)
		gl.TexCoord( 0,  1)
		gl.Vertex2d(x1, y2)
	gl.End()
end

--- Draw a quad over four points
-- @param x1 coordinate of first point (optional, defaults to 0)
-- @param y1 coordinate of first point (optional, defaults to 0)
-- @param x2 coordinate of second point (optional, defaults to 1)
-- @param y2 coordinate of second point (optional, defaults to 0)
-- @param x3 coordinate of third point (optional, defaults to 1)
-- @param y3 coordinate of third point (optional, defaults to 1)
-- @param x4 coordinate of fourth point (optional, defaults to 0)
-- @param y4 coordinate of fourth point (optional, defaults to 1)
function draw2D.quad(x1, y1, x2, y2, x3, y3, x4, y4)
	gl.Begin(GL.QUADS)
		gl.Vertex2d(x1 or 0, y1 or 0)
		gl.Vertex2d(x2 or 1, y2 or 0)
		gl.Vertex2d(x3 or 1, y3 or 1)
		gl.Vertex2d(x4 or 0, y4 or 1)
	gl.End()
end

--- Draw an ellipse at the point (x, y) with horizontal diameter w and vertical diameter h
-- @param x coordinate of center (optional, defaults to 0)
-- @param y coordinate of center (optional, defaults to 0)
-- @param w horizontal diameter (optional, defaults to 1)
-- @param h vertical diameter (optional, defaults to w)
function draw2D.ellipse(x, y, w, h)
	x = x or 0
	y = y or 0
	w = w and w/2 or 0.5
	h = h and h/2 or w
	gl.Begin(GL.TRIANGLE_FAN)
	for a = 0, twopi, 0.0436 do
		gl.Vertex2d(
			x + w * cos(a), 
			y + h * sin(a)
		)
	end
	gl.End()
end

local circlelist = displaylist(function()
	gl.Begin(GL.TRIANGLE_FAN)
	for a = 0, twopi, 0.0436 do
		gl.Vertex2d(cos(a), sin(a))
	end
	gl.End()
end)	

--- Draw an ellipse at the point (x, y) with horizontal diameter d
-- @param x coordinate of center (optional, defaults to 0)
-- @param y coordinate of center (optional, defaults to 0)
-- @param d diameter (optional, defaults to 1)
function draw2D.circle(x, y, d)
	if not y then
		d = x or 1
		x, y = 0, 0
	else
		x = x or 0
		y = y or 0
	end
	local r = d and d/2 or 0.5
	gl.glPushMatrix()
		gl.glTranslated(x, y, 0)
		gl.glScaled(r, r, 1)
		circlelist:draw()
	gl.glPopMatrix()
end

--- Draw an arc at the point (x, y) with horizontal diameter d
-- @param x coordinate of center (optional, defaults to 0)
-- @param y coordinate of center (optional, defaults to 0)
-- @param s start angle (optional, defaults to -pi/2)
-- @param e end angle (optional, defaults to pi/2)
-- @param w horizontal radius (optional, defaults to 1)
-- @param h vertical radius (optional, defaults to w)
function draw2D.arc(x, y, s, e, w, h)
	x = x or 0
	y = y or 0
	s = s or -halfpi
	e = e or halfpi
	w = w and w or 1
	h = h and h or w
	gl.Begin(GL.TRIANGLE_FAN)
	gl.Vertex2d(0, 0)
	for a = s, e, 0.0436 do
		gl.Vertex2d(
			x + w * cos(a), 
			y + h * sin(a)
		)
	end
	gl.End()
end

--- Set the rendering color
-- @param red value from 0 to 1 (optional, default 0)
-- @param green value from 0 to 1 (optional, default 0)
-- @param blue value from 0 to 1 (optional, default 0)
-- @param alpha (opacity) value from 0 to 1 (optional, default 1)
function draw2D.color(red, green, blue, alpha) 
	if not green then
		gl.Color(red, red, red, 1)
	elseif not blue then
		gl.Color(red, red, red, green)
	else
		gl.Color(red, green, blue, alpha)
	end
end

--- Load an image to draw
-- @param name the image file name/path
-- @return image object
function draw2D.loadImage(name)
	local tex = texture.load(name)
	return tex
end

--- Draw an image at the point (x, y) with width w and height h
-- @param img the image to use (created by loadImage())
-- @param x coordinate of center (optional, defaults to 0)
-- @param y coordinate of center (optional, defaults to 0)
-- @param w width (optional, defaults to 1)
-- @param h height (optional, defaults to 1)
function draw2D.image(img, x, y, w, h)
	img:bind()
	draw2D.rect(x, y, w, h)
	img:unbind()
end

return draw2D