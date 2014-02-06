--- A friendly wrapper for setting up vertex buffer objects
-- @module vbo

local ffi = require "ffi"
local gl = require "gl"
local vec2 = require "vec2"
local vec3 = require "vec3"
local vec4 = require "vec4"

ffi.cdef [[
typedef struct vertex {
	vec3f position;
	vec3f normal;
	vec2f texcoord;
	vec4f color;
} vertex;
]]



--- Create a vbo object
-- @param? n number of vertices (default 3)
-- @treturn vbo
function vbo(n) end


local vbo = {}
function vbo:__index(k)
	if type(k) == "number" then
		return self.data[k]
	else
		return vbo[k]
	end
end

function vbo.new(n)
	n = n or 3
	local self = {
		id = 0,
		dirty = false,
		count = n,
		usage = gl.DYNAMIC_DRAW,
		
		data = ffi.new("vertex[?]", n)
	}
	-- set reasonable defaults:
	for i = 0, self.count-1 do
		self.data[i].color:set(1, 1, 1, 1)
		self.data[i].normal:set(0, 0, 1)
	end
	
	-- TODO: gc handler like in shader?
	
	gl.context_register(self)
	
	return setmetatable(self, vbo)
end

--- A vertex buffer wrapper
-- @type vbo

function vbo:create()
	if self.id == 0 then
		self.id = gl.GenBuffers(1)
		self.dirty = true
	end
end

vbo.context_create = vbo.create

--- Bind the VBO
-- This will upload data to the GPU if the vbo.dirty flag is marked
-- @return self
function vbo:bind()
	self:create()
	gl.BindBuffer(gl.ARRAY_BUFFER, self.id)
	if self.dirty then
		gl.BufferData(gl.ARRAY_BUFFER, ffi.sizeof(self.data), self.data, self.usage)
		self.dirty = false
	end
	return self
end

--- Unbind the VBO
-- @return self
function vbo:unbind()
	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	return self
end

--- Set the buffer's position data as the source of a shader's attribute
-- @param shader the shader program to bind to
-- @param? name the attribute name (default "position")
-- @return self
function vbo:enable_position_attribute(shader, name)
	local attr = shader:GetAttribLocation(name or "position")
	self:bind()
	gl.VertexAttribPointer(
        attr,  	 
		3,                                --/* size */
        gl.FLOAT,                         --/* type */
        gl.FALSE,                         --/* normalized? */
        ffi.sizeof("vertex"),            --/* stride */
		ffi.cast("void *", ffi.offsetof("vertex", "position"))
    );
	gl.EnableVertexAttribArray(attr);
	self:unbind()
	return self
end

--- Disable the binding of position data as the source of a shader's attribute
-- @param shader the shader program to bind to
-- @param? name the attribute name (default "position")
-- @return self
function vbo:disable_position_attribute(shader, name)
	local attr = shader:GetAttribLocation(name or "position")
	gl.DisableVertexAttribArray(attr);
	return self
end

--- Set the buffer's normal data as the source of a shader's attribute
-- @param shader the shader program to bind to
-- @param? name the attribute name (default "normal")
-- @return self
function vbo:enable_normal_attribute(shader, name)
	local attr = shader:GetAttribLocation(name or "normal")
	self:bind()
	gl.VertexAttribPointer(
        attr,  	 
		3,                                --/* size */
        gl.FLOAT,                         --/* type */
        gl.FALSE,                         --/* normalized? */
        ffi.sizeof("vertex"),            --/* stride */
		ffi.cast("void *", ffi.offsetof("vertex", "normal"))
    );
	gl.EnableVertexAttribArray(attr);
	self:unbind()
	return self
end

--- Disable the binding of normal data as the source of a shader's attribute
-- @param shader the shader program to bind to
-- @param? name the attribute name (default "normal")
-- @return self
function vbo:disable_normal_attribute(shader, name)
	local attr = shader:GetAttribLocation(name or "normal")
	gl.DisableVertexAttribArray(attr);
	return self
end

--- Set the buffer's color data as the source of a shader's attribute
-- @param shader the shader program to bind to
-- @param? name the attribute name (default "color")
-- @return self
function vbo:enable_color_attribute(shader, name)
	local attr = shader:GetAttribLocation(name or "color")
	self:bind()
	gl.VertexAttribPointer(
        attr,  	 
		4,                                --/* size */
        gl.FLOAT,                         --/* type */
        gl.FALSE,                         --/* normalized? */
        ffi.sizeof("vertex"),            --/* stride */
		ffi.cast("void *", ffi.offsetof("vertex", "color"))
    );
	gl.EnableVertexAttribArray(attr);
	self:unbind()
	return self
end

--- Disable the binding of color data as the source of a shader's attribute
-- @param shader the shader program to bind to
-- @param? name the attribute name (default "color")
-- @return self
function vbo:disable_color_attribute(shader, name)
	local attr = shader:GetAttribLocation(name or "color")
	gl.DisableVertexAttribArray(attr);
	return self
end

--- Set the buffer's texcoord data as the source of a shader's attribute
-- @param shader the shader program to bind to
-- @param? name the attribute name (default "texcoord")
-- @return self
function vbo:enable_texcoord_attribute(shader, name)
	local attr = shader:GetAttribLocation(name or "texcoord")
	self:bind()
	gl.VertexAttribPointer(
        attr,  	 
		4,                                --/* size */
        gl.FLOAT,                         --/* type */
        gl.FALSE,                         --/* normalized? */
        ffi.sizeof("vertex"),            --/* stride */
		ffi.cast("void *", ffi.offsetof("vertex", "texcoord"))
    );
	gl.EnableVertexAttribArray(attr);
	self:unbind()
	return self
end

--- Disable the binding of texcoord data as the source of a shader's attribute
-- @param shader the shader program to bind to
-- @param? name the attribute name (default "texcoord")
-- @return self
function vbo:disable_texcoord_attribute(shader, name)
	local attr = shader:GetAttribLocation(name or "texcoord")
	gl.DisableVertexAttribArray(attr);
	return self
end

--- Submit the buffer to be rendered
-- @param? primitive rendering style (default gl.TRIANGLES)
-- @param? first the first index to render (default 0)
-- @param? count the number of vertices to render (default self.count)
-- @return self
function vbo:draw(primitive, first, count)
	gl.DrawArrays(primitive or gl.TRIANGLES, first or 0, count or self.count)
	return self
end

setmetatable(vbo, {
	__call = function(t, ...)
		return vbo.new(...)
	end,
})

return vbo