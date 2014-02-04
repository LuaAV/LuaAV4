
local concat = table.concat

local fs = {}

local sep = "/"
fs.sep = sep

-- run shell commands:
local function cmd(fmt, ...) 
	local str = string.format(fmt, ...)
	print(str) 
	return io.popen(str):read("*a") 
end

local function cmdi(fmt, ...)
	local str = string.format(fmt, ...)
	print(str) 
	return io.popen(str):lines()
end

-- get file extension of a file path:
-- will return foo for baz.bar.foo
-- will return nil for .gitignore
-- returns the prefix (up to but not including the ".") as second return value
function fs.ext(str)
	local s, e, name, ext = str:find("^(.+)%.(%w+)$")
	return ext, name or str
end

local function fs_iter(root, path, cb, recursive)
	local pathstr = concat(path, sep)
	local cmd = "ls -1 "..root..sep..pathstr
	local f = assert(io.popen(cmd), "failed popen in fs.iter: "..cmd)
	for l in f:lines() do
		local ext = fs.ext(l)
		if not ext then
			if recursive then
				local path1 = { unpack(path) }
				path1[#path1+1] = l
				local ok, err = pcall(fs_iter, root, path1, cb, recursive)
				if not ok then print("skipping", path, l, err) end
			end
		else
			cb(path, l)
		end
	end
end

-- iterate the files in a path, calling cb for each one
-- if recursive is true, then it will attempt to iterate all subfolders
-- cb arguments are path and filename
function fs.iter(root, cb, recursive)
	fs_iter(root, {}, cb, recursive)
end

-- get the file modified date:
function fs.modified(fullpath)
	return tonumber(io.popen("stat -f %m " .. fullpath):read("*a"))
end

-- create a watcher for any changed files in a path
-- (returns a function to poll)
function fs.watch(root, cb, recursive)
	-- memo of path -> modified date
	local modified = {}
	-- first, get mod date of existing:
	fs.iter(root, function(path, name)
		local fullpath = root .. sep .. concat(path, sep) .. sep .. name
		local mod = tonumber(io.popen("stat -f %m " .. fullpath):read("*a"))
		print(name, mod)
		modified[fullpath] = mod
	end, recursive)
	return function(cb)
		fs.iter(root, function(path, name)
			local fullpath = root .. sep .. concat(path, sep) .. sep .. name
			if modified[fullpath] then
				local f = io.popen("stat -f %m " .. fullpath)
				if f then
					local mod = tonumber(f:read("*a"))
					if mod and mod > modified[fullpath] then
						print("Modified:", name, mod)
						modified[fullpath] = mod
					end
				end
			end
		end, recursive)
	end
end

return fs