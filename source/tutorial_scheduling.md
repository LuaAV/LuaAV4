
# Timing and scheduling

The Lua language itself does not have means to control time, however this has been added in LuaAV via the ```scheduler``` module. It allows us to schedule functions that can be paused and resumed in the process of generating audio. It is thus **strongly timed** in a similar manner to the ChucK live-coding language. 

The scheduler preserves deterministic ordering and logical timestamps to high accuracy, and is used for many messages to the audio system (such as adding/removing synths). These functions are very useful for building up musical structures because of the temporal accuracy. 

> The main scheduler follows the cpu clock as closely as possible, usually within and accuracy of around 10 milliseconds; however when slow functions are called (such as loading files and creating complex resources such as windows), the scheduler may experience a temporary drop-out, from which it will attempt to recover as soon as possible.

When scripts are run within the LuaAV application, the main functions are already available as globals. When run from a LuaJIT command line console, they will need to be loaded manually:

```lua
local av = require "av"
local now, go, wait, event = av.now, av.go, av.wait, av.event
```

## The ```now()``` function

Printing out ```now()``` in a script will return the logical time in seconds since the script was loaded. Until we start scheduling with time, all script actions occur immediately, so now() will return 0.

```lua
print(now()) 	-- prints 0
```

## The ```go()``` function

The function ```go()``` allows us to schedule functions to run in the future. It will convert a function into a ```coroutine``` and add it to the scheduler. An optional first argument can specify the time (in seconds) to wait before this function is run, and additional arguments are passed to the function when it first runs.

```
go(print, "life")
go(2, print, "and everything")
go(1, print, "the universe")

-- prints: "life"
-- after 1 second, prints: "the universe"
-- after 1 second more, prints: "and everything"
```

Of course you can put your own function instead of using ```print```:

```
local function myprint(msg)
	print(msg)
end

go(myprint, "hello")
-- or even create an anonymous function:
go(1, function() print("world") end)
```

> Coroutines are Lua's way to provides parallelism within a script. One way of thinking about a coroutines is that it is like a parallel function or script state; another way to think about it is as a function that can be paused in mid execution, while Lua goes off to execute some other code, and to later returned to (resume) at the point at which it paused. (Lua is single-threaded by design, which means that only one actual function is executing at any time.) The ```go()``` and ```wait()``` functions connect coroutines with the LuaAV timing scheduler.

## The ```wait()``` function

So far we can use ```go()``` to precisely choose when a function starts. This could be enough to create a sequencer, for example.

But since the functions are run as ```coroutine```s, we can also pause them in the middle, and resume them again later. We do this using ```wait()```. The ```wait()``` function allows us to pause the execution of a function for a number of seconds, after which it will continue:

```
go(function()
	print("life")
	wait(1)	
	print("the universe")
	wait(1)
	print("and everything")
end)
```

What makes this more powerful is that it can be combined with other kinds of control flow such as for loops, while loops, nested function calls, and so on. Here's a simple example of an infinite process that prints "tick" every 1 second:

```
go(function()
	while true do	-- loop forever
		print("tick")
		wait(1)	
	end
end)
```

Combine this with ```now()``` to create a clock:

```
go(function()
	while true do	-- loop forever
		print("tick at", now())
		wait(1)	
	end
end)
```

## Parallelism

When a coroutine is paused, other coroutines can continue to run. So we can launch multiple coroutines to create parallel processes, like multiple players in an ensemble, multiple voices in a drum machine, and so on. 

Here's a very simple example; it prints out a tick every 1 second, and a TOCK every 4 seconds:

```
function clockprinter(name, period) 
	while true do
		print(now(), name) 
		wait(period)
	end
end

go(clockprinter, "TOCK!", 4) 
go(clockprinter, "tick", 1)
```

Remember, the ```go()``` function can also take an optional first argument (delay in seconds), which allows us to schedule it to occur at some point in the future:

```
go(1.75, clockprinter, "tickety", 2) -- will start 1.75 seconds later
```

So we can create many parallel copies of the same function that can be scheduled alongside each other, each with potentially distinct timing, but without losing deterministic accuracy. 

> In this way you can easily create musical patterns like Steve Reich's [Clapping Music](http://www.youtube.com/watch?v=lzkOFJMI5i8) or the phasing patterns of his [Drumming](http://www.youtube.com/watch?v=YH9n6pwpK0A&list=PL1G8x4dgz5wN--kHkJ66eahWhPEMTD4Pd) for example.

Note that the even if the initial delay argument to ```go()``` is 0, or is not given, the coroutine will not run immediately; ```go()``` simply adds the coroutine to the internal scheduler. The function will run as soon as the scheduler next activates, which is either at the end of the script (in ```av.run()``` for console-based scripts), or when the next ```wait()``` call is made:

```lua
-- this code prints out "hello world":
go(print, "world")
print("hello")
```

## Nested coroutines

Withing a scheduled coroutine we can continue to call other functions, and the thread of execution will follow the calls until either a ```wait()``` is reached, or the original function returns. This allows us to decompose a complex pattern into smaller functions. 

We can also launch new coroutines from within another, spawning many parallel threads of execution. Putting these together, here's an implementation of Steve Reich's Clapping Music:

```
--[[
An attempt to implement Steve Reich's "Clapping Music"
--]]

function clap1()
	-- implement clap sound here
	print("clap1")
end
function clap2()
	-- implement clap sound here
	print("clap2")
end

local dur = 1/8

-- clap N times:
function claps(sound, n)
	for i = 1, n do
		-- humanize:
		local jitter = math.random() * 0.01
		-- run the clap sound as another sub-process independent of main time:
		go(jitter, play, sound)
		-- note length:
		wait(dur)
	end
end

function rest()
	wait(dur)
end

-- this is the main pattern that is repeated over and over by each player:
function pattern(sound)
	claps(sound, 3)
	rest()
	claps(sound, 2)
	rest()
	claps(sound, 1)
	rest()
	claps(sound, 2)
	rest()
end

-- the process of each player:
function clapper(sound, shift)
	while true do
		for i = 1, 4 do
			pattern(sound)
		end
		if shift then rest() end
	end
end

-- player 1 does not shift:
go(clapper, clap1, false)
-- player 2 shifts:
go(clapper, clap2, true)
```



## The ```event()``` function

Sometimes we want to schedule activity to occur not at a given time, but when a given situation occurs. To support this, the ```go()``` and ```wait()``` functions can also take a string argument (instead of a duration). The string represents the name of a unique event.

```lua
-- schedule a function to call when the "foo" event next occurs:
go("foo", function print("the foo happened") end)
```

The ```event()``` function can then be used to resume ALL coroutines that were scheduled against or waiting upon a particular event. 

```lua
-- trigger it:
event("foo")
```

A common use-case of this is to schedule sequences to arbitrary rhythmic patterns:

```lua
-- launch a background process to trigger "beat" events with a 1/0.5/0.5 pattern:
function rhythm()
	while true do
		event("beat")
		wait(1)
		
		event("beat")
		wait(0.5)
		
		event("beat")
		wait(0.5)
	end
end
go(rhythm)

-- launch another process to respond to these events by alternating AAA and BBB:
function printer()
	while true do
		print("AAA")
		wait("beat")
		
		print("BBB")
		wait("beat")
	end
end
go(printer)
```

### Event arguments

The ```event()``` function can also take additional arguments; these arguments are received by (as return values of) any corresponding ```wait()```. In this way an event handler can respond with more nuance.

```lua
go(function()
	while true do
		local result = wait("foo")
		print("received", result)
	end
end)

go(function()
	while true do
		event("foo", math.random())
		wait(0.5)
	end
end)
```

### Events and the window ```draw()``` callback

Another common use of ```event()``` is to make sure that graphical rendering commands only execute during a window’s ```draw()``` method, which is the only place they are valid. 

The following example shows how a function ```drawstuff()``` is scheduled to execute only when the draw event occurs, and once it does, to wait until subsequent drawevents to continue rendering:

```lua
local draw2D = require "draw2D"
win = Window()

-- the window rendering function
function win:draw()
	-- resume any functions waiting on the "draw" event
	event("draw")
end

function drawstuff()
	-- run forever:
	while true do
		draw2D.line(0, 0, -math.cos(now(), math.sin(now()))
		-- wait for the next frame
		wait("draw")
		-- now wait for a random fraction of a second
		wait(math.random())
	end
end

-- start drawstuff() when the next "draw" event occurs:
go("draw", drawstuff)
```

Regardless of the frame-rate requested of a window, the actual timing of ```draw()``` calls can vary widely. If you want to preserve accurate timing in a coroutine, launch draw event handlers as sub-coroutines instead:

```
function drawstuff()
	-- run forever:
	while true do
		-- render on the next frame (do not wait)
		go("draw", function()
			draw2D.line(0, 0, -math.cos(now(), math.sin(now()))
		end)
		-- now wait for an accurate amount of time:
		wait(0.25)
	end
end
```

> Note that it is not valid to ```wait()``` inside any of the window callbacks such as ```draw```. Also, be careful not to ```wait()``` in the middle of a ```gl.Begin```/```gl.End``` pair, which would leave OpenGL in an inconsistent state. 

## Pausing the main script

From within the LuaAV application, the main script is already running as a coroutine, so it is possible to ```wait()``` at the top-level of code. When launched from a command line, this is not possible; but to achieve the same result you can launch your script via another:

```lua
go(dofile, myscriptname)
```

## Script-controlled schedulers

You can also create your own schedulers, which are independent of CPU clock, using the ```scheduler.create()``` function. A scheduler is an object that provides its own ```now()```, ```wait()``` and ```go()``` functions. Unlike the main scheduler, the logical time of this user-controlled scheduler is not tied to the CPU clock, but instead is advanced within the script using the ```advance()``` or ```update()``` functions of the created scheduler.

----

[![animation](http://25.media.tumblr.com/b5bbc21c3907802325301007ce31303f/tumblr_mjksjiMKYr1qamt2wo1_500.gif)](http://www.thisiscolossal.com/2012/05/delightful-paper-pop-ups-by-jenny-chen/)
