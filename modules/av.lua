#!/usr/bin/env luajit
-- av.lua can be used as a regular Lua module, or as a launcher script
-- (if it is used as a module, the main script must explicitly call av.run() at the end)
-- To know whether av.lua is executed as a module or as a launcher script:
-- if executed by require(), ... has length of 1 and contains the module name
local argc = select("#", ...)
local modulename = ...
local is_module = argc == 1 and modulename == "av"

local debug_traceback = debug.traceback

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

av = {
	-- the path to av.lua:
	path = "",
	-- general configuration
	config = {
		maxtimercallbacks = 50,
	},
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
	
	--print(arg[0], av.path)
	
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
av.now, av.go, av.wait, av.event = schedule.now, schedule.go, schedule.wait, schedule.event

-- TODO: remove this once we have core in place:
ffi.cdef[[
	// Windows
	void Sleep(int ms);
	
	// unix
	int poll(struct pollfd *fds, unsigned long nfds, int timeout);
	struct timeval {
		long int tv_sec;
		long int tv_usec;
	};
	int gettimeofday(struct timeval *restrict tp, void *restrict tzp);
]]
if ffi.os == "Windows" then
	function av.sleep(s)
		ffi.C.Sleep(s*1000)
	end
	
	local glfw = require "glfw"
	av.time = glfw.GetTime
else
	function av.sleep(s)
		ffi.C.poll(nil, 0, s*1000)
	end
	local tv = ffi.new("struct timeval[1]")
	local function time()
		ffi.C.gettimeofday(tv, nil)
		return tonumber(tv[0].tv_sec) + (tonumber(tv[0].tv_usec) * 1.0e-6)
	end
	local t0 = time()
	function av.time() return time() - t0 end
end

-- the main loop:
-- (initially defined as no-op to prevent infinite loop in user script)
function av.run() end

local t = 0
function av.step()
	local t1 = av.time()
	local dt = t1 - t	-- dt is passed to the global update(dt) call
	t = t1
	
	-- update scheduled routines:
	schedule.update(t, av.config.maxtimercallbacks)
	
	-- call global update() if it exists:	
	local f = _G.update
	if f and type(f) == "function" then
		local ok, err = xpcall(function() f(dt) end, debug_traceback)
		if not ok then
			print(err)
			-- if an error was thrown, cancel the draw to prevent endless error spew:
			_G.update = nil
		end
	end
	
	-- and repeat
	return true
end

-- the actual implementation when used:
local t = 0
local function run()
	while av.step() do 
		av.sleep(1/120)
	end
	print("done")
end


--------------------------------------------------------------------------------
-- boot sequence
--------------------------------------------------------------------------------

-- if loaded as a module, return here:
if is_module then 
	-- we're loaded as a module
	-- allow av.run() to be called from the script:
	av.run = run

	-- return the module:
	return av 
else
	-- indicate that av is already loaded
	-- so that require "av" now simply returns the local av:
	package.loaded.av = av
	
	-- modify the global arg table to trim off av.lua
	-- (so that launching a script via luajit av.lua or ./av.lua or via hashbang is consistent)
	for i = 0, argc+1 do arg[i] = arg[i+1] end

	-- pre-load LuaAV globals:
	Window = require "Window"
	now, go, wait, event = schedule.now, schedule.go, schedule.wait, schedule.event

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
	go(scriptfunc, unpack(arg))
	--scriptfunc(unpack(arg))
	
	-- start the main loop manually here:
	run()
end