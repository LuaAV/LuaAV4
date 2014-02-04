# Lua 5.1 / LuaJIT Quick Summary (part 2: advanced topics)

Back to [part 1](tutorial_lua.html).

## Modules

A module is (usually) just a table of functions, stored in a separate file. Modules act like external libraries: re-usable, encapsulated, *modular*. Load modules using ```require```:

```lua
-- load the foo module (foo.lua):
local foo = require "foo"

-- use a module function:
foo.this()
foo.that()
```

To create a module, simply create a Lua script whose last action is to return a table. This table will typically have functions inside. Modules should not create any global variables, only locals. Modules can be placed next to the script, or in any of the locations specified by the ```package.path``` string. The name of the module file should match the module name.

```lua
-- this is the foo module, i.e. foo.lua

-- create the module table
local foo = {}

-- add some functions to the module:
foo.this = function()
	print('this')
end
foo.that = function()
	print('that')
end

-- return the module table
return foo
```

Lua guarantees a given module is only executed once. Additional calls to ```require "foo"``` will always return the same table.

## Coroutines

Coroutines are a form of collaborative multi-tasking. You can think of them as functions that can be paused in mid execution, to be resumed at that position at a later time.

> The C programmer can think of them as similar to threads, however they are explicitly paused and resumed from within a script (rather than by the operating system), and do not make use of CPU multithreading capabilities.

A coroutine is created from an existing function using ```coroutine.create()```, and is resumed using ```coroutine.resume()```. It can pause itself with ```coroutine.yield()```. In addition, values can be passed back and forth via the arguments to ```coroutine.resume()``` and ```coroutine.yield()```.

```lua
local resume, yield = coroutine.resume, coroutine.yield

-- this function will be used to create a coroutine:

local function loop()
	print("hello!")
	local x = 0
	while true do
		-- pause function here:
		yield(x)
		-- continues here:
		x = x + 1
		print(x)
	end
end

-- create the coroutine:
local c = coroutine.create(loop)

-- the first resume runs from the start of the loop() function to the first yield():
coroutine.resume(c) -- prints: hello!

-- each subsequent resume runs from the last paused yield() to the next yield():
coroutine.resume(c) -- prints: 1
coroutine.resume(c) -- prints: 2
```

In LuaAV, coroutines are extended for accurate temporal scheduling, using the ```go```, ```wait``` and ```now``` functions.

## Metatables

Lua does not provide a class-based object-oriented system by default; instead it provides the meta-mechanisms with which many different kinds of object-oriented programming styles can be implemented.

There are several special events that can apply to objects (usually tables and userdata); the default behavior for these events can be overridden by means of a *metatable*. A metatable is just an ordinary table with some reserved key names bound to functions (metamethods) to specify this variant behavior. Any table or userdata can have its metatable set; some objects may share a metatable.

For example, the ```__add``` metamethod defines what happens when two objects are added to each other:

```lua
-- a metatable for pairs
local pair_meta = {}

-- a metamethod function for how to add two pairs together:
pair_meta.__add = function(a, b)
local p = {
  a[1]+b[1],
  a[2]+b[2],
}
-- result is also a pair:
setmetatable(p, pair_meta)
  return p
end

-- a constructor for pairs:
function make_pair(x, y)
  local p = { x, y }
  -- tell p to look in pair_meta for how to handle metamethod events:
  setmetatable(p, pair_meta)
  return p
end

-- create two pairs:
local p1 = make_pair(2, 3)
local p2 = make_pair(4, 5)

-- add them (creates a new pair):
local p3 = p1 + p2
print(p3[1], p3[2]) -- prints: 6 8
```

Arithmetic operator metamethods also exist for **__mul**, **__sub**, **__div**, **__mod**, **__pow**, **__unm** (unary negation).

The **__index** metamethod is important: if a key cannot be found in a given table, it will try again in whichever object the **__index** field points to; or call the function if **__index** points to a function. This is the principal way that inheritence (of both class data and methods) is supported:

```lua
local animal = {}

function animal:isalive() print("yes!") end

local dog = {}
function dog:talk() print("bark!") end

-- create metatable for dog, that refers to animal for unknown keys:
local dog_meta = { __index = animal }

-- apply metatable to dog:
setmetatable(dog, dog_meta)

-- test it:
dog:talk()  -- prints: bark!
dog:isalive() -- prints: yes!

animal:talk() -- error!
```

A corresponding ```__newindex``` metamethod exists to handle assignments of new keys to an object.

Other metamethods include **__tostring** to convert an object to a string (in the **print()** and **tostring()** functions), **__eq, __lt** and **__le** for logical comparisons, **__concat for** the **..** operator, **__len** for the **#** operator, and **__call** for the **()** operator.

By combining all of these metamethods, and smart use metatables, various forms of class based inheritance can be designed. Several examples can be found [here](http://loop.luaforge.net/).



## LuaJIT FFI

The [Foreign-Function Interface (FFI)](http://luajit.org/ext_ffi.html) allows LuaJIT to work with C language data types and functions, and even load and use pre-compiled C libraries. Working with FFI types is usually more difficult (and dangerous!) than plain Lua, but in certain cases it can run a lot faster. To use the ffi, first:

```lua
local ffi = require "ffi"
```

To create a new C-type object ("cdata"), use ```ffi.new()```. For example, to create C-style arrays of 64-bit floating point numbers (C-type *double*):

```lua
-- create an array of five numbers (initialized with zeroes by default):
local arr = ffi.new("double[5]")
local arr = ffi.new("double[?]", 5)

-- create an array of five numbers (initialized with 1, 2, 3, 4, 5):
local arr = ffi.new("double[5]", 1, 2, 3, 4, 5)
local arr = ffi.new("double[?]", 5, 1, 2, 3, 4, 5)
local arr = ffi.new("double[5]", {1, 2, 3, 4, 5})
local arr = ffi.new("double[?]", 5, {1, 2, 3, 4, 5})
```

Arrays can be indexed just as in C. That means *it counts from zero*, unlike Lua tables that count from 1:

```lua
arr[2] = 4.2
print(arr[2]) 	--> prints 4.2
```

The ```ffi.cdef``` function is used to define new aggregate C types (structs):

```lua
-- create declarations of C types in a long string:
local cdefs = [[

	typedef struct { 
		int a;
		double b;
	} foo;

	typedef struct {
		foo first;
		foo second;
	} foopair;

]]
-- add these types the the FFI:
ffi.cdef(cdefs)

-- create a new "foo" type with all members set to zero:
local myfoo = ffi.new("foo")

-- create a new "foo" type with specific values:
local myfoo = ffi.new("foo", { 100, 4.2 })

print(myfoo.a)		 --> prints 100
print(myfoo.b) 		--> prints 4.2

-- create a new "foopair":
local myfoopair = ffi.new("foopair", { { 100, 4.2 }, { 200, 3.14 } })

print(myfoo.second.a) 	--> prints 200
```

The ```ffi.load``` function is used to load a precompiled library of C code. It is usually coupled with a ```ffi.cdef``` to declare the functions and types the library contains:

```lua
-- load the "libsndfile" dynamic library:
local lib = ffi.load("libsndfile-1.dll")

-- declare one of the functions exported by the library
-- (usually we would declare them all at once, but here we just declare one for the example)
ffi.cdef [[
	const char * sf_version_string();
]]

-- use this function by indexing the library:
local version = lib.sf_version_string()

-- version is a cdata of type "const char *"
-- (i.e. an immutable array of bytes)
-- we can turn it into a Lua string using ffi.string:
print(ffi.string(version))
```

Note that the special symbol ```ffi.C``` is a namespace for all the symbols exported by the application itself, including the basic C math library.

> We can get the type of a cdata with ```ffi.typeof```, check it with ```ffi.istype```, get the size of a type with ```ffi.sizeof``` and ```ffi.offsetof```, cast cdata between types (e.g. pointer casts) using ```ffi.cast```, copy or set memory (akin to memcpy and memset) with ```ffi.copy``` and ```ffi.fill```, all basically following the usual rules in C. We can get platform information using ```ffi.os```, ```ffi.arch``` and ```ffi.abi```. We can attach special behavior to a cdata *type* using ```ffi.metatype```, similar to metatables for Lua types. We can add a callback to a cdata *object* when it is garbage collected using ```ffi.gc```. [See the FFI API here](http://luajit.org/ext_ffi_api.html)

With these features, we can interoperate with most C libraries directly from within Lua, without unduly compromising efficiency.
