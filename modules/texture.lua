local gl = require "gl"
local glu = require "glu"
local ffi = require "ffi"
local C = ffi.C

local texture = {}
texture.__index = texture

local function new(width, height, numtextures) 
	local self = setmetatable({
	
		target = gl.TEXTURE_2D,
		magfilter = gl.LINEAR,
		minfilter = gl.LINEAR_MIPMAP_LINEAR,
		mipmap = gl.TRUE,
		clamp = gl.CLAMP_TO_EDGE,
		internalformat = gl.RGBA,
		format = gl.RGBA,
		type = gl.UNSIGNED_BYTE,
		data = nil,
		dirty = true,
		
		-- assume 2D for now
		width = width or 512,
		height = height or 512,
		
		numtextures = numtextures or 1,
		currenttexture = 1,
		
		tex = nil,
	}, texture)
	
	-- register with window/context for rebuild callback
	gl.context_register(self)
	return self
end

--- Create a texture by loading in an image file
-- PNG, JPG, GIF etc. should be ok (uses the FreeImage library)
-- @param name image filename / path to load
-- @return OpenGL texture object
function texture.load(name)
	local freeimage = require "freeimage"
	
	-- verify loadable:
	local filetype = freeimage.GetFileType(name,0)
	assert(freeimage.FIFSupportsReading(filetype), "cannot parse image type")
	
	-- load image:
	local flags = 0
	local img = freeimage.Load(filetype, name, flags)
	if img == nil then error("failed to load "..name) end
	
	-- convert to 32bit:
	local res = freeimage.ConvertTo32Bits(img)
	freeimage.Unload(img)
	img = res
	
	-- convert greyscale images:
	local colortype = freeimage.GetColorType(img)
	if colortype == C.FIC_MINISWHITE or colortype == C.FIC_MINISBLACK then
		local res = freeimage.ConvertToGreyscale(img)
		freeimage.Unload(img)
		img = res
	end
	-- flip Y axis for GL:
	freeimage.FlipVertical(img)
	
	-- get dimensions:
	local w = freeimage.GetWidth(img)
	local h = freeimage.GetHeight(img)
	local scan_width = freeimage.GetPitch(img);
	
	-- verify:
	local datatype = freeimage.GetImageType(img)
	assert(datatype == C.FIT_BITMAP, "only 8-bit unsigned image types yet")
	
	-- create a texture:
	local tex = new(w, h)
	
	-- copy data to our own buffer:
	tex.data = ffi.new("uint8_t[?]", scan_width*h)
	freeimage.ConvertToRawBits(
		tex.data, img, 
		scan_width, 32, 
		1, 1, 1, 
		1);
		
   	-- done with image now:
   	freeimage.Unload(img)
	
	-- note that our image format is BGR:
	tex.format = gl.BGRA
	
	return tex
end	

function texture:context_destroy()
	if self.tex then
		gl.DeleteTextures(unpack(self.tex))
		self.tex = nil
	end
end

function texture:context_create() self:create() end

function texture:create()
	if not self.tex then	
		self.tex = { gl.GenTextures(self.numtextures) }
		for i, tex in ipairs(self.tex) do
			gl.BindTexture(self.target, self.tex[i])
			self.bound = true
			-- each cube face should clamp at texture edges:
			gl.TexParameteri(self.target, gl.TEXTURE_WRAP_S, self.clamp)
			gl.TexParameteri(self.target, gl.TEXTURE_WRAP_T, self.clamp)
			gl.TexParameteri(self.target, gl.TEXTURE_WRAP_R, self.clamp)
			-- normal filtering
			gl.TexParameteri(self.target, gl.TEXTURE_MAG_FILTER, self.magfilter)
			gl.TexParameteri(self.target, gl.TEXTURE_MIN_FILTER, self.minfilter)
			-- automatic mipmap
			gl.TexParameteri(self.target, gl.GENERATE_MIPMAP, self.mipmap)
			-- allocate:
			self:send()
		end
		gl.BindTexture(self.target, 0)
		self.bound = false
		glu.assert("intializing texture")
	end
end


function texture:send()
	if self.bound then	
		gl.TexImage2D(
			self.target, 
			0, 
			self.internalformat, 
			self.width, self.height, 0, 
			self.format, self.type, self.data
		)
	else
		self:bind()
		gl.TexImage2D(
			self.target, 
			0, 
			self.internalformat, 
			self.width, self.height, 0, 
			self.format, self.type, self.data
		)
		self:unbind()
	end
	self.dirty = false
end

function texture:settexture(i)
	self.currenttexture = i or self.currenttexture
end

function texture:bind(unit, tex)
	unit = unit or 0
	if tex then self:settexture(tex) end
	
	self:create()
	
	gl.ActiveTexture(gl.TEXTURE0+unit)
	gl.Enable(self.target)
	gl.BindTexture(self.target, self.tex[self.currenttexture])
	self.bound = true
	
	if self.dirty then
		self:send()
	end
end

function texture:unbind(unit)
	unit = unit or 0
	
	gl.ActiveTexture(gl.TEXTURE0+unit)
	gl.BindTexture(self.target, 0)
	gl.Disable(self.target)
	self.bound = false
end

function texture:quad(x, y, w, h, unit)
	if not y then 
		unit, x = x, nil
	end
	self:bind(unit)
	gl.sketch.quad(x, y, w, h)
	self:unbind(unit)
end

setmetatable(texture, {
	__call = function(t, w, h, n)
		return new(w, h, n)
	end,
})	
return texture