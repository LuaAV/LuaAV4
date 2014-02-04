
-- av.lua can be used as a regular Lua module, or as a launcher script
-- (if it is used as a module, the main script must explicitly call av.run() at the end)
-- To know whether av.lua is executed as a module or as a launcher script:
-- if executed by require(), ... has length of 1 and contains the module name
local argc = select("#", ...)
local modulename = ...
local is_module = argc == 1 and modulename == "av"

local ffi = require "ffi"

local path_sep = ffi.os == "Winows" and "\\" or "/"

-- extend the search paths:
local path_default = ffi.os == "Winows" and "" or "./"
local module_extension = ffi.os == "Windows" and "dll" or "so"
local lib_extension = ffi.os == "Windows" and "dll" or (ffi.os == "OSX" and "dylib" or "so")
local function add_module_path(path)
	-- lua modules
	package.path = string.format("%s?.lua;%s?%sinit.lua;%s", path, path, path_sep, package.path)
	-- binary modules
	package.cpath = string.format("%s?.%s;%s", path, module_extension, package.cpath)
	-- ffi libraries
	package.ffipath = package.ffipath or ""
	package.ffipath = string.format("%slib?.%s;%s", path, lib_extension, package.ffipath)
end

-- derive the containing folder (directory) from a filepath
local path_from_filename = function(filename)
	return filename:match("(.*" .. path_sep .. ")") or path_default
end

-- define the av module:
local av = {}

-- if loaded as a module, return here:
if is_module then return av end

-- else cache the module in case a script tries to require it:
package.loaded.av = av

-- configure module paths:
local start = arg[0]
local startpath = path_from_filename(start)
add_module_path(startpath .. "modules" .. path_sep)

local script = assert(arg[1], "missing argument 1: path of script to run")
local scriptpath = path_from_filename(script)
add_module_path(scriptpath)

-- TODO pre-load LuaAV globals

-- TODO resume as a coroutine in the av scheduler?
dofile(script)

-- Note that the script may try to call av.run(); we need a flag to suppress double-calls
-- TODO av.run()