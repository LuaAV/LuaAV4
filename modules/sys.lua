local ffi = require "ffi"
local C = ffi.C
ffi.cdef[[
	void Sleep(int ms);
	int poll(struct pollfd *fds, unsigned long nfds, int timeout);
]]

local sys = {}

if ffi.os == "Windows" then
	function sys.sleep(s)
		C.Sleep(s*1000)
	end
else
	function sys.sleep(s)
		C.poll(nil, 0, s*1000)
	end
end

return sys