--- displaylist: A friendly wrapper for OpenGL display lists
-- @module displaylist

local gl = require "gl"
local glu = require "glu"

--- Create a displaylist
-- @param func A Lua function containing OpenGL commands to store in the displaylist
function displaylist(func) end

local displaylist = {}
displaylist.__index = displaylist

local function new(ctor)
	local self = setmetatable({
		ctor = ctor,
		id = nil
	}, displaylist)
	-- register with window/context for rebuild callback
	gl.context_register(self)
	return self
end

function displaylist:context_destroy()
	if self.id then
		gl.DeleteLists(self.id, 1)
		self.id = nil
	end
end

function displaylist:context_create()
	self:create()
end

function displaylist:create()
	if not self.id then
		local id = gl.GenLists(1)
		gl.NewList(id, gl.COMPILE)
		self.ctor()
		gl.EndList()
		glu.assert("displaylist")
		self.id = id
	end
end

--- Draw the contents of the displaylist
function displaylist:draw()
	self:create()
	gl.CallList(self.id)
end
displaylist.__call = displaylist.draw

return new