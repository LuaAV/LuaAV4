
# Vectors and quaternions

The ```vec2```, ```vec3``` and ```vec4``` modules add definitions of 2D, 3D and 4D vectors respectively, with many convenient functions, methods and constructors.

Vectors are very useful for representing locations in space, directions of movement, relationships between points, velocities, forces, normals and tangents, vertices and other attributes of geometry, and many other spatial relationships. Most graphics languages have some kind of vector primitives; Processing users may recognize similarities between LuaAV's vec2 and Processing's PVector, for example.

```lua
local vec2 = require "vec2"
local vec3 = require "vec3"
local vec4 = require "vec4"
```

Vectors are frequently used to manage [velocities, forces and other behaviors](tutorial_vec_force.html).

## Quaternions

A quaternion is a four-component complex number (with one real and three imaginary components). It is a very useful mathematical object for dealing with orientations and rotations.

```lua
local quat = require "quat"
```
