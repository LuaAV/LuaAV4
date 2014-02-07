
# Vectors and quaternions

The ```vec2```, ```vec3``` and ```vec4``` modules add definitions of 2D, 3D and 4D vectors respectively, with many convenient functions, methods and constructors.

Vectors are very useful for representing locations in space, directions of movement, relationships between points, velocities, forces, normals and tangents, vertices and other attributes of geometry, and many other spatial relationships. Most graphics languages have some kind of vector primitives; Processing users may recognize similarities between LuaAV's vec2 and Processing's PVector, for example.

```lua
local vec2 = require "vec2"
local vec3 = require "vec3"
local vec4 = require "vec4"
```

Vectors are frequently used to manage [velocities, forces and other behaviors](tutorial_vec_force.html).

# (Euclidean) Vectors

A **vector** is one way of describing a direction with a magnitude. Vectors can describe spatial properties such as locations, but also properties that change over time such as velocities, accelerations, forces of attraction and repulsion, local wind speed and direction, etc. A magnitude without direction (such as a regular number) is called a **scalar**.

In a 2D space, a vector has two components (X, Y), in a 3D space, it has three (X, Y, Z). Programming with vectors is easier if these components are combined into a single abstraction of a *vector object*. We can also treat a position in space as a vector: *the vector from the origin (0, 0) to the position*. 

Adding two vectors is like applying their movements in series. 

The difference between two points can be obtained by subtraction; it also a vector. The *relative* position of B with respect to A is simply ```B - A```. So the position of agent B relative to agent A is ```B.position - A.position```. (For agent-oriented programming we often need to take the perspective *relative to an agent*, rather than the absolute, global perspective.)

We can multiply (or divide) vectors by scalars to make them longer or shorter. So ```A * 2``` produces a copy of vector A which is twice as long.

Using this, we can interpolate between two vectors A and B by interpolating their components according to an interpolation factor ```a``` which varies between 0 (for A) and 1 (for B) like this: ```A + a * (B - A)```. This is *linear interpolation*, or "lerp". If a is 0.5, then it corresponds to the *mean* (average) of two vectors.

The distance between two points is the length (*magnitude*) of the vector between them. We can use Pythagoras' theorem: ```distance = math.sqrt(v.x*v.x + v.y*v.y)```. 

A *unit vector* is a vector whose magnitude equals 1. The set of all unit vectors makes up the unit circle (a circle of radius 1). We can turn any vector into a unit vector by dividing by its length: 

```lua
local len = math.sqrt(v.x*v.x + v.y*v.y)
v.x = v.x / len
v.y = v.y / len
```

The angle between two points can be derived using the *arctangent* of Y over X. We can calculate it as ```math.atan2(y, x)```. (```math.atan(y/x)``` would work, except that it could be satisfied by two different angles; ```math.atan2``` is more explicit and usually gives us the angle we require.)

The length and angle of a vector form the *polar* representation. We can convert back to *Cartesian* form again just as easily:

```lua
-- Cartesian to polar:
local len = math.sqrt(v.x*v.x + v.y*v.y)
local angle = mat.atan2(y, x)
-- Polar to Cartesian:
local x = len * math.cos(angle)
local y = len * math.sin(angle)
```

This is one way that we can rotate a vector: convert to polar form, add to (or subtract from) the angle, convert back to Cartesian form. Another way is to rotate the X and Y components individually, and sum them (the matrix form):

```lua
x1 = v.x * math.cos(rotation) + v.y * math.sin(rotation)
y1 = v.y * math.cos(rotation) - v.x * math.cos(rotation)
```

The *dot product* (also known as *scalar product* or *inner product*) of two vectors v1 and v2 is defined as ```v1.x*v2x + v1.y*v2.y```. (Note the similarity with the Pythagorean theorem). In a way the dot product tells us how similar two vectors are (it is related to correlation). Geometrically it is defined as ```||A|| ||B|| cos t```, which means the length of A multiplied by the length of B multipled by the angle t between A and B. So we can re-arrange that to determine the angle between to vectors as ``` arccosine( dot(A, B) / (mag(A) * mag(B)))```. Of course, if A and B are *unit vectors*, this simplifies to ```arccosine(dot(A, b))```. 

> One useful result is that if the dot product is zero, then A and B are orthogonal (at right angles to each other). If it is positive, then the angle between is less than 90 degrees, and if negative, the vectors must face away from each other since the angle between them is greater than 90 degrees. (And since magnitudes are always positive, we can skip that part of the calculation too!)

```lua
-- create a new 2D vector:
function vec2(x, y)
	local v = {}
	v.x = x
	v.y = y
	return v
end

-- multiply a vector by a number (modifies existing vector):
function vec2_mul(self, n)
	self.x = self.x * n
	self.y = self.y * n
	return self
end
```

Agents have spatial locations (positions), which we can store as vectors (direciton and magnitude from the world origin):

```lua
function agent()
	local self = {
		pos = vec2(math.random(), math.random())
	}
	return self
end

function agent_draw(self)
	g.circle(self.pos.x, self.pos.y, 0.01)
end

A = agent()
```

New location = old location plus velocity: ```agent.pos = agent.pos + agent.velocity```. This is accumulation or *integration*, at the *first-order*. Velocity is the *rate of change* of position. Second-order integration could be expressed as ```agent.velocity = agent.velocity + agent.acceleration```, since acceleration is the *rate of change of velocity*. 

Going the other way, we can take the *difference* of current and previous location to infer the velocity: ```velocity = current_position - previous_position```, which is clearly a relative vector.

```lua
function agent()
	local self = {
		pos = vec2(math.random(), math.random()),
		vel = vec2(0, 0),
		acc = vec2(0, 0),
	}
	return self
end

function agent_update(self)
	-- update velocity by acceleration:
	vec2_add(self.vel, self.acc)
	-- update location by velocity:
	vec2_add(self.pos, self.vel)
end

function agent_draw(self)
	g.push()
	g.translate(self.pos.x, self.pos.y)
	g.rotate(vec2_angle(self.vel))
	g.circle(0, 0, 0.01)
	g.line(0, 0, 0.02, 0)
	g.pop()
end
```


## Quaternions

A quaternion is a four-component complex number (with one real and three imaginary components). It is a very useful mathematical object for dealing with orientations and rotations.

```lua
local quat = require "quat"
```
