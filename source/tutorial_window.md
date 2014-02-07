
# Window, keyboard and mouse

## Create/open a window

If you are running in the LuaAV application, you can create a window like this:

```lua
-- create and open a new window:
local win = Window()
```

The ```Window()``` constructor can take arguments to set the title and size:

```lua
local win = Window("example", 512, 512)
```

Or it can receive a table to set more attributes. For example, the ```autoclear``` attribute tells the window whether to clear the screen between each frame. It is enabled by default, but can be disabled in order to support gradual painting effects:

```lua
local win = Window {
	title = "foo",
	-- tell this window to *not* clear between frames:
	autoclear = false,
}
```

> If you are running from a console command line, some additional lines are required to set up the modules and start running the main loop:

> ```lua
-- load the Window module:
local Window = require "Window"
-- create and open a new window:
local win = Window()
-- PUT YOUR SCRIPT CODE HERE
-- the last line of the script should enter the main loop:
win.run()
```

Every window has an associated [OpenGL](tutorial_opengl.html) context with which we can render graphics. It also handles mouse and keyboard interactions.

## Window callbacks

When certain events occur, such as resizing a window, moving the mouse, pressing a key, or simply the succession of frames over time, the window manager may ***call back*** into your script to notify you, and let your script decide how to handle the event. 

You can handle these events either by defining a global function with a specific name (which will handle the corresponding event type for all windows), or by adding a function with that name to a specific window object. The callback names and their meanings are listed below.

### The ```draw()``` callback

The ```draw()``` function (or ```win:draw()``` method) handles requests to re-draw the window content. That means, this is the function to put all of your rendering code into. 

```lua
-- define a rendering handler for all windows:
function draw()
	-- all rendering code should go here
end

-- define a rendering handler for one specific window:
-- (note that the argument implicit "self" in the "object:method" syntax is the window)
function win:draw()
	-- drawing code goes here
end
```

> Note that the default coordinate system of ```draw()``` runs from x == -1 (left side) to x == 1 (right side), and y == -1 (bottom) to y == 1 (top). However this can be changed by means of ```gl``` matrix transformations (or ```draw2D``` transformations). 

### The ```mouse()``` callback

Several types of event can trigger a call to ```mouse()```:

- **down**: a mouse button was pressed
- **up**: a mouse button was released
- **move**: the mouse was moved
- **drag**: the mouse was moved with a button held down
- **scroll**: the mouse scroll wheel was moved
- **enter**: the mouse entered the window frame
- **exit**: the mouse exited the window frame

```lua
function mouse(event, button, x, y)
	-- event is a string, e.g. "down", "up", etc.
	-- button is "left", "right" or "middle"
	-- x and y are the mouse location (in pixels)
	-- unless the event is "scroll", in which case x and y are the scroll deltas
	
	-- for example:
	if event == "down" then
		print("click at", x, y)
	elseif event == "scroll" then
		print("scroll by", x, y)
	end
end
```

> Note that mouse positions are in pixel coordinates, which may need to be changed to match the coordinate system of rendering.

### The ```key()``` callback

These callbacks handle keyboard events. Modifiers are special "meta" keys shift, ctrl, alt and cmd. 

```lua
function key(event, k)
	-- event is either "down" for a keypress, or "up" for key release
	-- k is either a single character (such as "a", "B" etc.) for the key,
	-- a key name (such as "shift", "ctrl", "alt", "escape" etc),
	-- or a numeric keycode
	
	-- for example:
	if event == "down" and k == "shift" then
		print("shift key pressed")
	elseif event == "up" and k == 32 then
		print("spacebar released")
	end
end
```

> Note that the single character versions of keys only report key down events, not key up events. If you want key up events, test for the keycode number instead.

### Other callbacks

The ```resize()``` callback happens whenever the window is resized:

```lua
function win:resize(width, height)
	-- width and height are in pixels
end
```

The window will also trigger a ```create()``` callback before the first frame is rendered (a chance to initialize OpenGL resources), a ```closing()``` callback when it is closed (a chance to release resources), and a ```focused(bool)``` callback when it gains or loses focus.