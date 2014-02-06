--- A desktop window with an OpenGL context
-- @module Window

--[[

TODO:

fullscreen
clearcolor
dim / origin (as vec2?)
cursor, cursorstyle
fps
mousemove
stereo
(set)title

other glfw hints
http://www.glfw.org/docs/latest/window.html#window_hints

monitor management

joysticks

glfwExtensionSupported
glfwGetProcAddress

--]]

local debug_traceback = debug.traceback

local ok, av = pcall(require, "av")
if not ok then av = nil end

local gl = require "gl"

-- currently Window is implemented on GLFW:
local glfw = require "glfw"
if glfw.Init() == 0 then
	error("Failed to initialize GLFW")
end

local Window = {
	title = "LuaJIT",
	width = 720,
	height = 480,
	sync = true,
	autoclear = true,
}
Window.__index = Window

-- list of all active windows:
local windows = {}

local mouse_buttons = {
	[0] = "left",
	[1] = "right",
	[2] = "middle",
}
local button_actions = {
	[glfw.PRESS] = "down",
	[glfw.RELEASE] = "up",
	[glfw.REPEAT] = "repeat",
}

local keynames = {
	[glfw.KEY_LEFT_SHIFT] = "shift",
	[glfw.KEY_RIGHT_SHIFT] = "shift",
	[glfw.KEY_LEFT_ALT] = "alt",
	[glfw.KEY_RIGHT_ALT] = "alt",
	[glfw.KEY_LEFT_CONTROL] = "ctrl",
	[glfw.KEY_RIGHT_CONTROL] = "ctrl",
	[glfw.KEY_LEFT_SUPER] = "cmd",
	[glfw.KEY_RIGHT_SUPER] = "cmd",
	
	[glfw.KEY_SPACE] = "space",
	[glfw.KEY_ESCAPE] = "escape",
	[glfw.KEY_ENTER] = "enter",
	[glfw.KEY_TAB] = "tab",
	[glfw.KEY_BACKSPACE] = "delete",
	[glfw.KEY_INSERT] = "insert",
	[glfw.KEY_DELETE] = "delete",
	
	[glfw.KEY_RIGHT] = "right",
	[glfw.KEY_LEFT] = "left",
	[glfw.KEY_UP] = "up",
	[glfw.KEY_DOWN] = "down",
	[glfw.KEY_PAGE_UP] = "pageup",
	[glfw.KEY_PAGE_DOWN] = "pagedown",
	[glfw.KEY_HOME] = "home",
	[glfw.KEY_END] = "end",
	
	[glfw.KEY_KP_ENTER] = "enter",
	
	[glfw.KEY_CAPS_LOCK] = "capslock",
	[glfw.KEY_NUM_LOCK] = "numlock",
}

for i = 1, 25 do
	keynames[glfw["KEY_F"..i]] = "f"..i
end

local function new(title, w, h, x, y)
	local self
	if type(title) == "table" then
		self = title
	else
		self = {
			title = title,
			width = w,
			height = h,
			x = x or 0,
			y = y or 0,
		}
	end	
	
	self.frame = 0
	
	-- internal hidden state:
	local state = {
		mx = 0,
		my = 0,
		move = "move",
		button = "left",
	}
	
	-- TODO: derive appropriate window hints, e.g.
	--glfw.WindowHint(glfw.DEPTH_BITS, 16)
	--glfw.WindowHint(glfw.REFRESH_RATE, 0) -- max fps
	
	setmetatable(self, Window)
	
	rawset(self, "ptr", glfw.CreateWindow( self.width, self.height, self.title, nil, nil ))
	assert(self.ptr ~= nil, "Failed to open GLFW window")
	
	
	-- set (default) callbacks:
	glfw.SetFramebufferSizeCallback(self.ptr, function(ptr, w, h)		
		local f = self.resize
		if f and type(f) == "function" then
			local ok, err = xpcall(function() f(self, w, h) end, debug_traceback)
			if not ok then print(err) end
		else
			local f = _G["resize"]
			if f and type(f) == "function" then
				local ok, err = xpcall(function() f(w, h) end, debug_traceback)
				if not ok then print(err) end
			end
		end
	end)
	
	glfw.SetWindowCloseCallback(self.ptr, function(ptr)
		local f = self.closing
		if f and type(f) == "function" then
			local ok, err = xpcall(function() f(self) end, debug_traceback)
			if not ok then print(err) end
		else
			local f = _G["closing"]
			if f and type(f) == "function" then
				local ok, err = xpcall(f, debug_traceback)
				if not ok then print(err) end
			end
		end
		gl.context_destroy()
	end)
	
	glfw.SetWindowFocusCallback(self.ptr, function(ptr, b)
		local f = self.focused
		if f and type(f) == "function" then
			local ok, err = xpcall(function() f(self, b ~= 0) end, debug_traceback)
			if not ok then print(err) end
		end
	end)
	glfw.SetWindowIconifyCallback(self.ptr, function(ptr, b)
		local f = self.iconified
		if f and type(f) == "function" then
			local ok, err = xpcall(function() f(self, b ~= 0) end, debug_traceback)
			if not ok then print(err) end
		end
	end)
	
	glfw.SetCursorPosCallback(self.ptr, function(ptr, x, y)
		state.mx = x
		state.my = self.height - y
		local f = self.mouse
		if f and type(f) == "function" then
			local ok, err = xpcall(function() f(self, state.move, state.button, state.mx, state.my) end, debug_traceback)
			if not ok then print(err) end
		else
			local f = _G["mouse"]
			if f and type(f) == "function" then
				local ok, err = xpcall(function() f(state.move, state.button, state.mx, state.my) end, debug_traceback)
				if not ok then print(err) end
			end
		end
	end)
	
	glfw.SetCursorEnterCallback(self.ptr, function(ptr, b)
		local action = (b == 0) and "exit" or "enter"
		local f = self.mouse
		if f and type(f) == "function" then
			local ok, err = xpcall(function() f(self, action, state.button, state.mx, state.my) end, debug_traceback)
			if not ok then print(err) end
		else
			local f = _G["mouse"]
			if f and type(f) == "function" then
				local ok, err = xpcall(function() f(action, state.button, state.mx, state.my) end, debug_traceback)
				if not ok then print(err) end
			end
		end
	end)
	
	glfw.SetScrollCallback(self.ptr, function(ptr, dx, dy)
		-- TODO: get modifiers
		local f = self.mouse
		if f and type(f) == "function" then
			local ok, err = xpcall(function() f(self, "scroll", state.button, dx, -dy) end, debug_traceback)
			if not ok then print(err) end
		else
			local f = _G["mouse"]
			if f and type(f) == "function" then
				local ok, err = xpcall(function() f("scroll", state.button, dx, -dy) end, debug_traceback)
				if not ok then print(err) end
			end
		end
	end)
	
	glfw.SetMouseButtonCallback(self.ptr, function(ptr, button, action, mods)
		button = mouse_buttons[button]
		action = button_actions[action]
		state.move = (action == "down") and "drag" or "move"
		state.button = button
		-- TODO: get modifiers
		local f = self.mouse
		if f and type(f) == "function" then
			local ok, err = xpcall(function() f(self, action, button, state.mx, state.my) end, debug_traceback)
			if not ok then print(err) end
		else
			local f = _G["mouse"]
			if f and type(f) == "function" then
				local ok, err = xpcall(function() f(action, button, state.mx, state.my) end, debug_traceback)
				if not ok then print(err) end
			end
		end
	end)
	
	local function keycallback(action, key)
		local f = self.key
		if f and type(f) == "function" then
			local ok, err = xpcall(function() f(self, action, key) end, debug_traceback)
			if not ok then print(err) end
		else
			local f = _G["key"]
			if f and type(f) == "function" then
				local ok, err = xpcall(function() f(action, key) end, debug_traceback)
				if not ok then print(err) end
			end
		end
	end
	
	glfw.SetKeyCallback(self.ptr, function(ptr, key, scancode, action, mods)
		action = button_actions[action]
		keycallback(action, key)
		local named = keynames[key]
		if named then
			keycallback(action, named)
		end
	end)
	
	glfw.SetCharCallback(self.ptr, function(ptr, c)
		local ok, key = pcall(string.char, c)
		if ok then
			keycallback("down", key)
		end
	end)
	
	-- sync
	glfw.MakeContextCurrent(self.ptr)
	glfw.SwapInterval( self.sync and 1 or 0 )

	windows[self] = true
	
	return self
end


-- TEMP: only makes sense for single window
function Window.poll() 
	glfw.PollEvents() 
	--glfw.WaitEvents()
end
-- it can trigger callbacks, which are not safe for JIT:
jit.off(Window.poll)

local t0 = glfw.GetTime()
local function step()
	-- receive events
	Window.poll()

	local t = glfw.GetTime()
	local dt = t - t0
	t0 = t
	for self in pairs(windows) do
		if glfw.WindowShouldClose(self.ptr) == 0 then
			glfw.MakeContextCurrent(self.ptr)
			gl.Viewport(0, 0, self.width, self.height)
			
			-- on the first frame, call win:create()
			if self.frame == 0 then
			
				gl.Enable(gl.MULTISAMPLE)	
				gl.Enable(gl.POLYGON_SMOOTH)
				gl.Hint(gl.POLYGON_SMOOTH_HINT, gl.NICEST)
				gl.Enable(gl.LINE_SMOOTH)
				gl.Hint(gl.LINE_SMOOTH_HINT, gl.NICEST)
				gl.Enable(gl.POINT_SMOOTH)
				gl.Hint(gl.POINT_SMOOTH_HINT, gl.NICEST)
			
				gl.Clear()
				gl.context_create()
				
				local f = self.create
				if f and type(f) == "function" then
					local ok, err = xpcall(function() f(self) end, debug_traceback)
					if not ok then
						print(err)
						-- if an error was thrown, cancel the draw to prevent endless error spew:
						self.draw = nil
					end
				else
					local f = _G.create
					if f and type(f) == "function" then
						local ok, err = xpcall(f, debug_traceback)
						if not ok then
							print(err)
							-- if an error was thrown, cancel the draw to prevent endless error spew:
							_G.draw = nil
						end
					end
				end
			end
			self.frame = self.frame + 1
			
			if self.autoclear then
				gl.Clear()
			end
			gl.MatrixMode(gl.PROJECTION)
			gl.LoadIdentity()
			gl.MatrixMode(gl.MODELVIEW)
			gl.LoadIdentity()
			
			local f = self.draw
			if f and type(f) == "function" then
				local ok, err = xpcall(function() f(self) end, debug_traceback)
				if not ok then
					print(err)
					-- if an error was thrown, cancel the draw to prevent endless error spew:
					self.draw = nil
				end
			else
				local f = _G.draw
				if f and type(f) == "function" then
					local ok, err = xpcall(f, debug_traceback)
					if not ok then
						print(err)
						-- if an error was thrown, cancel the draw to prevent endless error spew:
						_G.draw = nil
					end
				end
			end

			glfw.SwapBuffers(self.ptr)
		else
			windows[self] = nil
		end
	end

	-- return true to keep looping if there is a window open:
	if next(windows) == nil then
		glfw.Terminate()
		return false
	else
		return true
	end
end

if av then
	Window.title = av.script.name

	-- wrap av.run:
	local av_step = av.step
	local t0 = glfw.GetTime()
	av.step = function()
		-- do the usual:
		av_step()
		-- and do GLFW:
		return step()
	end
	
	Window.run = av.run
else
	-- create a function to serve as the main loop:
	function Window.run()
		while step() do end
	end
end

setmetatable(Window, {
	__call = function(self, ...) 
		return new(...)
	end,
})

return Window