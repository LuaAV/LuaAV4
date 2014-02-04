
# Window, keyboard and mouse

Loading the module is necessary when used from a console command line, but is not needed when used within LuaaV. Similarly, from a console command line your script should end with ```av.run()```, but this is not necessary when run from the LuaAV application:

```lua
-- these lines are not needed when run from the LuaAV application:
local av = require "av"
local Window = require "av.Window"

-- PUT YOUR SCRIPT CODE HERE

-- this lines is not needed when run from the LuaAV application:
av.run()
```

## Create/open a window

```lua
-- create and open a new window:
local win = Window()
```

Every window has an associated [OpenGL](tutorial_opengl.html) context with which we can render graphics. It also handles mouse and keyboard interactions.

## Window callbacks

When certain events occur, such as resizing a window, moving the mouse, pressing a key, or simply the succession of frames over time, the window manager may ***call back*** into your script to notify you, and let your script decide how to handle the event. 

You can handle these events either by defining a global function with a specific name (which will handle the corresponding event type for all windows), or by adding a function with that name to a specific window object. The callback names and their meanings are listed below.

### The ```draw()``` callback

The ```draw()``` function (or ```win:draw()``` method) handles requests to re-draw the window content. That means, this is the function to put all of your rendering code into. 

```lua
-- define a rendering handler for all windows:
function draw(dt)
	-- the "dt" argument is the time (in seconds) since the last draw()
	-- (so 1/dt gives an estimate of the actual frame rate)
	
	-- if you don't use the "dt" argument, 
	-- you don't need to include it in the definition of "draw()".

	-- all rendering code should go here
end

-- define a rendering handler for one specific window:
-- (note that the argument implicit "self" in the "object:method" syntax is the window)
function win:draw(dt)
	-- drawing code goes here
end
```

> Note that the default coordinate system of ```draw()``` runs from x == -1 (left side) to x == 1 (right side), and y == -1 (bottom) to y == 1 (top). However this can be changed by means of ```gl``` matrix transformations (or ```draw2D``` transformations). 

### The ```resize()``` callback

The ```resize()``` callback happens whenever the window is resized:

```lua
function win:resize(width, height)
	-- width and height are in pixels
end
```

### The ```mouse()``` callback

Several types of event can trigger a call to ```mouse()```:

- **down**: a mouse button was pressed
- **up**: a mouse button was released
- **move**: the mouse was moved
- **drag**: the mouse was moved with a button held down
- **scroll**: the mouse scroll wheel was moved

```lua
function win:mouse(event, button, x, y, dx, dy)
	-- event is a string, e.g. "down", "up", etc.
	-- button is "left", "right" or "middle"
	-- x and y are the mouse location (in pixels)
	-- dx and dy are the delta positions (for "drag" and "move" events) or scroll delta (for "scroll" event)
	
	-- for example:
	if event == "down" then
		print("click at", x, y)
	elseif event == "scroll" then
		print("scroll by", dx, dy)
	end
end
```

> Note that mouse positions are in pixel coordinates, which may need to be changed to match the coordinate system of rendering.

### The ```key()``` callback

These callbacks handle keyboard events. Modifiers are special "meta" keys shift, ctrl, alt and cmd. 

```lua
function win:key(event, k)
	-- event is either "down" for a keypress, or "up" for key release
	-- k is either a modifier string (one of "shift", "ctrl", "alt" or "cmd"),
	-- or an ASCII/unicode character number
	-- (keycodes can be converted to strings via string.char(keycode))
	
	-- for example:
	if event == "down" and k == "shift" then
		print("shift key pressed")
	elseif event == "up" and k == 32 then
		print("spacebar released")
	end
end
```

> Note that keycodes for some special keys might not be consistent between different operating systems.
