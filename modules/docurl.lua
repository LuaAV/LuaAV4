-- a map of variable names to their documentation URLs:
local docurl = {}

-- TODO: add the LuaAV modules, with links to the reference pages.



for k in pairs{
	["_G"]=true, ["_VERSION"]=true, ["assert"]=true, ["collectgarbage"]=true, ["dofile"]=true, ["error"]=true, ["getfenv"]=true, ["getmetatable"]=true, ["ipairs"]=true, ["load"]=true, ["loadfile"]=true, ["loadstring"]=true, ["module"]=true, ["next"]=true, ["pairs"]=true, ["pcall"]=true, ["print"]=true, ["rawequal"]=true, ["rawget"]=true, ["rawset"]=true, ["require"]=true, ["select"]=true, ["setfenv"]=true, ["setmetatable"]=true, ["tonumber"]=true, ["tostring"]=true, ["type"]=true, ["unpack"]=true, ["xpcall"]=true,
	["coroutine.create"]=true, ["coroutine.resume"]=true, ["coroutine.running"]=true, ["coroutine.status"]=true, ["coroutine.wrap"]=true, ["coroutine.yield"]=true,
	["debug.debug"]=true, ["debug.getfenv"]=true, ["debug.gethook"]=true, ["debug.getinfo"]=true, ["debug.getlocal"]=true, ["debug.getmetatable"]=true, ["debug.getregistry"]=true, ["debug.getupvalue"]=true, ["debug.setfenv"]=true, ["debug.sethook"]=true, ["debug.setlocal"]=true, ["debug.setmetatable"]=true, ["debug.setupvalue"]=true, ["debug.traceback"]=true,
	["file:close"]=true, ["file:flush"]=true, ["file:lines"]=true, ["file:read"]=true, ["file:seek"]=true, ["file:setvbuf"]=true, ["file:write"]=true,
	["io.close"]=true, ["io.flush"]=true, ["io.input"]=true, ["io.lines"]=true, ["io.open"]=true, ["io.output"]=true, ["io.popen"]=true, ["io.read"]=true, ["io.stderr"]=true, ["io.stdin"]=true, ["io.stdout"]=true, ["io.tmpfile"]=true, ["io.type"]=true, ["io.write"]=true,
	["math.abs"]=true, ["math.acos"]=true, ["math.asin"]=true, ["math.atan"]=true, ["math.atan2"]=true, ["math.ceil"]=true, ["math.cos"]=true, ["math.cosh"]=true, ["math.deg"]=true, ["math.exp"]=true, ["math.floor"]=true, ["math.fmod"]=true, ["math.frexp"]=true, ["math.huge"]=true, ["math.ldexp"]=true, ["math.log"]=true, ["math.log10"]=true, ["math.max"]=true, ["math.min"]=true, ["math.modf"]=true, ["math.pi"]=true, ["math.pow"]=true, ["math.rad"]=true, ["math.random"]=true, ["math.randomseed"]=true, ["math.sin"]=true, ["math.sinh"]=true, ["math.sqrt"]=true, ["math.tan"]=true, ["math.tanh"]=true,
	["os.clock"]=true, ["os.date"]=true, ["os.difftime"]=true, ["os.execute"]=true, ["os.exit"]=true, ["os.getenv"]=true, ["os.remove"]=true, ["os.rename"]=true, ["os.setlocale"]=true, ["os.time"]=true, ["os.tmpname"]=true,
	["package.cpath"]=true, ["package.loaded"]=true, ["package.loaders"]=true, ["package.loadlib"]=true, ["package.path"]=true, ["package.preload"]=true, ["package.seeall"]=true,
	["string.byte"]=true, ["string.char"]=true, ["string.dump"]=true, ["string.find"]=true, ["string.format"]=true, ["string.gmatch"]=true, ["string.gsub"]=true, ["string.len"]=true, ["string.lower"]=true, ["string.match"]=true, ["string.rep"]=true, ["string.reverse"]=true, ["string.sub"]=true, ["string.upper"]=true,
	["table.concat"]=true, ["table.insert"]=true, ["table.maxn"]=true, ["table.remove"]=true, ["table.sort"]=true,
} do
	docurl[k] = "http://www.lua.org/manual/5.1/manual.html#pdf-"..k
end	

for k, v in pairs{
	["ffi.cdef"] = "ffi_cdef", 
	["ffi.C"] = "ffi_C",
	["ffi.load"] = "ffi_load",
	["ffi.new"] = "ffi_new",
	["ffi.typeof"] = "ffi_typeof",
	["ffi.cast"] = "ffi_cast",
	["ffi.metatype"] = "ffi_metatype",
	["ffi.gc"] = "ffi_gc",
	["ffi.sizeof"] = "ffi_sizeof",
	["ffi.alignof"] = "ffi_alignof",
	["ffi.offsetof"] = "ffi_offsetof",
	["ffi.istype"] = "ffi_istype",
	["ffi.errno"] = "ffi_errno",
	["ffi.string"] = "ffi_string",
	["ffi.copy"] = "ffi_copy",
	["ffi.fill"] = "ffi_fill",
	["ffi.abi"] = "ffi_abi",
	["ffi.os"] = "ffi_os",
	["ffi.arch"] = "ffi_arch",
} do
	docurl[k] = "http://luajit.org/ext_ffi_api.html#"..v
end

return docurl