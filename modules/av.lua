
-- av.lua can be used as a regular Lua module, or as a launcher script
-- (if it is used as a module, the main script must explicitly call av.run() at the end)
-- To know whether av.lua is executed as a module or as a launcher script:
-- if executed by require(), ... has length of 1 and contains the module name
local argc = select("#", ...)
local modulename = ...
local is_module = argc == 1 and modulename == "av"

-- if loaded as module in luajit, the script name is arg[0]
-- else if loaded by executing av.lua, the script name is arg[1]:
local script_filename = arg[is_module and 0 or 1]

--------------------------------------------------------------------------------
-- utilities
--------------------------------------------------------------------------------

local ffi = require "ffi"

local path_sep = ffi.os == "Windows" and "\\" or "/"

-- extend the search paths:
local path_default = ffi.os == "Windows" and "" or "./"
local module_extension = ffi.os == "Windows" and "dll" or "so"
local lib_extension = ffi.os == "Windows" and "dll" or (ffi.os == "OSX" and "dylib" or "so")
local function add_module_path(path)
	-- lua modules
	package.path = string.format("%s?.lua;%s?%sinit.lua;%s", path, path, path_sep, package.path)
	-- binary modules
	package.cpath = string.format("%s?.%s;%s", path, module_extension, package.cpath)
	-- ffi libraries
	package.ffipath = package.ffipath or ""
	package.ffipath = string.format("%s%s%slib?.%s;%s", path, ffi.os, path_sep, lib_extension, package.ffipath)
end

-- derive the containing folder (directory) from a filepath
local path_from_filename = function(filename)
	local path, name = filename:match("(.*" .. path_sep .. ")(.*)") 
	return (path or path_default), name
end

--------------------------------------------------------------------------------
-- av module
--------------------------------------------------------------------------------

local av = {
	-- the path to av.lua:
	path = "",
	-- general configuration
	config = {},
	-- data about the script being run:
	script = {
		-- the name of the script being run:	
		name = "",
		-- the path of the script being run:
		path = "",
	},
}


--------------------------------------------------------------------------------
-- script & search paths
--------------------------------------------------------------------------------

-- if loaded as a module, return here:
if is_module then 
	-- we're loaded as a module
	-- we have to assume av was found in package.path
	-- that implies av modules are also in package.path, so we don't need to modify it
	-- (but what about ffipath?)
	
	if script_filename then
		-- extract path from filename
		av.script.path = path_from_filename(script_filename)
	else
		if ffi.os ~= "Windows" then
			-- use present working directory
			av.script.path = io.popen("pwd"):read("*l")
		end
	end
else
	-- we were executed as a script
	local av_filename = assert(arg[0], "error determining path to av")
	-- extract path from filename
	av.path = path_from_filename(av_filename)
	-- add this to search paths:
	add_module_path(av.path)
	
	print(arg[0], av.path)
	
	-- now extract path from filename
	assert(script_filename, "missing argument (path of script to run)")
	-- extract path from filename
	av.script.path, av.script.name = path_from_filename(script_filename)
	-- also add this to package path:
	add_module_path(av.script.path)
end

--------------------------------------------------------------------------------
-- mainloop scheduler
--------------------------------------------------------------------------------
local scheduler = require "scheduler"
local schedule = scheduler.create()
now, go, wait, event = schedule.now, schedule.go, schedule.wait, schedule.event

-- TODO: remove this once we have core in place:
ffi.cdef[[
	void Sleep(int ms);
	int poll(struct pollfd *fds, unsigned long nfds, int timeout);
]]
local sleep
if ffi.os == "Windows" then
  function sleep(s)
    ffi.C.Sleep(s*1000)
  end
else
  function sleep(s)
    ffi.C.poll(nil, 0, s*1000)
  end
end

-- the main loop:
local t = 0
function av.run()
	-- avoid multiple invocations:
	av.run = function() end
	while true do
		t = t + 1
		schedule.update(t, config.maxtimercallbacks)
		sleep(1)
	end
end


--------------------------------------------------------------------------------
-- boot sequence
--------------------------------------------------------------------------------

-- if loaded as a module, return here:
if is_module then 
	-- we're loaded as a module
	-- just return the module:
	return av 
else
	-- indicate that av is already loaded
	-- so that require "av" now simply returns the local av:
	package.loaded.av = av
	
	-- modify the global arg table to trim off av.lua
	-- (so that launching a script via luajit av.lua or ./av.lua or via hashbang is consistent)
	for i = 0, argc+1 do arg[i] = arg[i+1] end

	-- TODO pre-load LuaAV globals

	-- TODO resume as a coroutine in the av scheduler?
	
	-- parse the script into a function:
	local scriptfunc, err = loadfile(script_filename)
	if not scriptfunc then
		-- print any parse error and exit with failure:
		print(err)
		os.exit(-1)
	end

	-- schedule this script to run as a coroutine, as soon as av.run() begins:
	-- (passing arg as ... is strictly speaking redundant; should it be removed?)
	--go(scriptfunc, unpack(arg))
	scriptfunc(unpack(arg))
	
	-- Note that the script may try to call av.run(); we need a flag to suppress double-calls
	-- start the main loop:
	-- TODO av.run()
end