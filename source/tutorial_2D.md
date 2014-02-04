
# Drawing in 2D

LuaAV provides a few utilities for 2D drawing, somewhat similar to Cairo, HTML5 canvas, or Processing, via the [draw2D](doc/modules/draw2D.html) module. (It is implemented using the [OpenGL](tutorial_opengl.html) module.)

To do any drawing we first need a [window](tutorial_window.html); then we can implement our drawing inside the ```draw()``` or ```win:draw()``` functions. Note that the default coordinate system of the window runs from x == -1 (left side) to x == 1 (right side), and y == -1 (bottom) to y == 1 (top). 

```lua
-- load in the draw2D module:
local draw2D = require "draw2D"

function draw()
	-- draw a point exactly in the center of the window:
	draw2D.point(0, 0)
	
	-- draw a line across the window, below the point:
	draw2D.line(-1, -0.5, 1, -0.5)
	
	-- draw two shapes in the top-left and top-right quadrants:
	draw2D.rect(-0.5, 0.5, 0.25, 0.25)
	draw2D.ellipse(0.5, 0.5, 0.25, 0.25)
end
```

## Transformations & transformation stack

If we want to render the same geometry at different locations, scales and rotations in space, we would normally have to recalculate the arguments to each draw2D call. Instead, we can transform the entire space, using ```draw2D.translate()```, ```draw2D.rotate()``` and ```draw2D.scale()```. You could think of translation as meaning changing the 'start point' (in mathematical terms, the "origin") of drawing. Or you could think of it as moving the underlying "graph paper" that we are drawing onto. Similarly for the rotating the paper, or scaling it.

Unlike color(), translate(), scale() and rotate() do not replace the previous values; instead they accumulate on top of each other into a hidden state called the transformation matrix (which is a fancy name for how we get from the coordinate system in which we are currently drawing to the coordinate system of the actual output pixels). What that means is that calling translate(0.1, 0) three times in sequence is the same as calling translate(0.3, 0) once. 

Another useful feature of the transformation matrix is that it behaves like a stack: you can "push" a new matrix before modifying the coordinate system with translate() etc., and then later "pop" it to restore the coordinate system to how it was just before the push(). 

![Stack](http://upload.wikimedia.org/wikipedia/commons/2/29/Data_stack.svg)

*Pushing* the stack allows you to modify the transformation temporarily, and then later *pop* back to the previous state. Usually OpenGL provides up to 16 possible transformations on the stack.

A typical use of this is to share the same rendering code for all agents:

```lua
-- create some agents at random positions & directions:
local agents = {}
for i = 1, 100 do
	agents[i] = {
		-- random position in world:
		x = math.random()*2-1, 
		y = math.random()*2-1,
		-- random direction:
		direction = math.pi * 2 * math.random(),
		-- small size:
		size = 0.02,
	}
end

-- get local references to draw2D functions:
local color, rect, circle = draw2D.color, draw2D.rect, draw2D.circle
local push, pop = draw2D.push, draw2D.pop
local translate, rotate, scale = draw2D.translate, draw2D.rotate, draw2D.scale

-- a function to draw an agent
-- assumes the center of the agent is at (0,0)
-- the size of the agent runs from (-1,1)
-- and the agent faces to the positive X axis
function draw_agent()
	color(0.3)
	rect(0, 0, 1, 0.5)
	color(1)
	circle(0.6, 0.25, 0.2)
	circle(0.6, -0.25, 0.2)
end

-- the main rendering function:
function draw()
	-- iterate all the agents:
	for i, a in ipairs(agents) do
		-- cache the current coordinate system:
		push()
		-- change the coordinate system to match the agent:
		translate(a.x, a.y)
		rotate(a.direction)
		scale(a.size)
		-- call the routine to actually draw an agent:
		draw_agent()
		-- restore the previous coordinate sytem:
		pop()
	end
end
```

> Note that the order of transformations is important: translate followed by scale is quite different to scale followed by translate. For controlling an object, usually the order used is "translate, rotate, scale".

As a next step, it would make sense to manage the agent [positions, velocities, accelerations](tutorial_vec_force.html) etc. using ```vec2``` objects (see [vectors](tutorial_vec.html).

 