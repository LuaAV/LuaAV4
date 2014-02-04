
# Lua 5.1 / LuaJIT Quick Summary (part 1: types, control flow, and scope)

[Read about the Lua/LuaJIT language here](about_lua.html), including [documentation and resource links](about_lua.html#documentation_and_resources).

Go to [part 2](tutorial_lua_part2.html).

## Syntax

```lua
-- Two dashes create a comment that ends at the line break
print("hello world")
-- Note: there is no need for semicolons to terminate statements.
```

### Simple types

All values in Lua are one of the following types; however unlike C, the type does not belong to the variable, but to the value itself. That means that a variable can change type (dynamic typing).

```lua
-- Unlike C, the type information is stored with the value, not the variable; 
-- this means that the type of a variable can change dynamically.
x = 1 			-- x now refers to a number
x = "foo" 		-- x now refers to a string

-- check types like this:
if type(x) == "number" then 
	-- do stuff
end
```

#### Numbers

All numbers in Lua are 64-bit floating point type (aka ‘double’ for C programmers). There is no distinction between integers and non-integers. 

```lua
-- these lines are all equivalent
-- they assign the number value 1 to the variable name x:
x = 1
x = 1.0
x = 100e-2  -- e base10 format
x = 0x1 --hexadecimal format
-- Note: all numbers in Lua are 64-bit doubles
```

> The exception is FFI objects, which present any C type to Lua, including number types.


#### Strings

Lua strings are immutable: each string operation creates a new string. 

```lua
-- strings:
print("a simple string")
print('a simple string')

-- embedding special characters and multi-line strings:
x = 'escape the \' character, and write \n a new line'
x = [[
The double square brackets are a simple way to write strings
that span
over several
lines]]
```

> Strings are hashed internally very efficiently, and garbage collected.


#### Booleans and nil

Boolean values are the keywords ```true``` and ```false```. The ```nil``` value indicates the absence of a value, and also counts as false for conditional tests.

```lua
-- Boolean values:
t = true
f = false
if t then print("t!") end -- prints t!
if f then print("f!") end -- prints nothing

-- nil indicates the absence of value. 
-- Assigning nil to a variable marks the variable for garbage collection.
n = nil
-- nil also evaluates to false for a predicate:
if n then print("n!") end -- prints nothing
```

> Assigning ```nil``` to a variable removes a reference to the value; if the value is no longer accessibly referenced by code, it can be garbage collected. Assigning ```nil``` to a table key effectively removes that key from the table.


### Tables (structured data)

Lua provides only one data structure: the *table*. Tables in Lua are associative arrays, mapping **keys** to **values**. Both keys and values can be *any* valid Lua type except nil. However, the implementation makes sure that when used with continuous number keys, the table performs as a fast array. 

```lua
-- creating an array-like table of strings, the quick way:
t = { "one", "two", "three" }

-- creating a dictionary-like table, the quick way:
t = { one = 1, two = 2, three = 3 }

-- creating a table with both array-like and dictionary-like parts:
t = { "one", "two", "three", one = 1, two = 2, three = 3 }

-- create an empty table:
t = {}

-- add or replace key-value pairs in the table:
t[1] = "one"	-- array-like
t["two"] = 2	-- dictionary-like
-- a simpler way of saying that:
t.two = 2

print(t.two, t["two"]) 	--> 2 2

-- special case of nil:
-- remove a key-value pair by assigning the value nil:
t.two = nil
print(t.two)			--> <nil>

-- create a table with a sub-table:
t = {
	numbers = { 1, 2, 3 },
	letters = { "a", "b", "c" },
}

-- any Lua type (except nil) can be used as key or value
-- (including functions, other tables, the table itself, ...)
t[x] = t
t[function() end] = false
t[t] = print
-- and other madness...
```

It’s important to remember that a Lua table has two parts; an array-portion and a hash-table portion. The array portion is indexed with integer keys, starting from 1 upwards. All other keys are stored in the hash (or record) portion.

The **array** portion gives Lua tables the capability to act as ordered lists, and can grow/shrink as needed (similar to C++ vectors). Sometimes the array portion is called the **list** portion, because it is useful for creating lists similarly to LISP. In particular, the table constructor will insert numeric keys in order for any values that are not explicitly keyed:

```lua
-- these two lines are equivalent
local mylist = { [1]="foo", [2]="bar", [3]="baz" }:
local mylist = { "foo", "bar", "baz" }

print(mylist[2]) 			--> bar
		
print(unpack(mylist)) 		--> foo bar baz 
```

*Remember that Lua expects most tables to count from 1, not from 0.*

### Iterating a table

To visit **only** array-portion of a table, use a numeric for loop or ```ipairs```, like the following. The traversal follows the order of the keys, from 1 to the length of the table:

```lua
for i = 1, #mytable do
	local v = mytable[i]
	-- do things with the index (i) and value (v)
	print(i, v)
end

for i, v in ipairs(mytable) do
	-- do things with the index (i) and value (v)
	print(i, v)
end
```

To visit **all** key-value pairs of a table, including the array-portion, use a for loop with ```pairs```. Note that in this case, the order of traversal is undefined; it may be different each time.

```lua
for k, v in pairs(mytable) do
	-- do things with the key (k) and value (v)
	print(k, v)
end
```

### Functions

Functions can be declared in several ways:

```lua
-- these are equivalent:
sayhello = function(message)
  print("hello", message)
end

function sayhello(message)
  print("hello", message)
end

-- using the function:
sayhello("me")  -- prints: hello me
sayhello("you") -- prints: hello you

-- replacing the function
sayhello = function(message)
  print("hi", message)
end

sayhello("me")  -- prints: hi me
```

Functions can zero or more arguments. In Lua, they can also have more than one return value:

```lua
function minmax(a, b)
  return math.min(a, b), math.max(a, b)
end
print(minmax(42, 13)) -- prints: 13 42
```

> In Lua, functions are first-class values, just like numbers, strings and tables. That means that functions can take functions as arguments, functions can return other functions as return values, functions can be keys and values in tables. It also means that functions can be created and garbage collected dynamically.


#### Method-call syntax

A special syntax is available for a table’s member functions that are intended to be used as methods. The use of a colon (```:```) instead of a period (```.```) passes the table itself through as the first implicit argument ```self```. This is called *method-call syntax*:

```lua

-- create a table
local t = { 
	-- with one value being a number:
	num = 10, 
	-- and another value being a function:
	-- (note the use of the keyword "self")
	printvalue = function(self)
  		print(self.num)
	end,
}

-- or declare/modify it like this:
function t:printvalue()
	print(self.num)
end

-- use the method:
t.printvalue(t) -- prints: 10
```

> There's nothing really special here except some fancy syntax for convenience; saying ```t:printvalue()``` is just the same as saying ```t.printvalue(t)```.


### Logic and control flow

```lua
-- if blocks:
if x == 1 then
  print("one")
  -- as many elseifs as desired can be chained
elseif x == 2 then
  print("two")
elseif x == 3 then
  print("three")
else
  print("many")
end

-- while loops:
x = 10
while x > 0 do
  print(x)
  x = x - 1
end

repeat
  print(x)
  x = x + 1
until x == 10

-- numeric for loop:
-- count from 1 to 10
for i = 1, 10 do 
	print(i) 
end		
-- count 1, 3, 5, 7, 9:
for i = 1, 10, 2 do 
	print(i) 
end
-- count down from 10 to 1:
for i = 10, 1, -1 do 
	print(i) 
end

-- logical operators:
if x == y then print("equal") end
if x ~= y then print("not equal") end

-- combinators are "and", "or" and "not":
if x > 12 and not x >= 20 then print("teen") end
```

### Lexical scoping

If a variable is declared ```local```, it exists for any code that follows it, until the ```end``` of that block. (You can tell what a block is by how the code is indented.) Local identifiers are not visible outside the block in which they were declared, but are visible inside sub-blocks. This is called *lexical scoping*.

If a variable is not declared local, it becomes a global variable, belonging to the entire script. **This is a very common cause of bugs**, so it is better to use ```local``` in nearly all cases. (Also, local variables are more efficient).

```lua
function foo(test)
	-- a function body is a new block
	local y = "mylocal"
	if test then
		-- this is a sub-block of the function
		-- so "y" is still visible here
		print(y)  -- prints: mylocal
	end
end

-- this is outside the block in which "local y" occurred,
-- so "y" is not visible here:
print(y)    -- prints: nil
```

Assigning to a variable that has not been declared locally within the current block will search for that name in parent blocks, recursively, up to the top-level. If the name is found, the assignment is made to that variable. But if the name is still not found, Lua creates a new global instead. Mostly this does what you'd expect, so long as you use ```local``` whenever you declare a new variable.

```lua
-- an outer variable:
local x = "outside"
print(x) -- prints: outside

-- sub-block uses "local", which does not affect the variable "x" outside:
function safe()
	local x = "inside"
end
safe()
print(x) -- prints: outside

-- sub-block does not use "local", so this updates the variable "x" outside:
function unsafe()
	x = "inside"
end
unsafe()
print(x) -- prints: inside
```

#### Closures

Closures arise from the mixed use of lexically scoped local variables, and higher order functions. Any function that makes use of non-local variables effectively keeps those variable references alive within it. An example explains this better:

```lua
function make_counter()
	local count = 0
	-- notice that one function returns another
	-- each call to "make_counter()" will allocate and return a newly defined function:
	return function()
		count = count + 1
		print(count)
	end
end

-- call to make_counter() returns a function;
-- and 'captures' the local count as an 'upvalue' specific to it
local c1 = make_counter()
c1()  -- prints: 1
c1()  -- prints: 2
c1()  -- prints: 3

-- another call to make_counter() creates a new function,
-- with a new count upvalue
local c2 = make_counter()
c2()  -- prints: 1
c2()  -- prints: 2

-- the two function's upvalues are independent of each other:
c1()  -- prints: 4
```

#### Garbage collection

Objects are never explicitly deleted in Lua (though sometimes resources such as files might have explicit close() methods). When Lua gets to the end of a block, normally it can release any ```local``` variables created with it. 

However they might still be referenced (e.g. by tables or closures), in which case Lua won't release the memory until those values are no longer accessible. Most of the time we don't even need to think about it.

> Lua uses an fast incremental garbage collector that runs in the background, which silently recycles the memory for any values to which no more references remain. 

---

Go to [part 2](tutorial_lua_part2.html).