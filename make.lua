#!/usr/bin/env luajit



--[[
	Before building the site, it makes sense to rebuild the docs
		- scan the source tree for modules (.lua (or .ldoc, .c, .cpp ,.mm etc.))
		- if they contain @module, then store them in the list (with path prefix)
		- scan each one, to identify the --- comments that identify functions etc.
		- generating md files accordingly inside /source/doc/
		- all the names encountered should also be added to docurl.lua so that generated code sections of pages will link to them
--]]

--[[

# Static site generator

Static so that simple FTP works

## Goals

- Write source content in markdown format
- Use templates to separate page design from content
- Include sub-templates:
	- Common widgets shared between different templates 
- Include generated partial content:
	- Navigation menus
	- Related articles etc.

- Also generate 'theme' or 'tag' pages: links to all articles with a given tag

- Also generate non-HTML output, e.g. LaTeX CV

- Would be nice to support a 'live edit' preview mode e.g. via node.js etc. Or simply a file watcher. 

Content may be shared between several sites; e.g. an.net and gw.net and hj.name share some content. av.net would also.

## File structure

Output folder separated from model (content) folder
Perhaps also several separate "view" folders? (e.g. for different sites)

Consider for example my CV. The ideal situation would be to have a document (or tree) for all the items in the CV; this could be used with a predicate filter to generate the publication list, the project page, etc, as well as to generate the CV pdf. But the data itself should be just plain data. Perhaps tabulated into a Lua table. Then different cv views are just different scripts using the data; e.g. short-cv, full-cv, etc; and I could also use it to create a chronological "activity" log.

## Method

Partial generated content, nested templates, etc. imply at least a two-pass architecture. First gather up data, spawning jobs, then render down until no jobs remain.
If no input file is given, scan the whole tree.

Think it is a bit like make.

Filewatcher style implies building a dependency graph between jobs.
Or simply use coroutines to yield jobs if their inputs are not ready yet.
Watch out for creating the same job more than once.
Handle loops.

Is there a concatenative language way of doing it?


## Markdown parsing

1. Insert metadata at the head of a .md file; ideally this would be a Lua table

2. #include one .md inside another 

3. Run arbitrary lua code in the middle of a .md (or #include a lua script equivalently), so that we can generate 

The proposals for md comments are <!--- ---> and <!--| |-->. 
Our simple template parser understands $foo and $foo{}, so it would be easy to extend with $include{} and $lua{}. 






--]]

local concat = table.concat
local format = string.format

-- grab arguments:
arg = arg or { ... }
for i, v in ipairs(arg) do
	print(i, v)
	arg[v] = true
end

-- run shell commands:
local function cmd(fmt, ...) 
	local str = format(fmt, ...)
	--print(str) 
	return io.popen(str):read("*a") 
end

local function cmdi(fmt, ...)
	local str = format(fmt, ...)
	--print(str) 
	return io.popen(str):lines()
end

-- time is optional, defaults to current time
local function html5date(time)
	return os.date("%F", time)
end

local function html5timezone()
	local timezone = os.date("%z")
	return format("%s:%s", timezone:sub(1, 3), timezone:sub(4))
end

local function html5datetime(time)
	if time then
		return os.date("%FT%T", time)
	end
	return os.date("%FT%T")..html5timezone()
end

--print(html5datetime())
--print(html5datetime(os.time{ year=2013, month=11, day=25, hour=20, min=23, sec=46 }))

-- allow loading modules from ./modules:
package.path = "./modules/?.lua;./modules/?/init.lua;" .. package.path
package.cpath = "./modules/?.so" .. package.cpath

local fs = require "fs"
local sys = require "sys"
local kqueue = require "kqueue"
local md = require "md"
local template = require "template"
--tostring = require "tostring"

local config = {
	path = {
		content = "source",
		public = ".",
		doc_content = "../libluaav"
	},
}

-- html templates to use:
local templates = {}

-- a list of jobs to watch:
local watched = {}

local action = arg.action or arg[1] or "build"

local jobsort_priorities = { 
	"html",
	"doc",
	"lua", 
	"md",
} 
for i, v in ipairs(jobsort_priorities) do jobsort_priorities[v] = i end
local function jobsort(a, b)
	if a.type == b.type then
		return #a.path < #b.path
	else
		return jobsort_priorities[a.type] < jobsort_priorities[b.type]
	end
end

-- a list of jobs to perform:
local jobs = {}

local function job_add(job)
	jobs[#jobs+1] = job
	table.sort(jobs, jobsort)	
end

-- run current list of jobs:
local function job_run(job)
	print("-------- running job", job.type, job.name)
	
	local str = io.open(job.fullpath):read("*a")
	
	if job.type == "html" then
		print("parse", job.fullpath)
		
		-- what is the role of this file?
		local role, name = fs.ext(job.name)
		print("as", role, name)
		
		if role == "template" then
		
			local t = template(str)
			templates[name] = t
			
		elseif role == "partial" then
			
			
			
		else
			-- just a plain html file; copy across?
			
		end
	elseif job.type == "lua" then
	
		print("run", job.fullpath, str)
		
		-- pass in any args?
		local f, err = loadstring(str)
		if not f then 
			print(err) 
		else
			local ok, result = xpcall(function()
				f(str, config, job)
			end, debug.traceback)
			if not ok then print("error running", job.fullpath, result) end
		end
		
	elseif job.type == "md" then
		-- maybe pull out some header info first?
		
		local tmp = job.template or templates.default
		
		job.body, job.links = md(str)
		
		-- TODO: we could use this to create a side menu
		-- or even site-wide menu
		for i, v in ipairs(job.links) do
			print(v.title, "->", "#"..v.aname)
		end
		
		-- paste into generic page template
		local result = tmp(job)
		
		-- write it:
		local of = config.path.public .. fs.sep 
				.. concat(job.path, fs.sep) .. fs.sep
				.. job.name .. ".html"
				
		print("generating", of)
		
		cmd("touch "..of)
		
		of = io.open(of, "w")
		of:write(result)
		of:close()
	elseif job.type == "doc" then
		-- does it contain @module?
		if str:find("@module") then
		
			local result = "module"
		
			-- write it:
			local of = config.path.content .. fs.sep 
					.. "doc" .. fs.sep .. concat(job.path, fs.sep) .. fs.sep
					.. job.name .. ".md"
			print(of)
			
			cmd("touch "..of)
		
			of = io.open(of, "w")
			of:write(result)
			of:close()
		end
	end
	
	watched[job] = true
end

local function run_jobs()
	while #jobs > 0 do
		local job = table.remove(jobs, 1)
		job_run(job)
	end
	collectgarbage()
end

local kq = kqueue.new()

local function job_from_file(path, name)
	local fullpath = config.path.content .. fs.sep 
					.. concat(path, fs.sep) .. fs.sep 
					.. name
	local ext, name = fs.ext(name)	
	
	local job = {
		type=ext,
		name=name,
		path=path,
		fullpath=fullpath,
		title=name,
		
		modified = fs.modified(fullpath),
	}
	job_add(job)
	
	local w = kqueue.watch(kq, fullpath, function(w)
		print("modified:", w.filename, w.fd)
		job_add(w.job)
		run_jobs()
	end)
	w.job = job
end

function doc_from_file(path, name)
	local fullpath = config.path.doc_content .. fs.sep 
					.. concat(path, fs.sep) .. fs.sep 
					.. name
	local ext, name = fs.ext(name)	
	
	if ext == "lua" then
		print(fullpath, ext, name)
		
		local job = {
			type="doc",
			name=name,
			path=path,
			fullpath=fullpath,
			title=name,
		
			modified = fs.modified(fullpath),
		}
		job_add(job)
	
		local w = kqueue.watch(kq, fullpath, function(w)
			print("modified:", w.filename, w.fd)
			job_add(w.job)
			run_jobs()
		end)
		w.job = job
	end
end

-- build up the list of jobs:
if action == "build" then
	print("building site")
	
	fs.iter(config.path.doc_content, doc_from_file, true)
	
	-- iterate the content path (recursively):
	fs.iter(config.path.content, job_from_file, true)
else
	error("unrecognized action " .. action)
end

run_jobs()

print("now watching for changes")

kqueue.start(kq)

--[[
while true do
	
	for job in pairs(watched) do
		local mod = fs.modified(job.fullpath)
		if mod > job.modified then
			-- add job:
			jobs[#jobs+1] = job
			-- update modified:
			job.modified = mod
		end
		collectgarbage()
	end
	
	if #jobs > 0 then
		-- sort joblist:
		table.sort(jobs, jobsort)
		run_jobs()
	end
		
	sys.sleep(1)
end
--]]